-- Q1 - "Репутационные пары". Запрос анализирует какие теги задаются одновременно, как быстро на них отвечают,
-- и как это связано с репутацией пользователей
-- находит самые популярные пары тегов (теги, которые часто задаются вместе).
-- вопрос-ответ должен иметь тег "postgresql"
-- определяет среднее время ответа на вопросы с этими тегами
-- сопоставляет это с репутацией пользователей, которые дали ответы

WITH popular_pairs_of_tags AS (SELECT "Tags", count(*), RANK() OVER (ORDER BY count(*) DESC ) AS rank

                               FROM "Posts"
                               WHERE (LENGTH("Tags") - LENGTH(REPLACE("Tags", '|', '')) = 3)
                                 AND "Tags" LIKE '%postgresql%'
                               GROUP BY "Tags"
                               ORDER BY count(*) DESC),
     answer_time as (SELECT p_post."Id",
                            p_post."Tags",
                            p_answ."CreationDate" - p_post."CreationDate" as answer_time,
                            "Reputation"
                     FROM "Posts" p_answ
                              JOIN "Posts" p_post ON p_answ."ParentId" = p_post."Id" AND p_answ."PostTypeId" = 2 AND
                                                     p_post."PostTypeId" = 1
                              JOIN "Users" ON p_answ."OwnerUserId" = "Users"."Id")

SELECT answer_time."Tags", avg(answer_time) as avg_answer_time, avg("Reputation") as avg_reputation
FROM answer_time
         JOIN popular_pairs_of_tags
              ON popular_pairs_of_tags.rank < 10 and answer_time."Tags" = popular_pairs_of_tags."Tags"
GROUP BY answer_time."Tags";



EXPLAIN (ANALYZE, BUFFERS, COSTS, FORMAT JSON)
WITH popular_pairs_of_tags AS (SELECT "Tags", count(*), RANK() OVER (ORDER BY count(*) DESC ) AS rank

                               FROM "Posts"
                               WHERE (LENGTH("Tags") - LENGTH(REPLACE("Tags", '|', '')) = 3)
                                 AND "Tags" LIKE '%postgresql%'
                               GROUP BY "Tags"
                               ORDER BY count(*) DESC),
     answer_time as (SELECT p_post."Id",
                            p_post."Tags",
                            p_answ."CreationDate" - p_post."CreationDate" as answer_time,
                            "Reputation"
                     FROM "Posts" p_answ
                              JOIN "Posts" p_post ON p_answ."ParentId" = p_post."Id" AND p_answ."PostTypeId" = 2 AND
                                                     p_post."PostTypeId" = 1
                              JOIN "Users" ON p_answ."OwnerUserId" = "Users"."Id")

SELECT answer_time."Tags", avg(answer_time) as avg_answer_time, avg("Reputation") as avg_reputation
FROM answer_time
         JOIN popular_pairs_of_tags
              ON popular_pairs_of_tags.rank < 10 and answer_time."Tags" = popular_pairs_of_tags."Tags"
GROUP BY answer_time."Tags";