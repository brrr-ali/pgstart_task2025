-- Q2 - "Успешные шутники". Найти ответы с самыми низкими оценками, которые были приняты как лучший ответ,
-- это что-то вроде "парада парадоксов", где авторы приняли ответ, несмотря на низкий рейтинг
-- ищем только те ответы, которые были приняты авторами вопросов (AcceptedAnswerId),
-- даже если они имеют низкий рейтинг (Score < 0)
-- добавляется имя пользователя, который дал ответ
-- cортируем ответы по худшему рейтингу
-- ответ должен иметь тег "postgresql"

SELECT "Users"."DisplayName", p_best_answer."Id", p_best_answer."Score", p_best_answer."Tags"
FROM "Posts" p_post
         JOIN "Posts" p_best_answer on p_post."PostTypeId" = 1 AND p_post."AcceptedAnswerId" = p_best_answer."Id" AND
                                       p_best_answer."Score" < 0
    AND p_best_answer."Tags" LIKE '%postgresql%'
         JOIN "Users" ON p_best_answer."OwnerUserId" = "Users"."Id"
ORDER BY p_best_answer."Score";



EXPLAIN (ANALYZE, BUFFERS, COSTS, FORMAT JSON)
SELECT "Users"."DisplayName", p_best_answer."Id", p_best_answer."Score", p_best_answer."Tags"
FROM "Posts" p_post
         JOIN "Posts" p_best_answer on p_post."PostTypeId" = 1 AND p_post."AcceptedAnswerId" = p_best_answer."Id" AND
                                       p_best_answer."Score" < 0
    AND p_best_answer."Tags" LIKE '%postgresql%'
         JOIN "Users" ON p_best_answer."OwnerUserId" = "Users"."Id"
ORDER BY p_best_answer."Score";
