-- ============================================================
-- База данных: car_races
-- Задача 3 (4 балла)
-- Классы с наименьшей средней позицией (все при ничье).
-- Для каждого авто из этих классов вывести:
-- car_name, car_class, average_position, race_count, car_country, total_races.
-- ============================================================

WITH car_stats AS (
    SELECT
        c.name                  AS car_name,
        c.class                 AS car_class,
        AVG(r.position)         AS average_position,
        COUNT(r.race)           AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
class_avg AS (
    -- Средняя позиция по классу (агрегируем все авто в классе)
    SELECT
        car_class,
        AVG(average_position)   AS class_avg_position
    FROM car_stats
    GROUP BY car_class
),
best_classes AS (
    -- Классы с минимальной средней позицией
    SELECT car_class
    FROM class_avg
    WHERE class_avg_position = (SELECT MIN(class_avg_position) FROM class_avg)
),
class_total_races AS (
    -- Общее количество гонок для каждого класса
    SELECT
        c.class                 AS car_class,
        COUNT(r.race)           AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country                  AS car_country,
    ctr.total_races
FROM car_stats cs
JOIN Classes cl ON cs.car_class = cl.class
JOIN class_total_races ctr ON cs.car_class = ctr.car_class
WHERE cs.car_class IN (SELECT car_class FROM best_classes)
ORDER BY cs.average_position;

-- Ожидаемый вывод:
-- car_name     | car_class   | average_position | race_count | car_country | total_races
-- Ferrari 488  | Convertible | 1.0000           | 1          | Italy       | 1
-- Ford Mustang | SportsCar   | 1.0000           | 1          | USA         | 1
