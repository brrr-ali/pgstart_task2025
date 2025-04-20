import argparse
import xml.etree.ElementTree as ET
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_batch
from datetime import datetime
import os

def get_self_referential_columns(conn, table_name):
    # Получаем самореферентные внешние ключи
    self_refs = {}
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT kcu.column_name, c.confrelid::regclass
            FROM pg_constraint c
            JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
            JOIN pg_class cl ON cl.oid = c.conrelid
            JOIN pg_namespace n ON n.oid = cl.relnamespace
            JOIN information_schema.key_column_usage kcu 
                ON kcu.constraint_name = c.conname
            WHERE c.contype = 'f' 
                AND cl.relname = %s 
                AND c.confrelid = c.conrelid
        """, (table_name,))
        
        for col, ref_table in cursor:
            if ref_table == table_name:
                self_refs[col] = {'values': [], 'positions': []}
    return self_refs

def parse_xml(file_path, table_name):
    tree = ET.parse(file_path)
    root = tree.getroot()
    
    data = []
    for row in root.findall('row'):
        item = {}
        for attr in row.attrib:
            value = row.get(attr)
            
            if value in ('True', 'False'):
                value = value == 'True'
            
            if 'Date' in attr and value:
                try:
                    value = datetime.fromisoformat(value.replace('T', ' '))
                except ValueError:
                    pass
            
            item[attr] = value
        data.append(item)
    return data

def import_to_postgres(data, table_name, conn):
    """Импорт данных с обработкой самореферентных внешних ключей"""
    if not data:
        print(f"No data found for table {table_name}")
        return

    # Получаем информацию о самореферентных колонках
    self_refs = get_self_referential_columns(conn, table_name)
    
    columns = set()
    for item in data:
        columns.update(item.keys())
    columns = list(columns)

    # Создаем маску для самореферентных колонок
    self_ref_mask = {col: idx for idx, col in enumerate(columns) if col in self_refs}
    
    insert_query = sql.SQL("""
        INSERT INTO {} ({}) VALUES ({})
        ON CONFLICT ("Id") DO NOTHING
    """).format(
        sql.Identifier(table_name),
        sql.SQL(', ').join(map(sql.Identifier, columns)),
        sql.SQL(', ').join([sql.Placeholder()] * len(columns)))
    
    update_queries = {}
    with conn.cursor() as cursor:
        try:
            # Отключаем проверку внешних ключей
            cursor.execute("SET session_replication_role = replica;")
            
            # Первый этап: вставка всех данных с NULL в самореферентных колонках
            batch_values = []
            for item in data:
                values = [item.get(col) for col in columns]
                for col, pos in self_ref_mask.items():
                    original_value = values[pos]
                    if original_value is not None:
                        if col not in update_queries:
                            update_queries[col] = []
                        update_queries[col].append((
                            item['Id'],
                            original_value
                        ))

                for col in self_ref_mask:
                    values[pos] = None
                
                batch_values.append(tuple(values))
            execute_batch(cursor, insert_query, batch_values)
            
            # Второй этап: обновление самореферентных колонок
            for col, records in update_queries.items():
                update_query = sql.SQL("""
                    UPDATE {} 
                    SET {} = %s 
                    WHERE "Id" = %s
                """).format(
                    sql.Identifier(table_name),
                    sql.Identifier(col))
                update_data = [(ref_id, item_id) for item_id, ref_id in records]
                execute_batch(cursor, update_query, update_data)
            
            # Включаем проверку обратно
            cursor.execute("SET session_replication_role = DEFAULT;")
            
            conn.commit()
            print(f"Successfully imported {len(data)} rows to {table_name}")
            
        except Exception as e:
            conn.rollback()
            print(f"Error importing to {table_name}: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description='Import XML data to PostgreSQL')
    parser.add_argument('xml_file', help='Path to XML file')
    parser.add_argument('--db', required=True, help='Database name')
    parser.add_argument('--table', required=True, help='Target table name')
    parser.add_argument('--user', required=True, help='Database user')
    parser.add_argument('--password', required=True, help='Database password')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', default='5432', help='Database port')
    
    args = parser.parse_args()

    if not os.path.exists(args.xml_file):
        print(f"Error: XML file {args.xml_file} not found")
        return

    try:
        conn = psycopg2.connect(
            dbname=args.db,
            user=args.user,
            password=args.password,
            host=args.host,
            port=args.port
        )
        
        data = parse_xml(args.xml_file, args.table)
        
        if data:
            import_to_postgres(data, args.table, conn)
            
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()