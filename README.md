# pgstart_task2025
Тестовое задание для стажировки PGStart
Инструкция по запуску:
1) создайте базу данных, в ней выполните скрипт `create.sql`
2) запустите скрипт `insert.sql` - произойдет вставка дополнительных таблиц, не входящих в дамп
3) для загрузки дампа выполните команды, передавая свои параметры
```
python xml_to_db.py ./data/Users.xml --db=pgstart --table="Users" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/Badges.xml --db=pgstart --table="Badges" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/Posts.xml --db=pgstart --table="Posts" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/PostHistory.xml --db=pgstart --table="PostHistory" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/PostLinks.xml --db=pgstart --table="PostLinks" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/Comments.xml --db=pgstart --table="Comments" --user=postgres   --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/Tags.xml --db=pgstart --table="Tags" --user=postgres --password=your_password --host=localhost --port=5432

python xml_to_db.py ./data/Votes.xml --db=pgstart --table="Votes" --user=postgres   --password=your_password --host=localhost --port=5432

```
Запросы и их планы выполнения находятся в папке `requests`.

Для улучшения скорости запросов можно добавить индексы. Хотя сейчас данных относительно мало и добавление индексов, вероятно, будет не эффективно. 

Время исполнения 1 запроса можно улучшить изменением порядка условий, если сначала проверить есть ли подстрока postgresql, а затем проверять количество тегов. 
