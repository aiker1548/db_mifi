-- ============================================================
-- База данных: car_races
-- Задача 5 (4 балла)
-- Классы с наибольшим количеством авто с низкой средней позицией (> 3.0).
-- Вывести все авто из таких классов:
-- car_name, car_class, average_position, race_count,
-- car_country, total_races, low_position_count.
-- Сортировка по low_position_count.
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
class_low_count AS (
    -- Количество авто с низкой позицией (> 3.0) по классу
    SELECT
        car_class,
        SUM(CASE WHEN average_position > 3.0 THEN 1 ELSE 0 END) AS low_position_count
    FROM car_stats
    GROUP BY car_class
),
class_total_races AS (
    -- Общее количество гонок на класс
    SELECT
        c.class                 AS car_class,
        COUNT(r.race)           AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
max_low AS (
    -- Максимальное значение low_position_count
    SELECT MAX(low_position_count) AS max_low_count
    FROM class_low_count
    WHERE low_position_count > 0
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country                  AS car_country,
    ctr.total_races,
    clc.low_position_count
FROM car_stats cs
JOIN class_low_count clc ON cs.car_class = clc.car_class
JOIN class_total_races ctr ON cs.car_class = ctr.car_class
JOIN Classes cl ON cs.car_class = cl.class
JOIN max_low ml ON clc.low_position_count = ml.max_low_count
ORDER BY clc.low_position_count DESC, cs.car_name;

-- Ожидаемый вывод:
-- car_name         | car_class | average_position | race_count | car_country | total_races | low_position_count
-- Audi A4          | Sedan     | 8.0000           | 1          | Germany     | 2           | 2
-- Chevrolet Camaro | Coupe     | 4.0000           | 1          | USA         | 1           | 1
-- Renault Clio     | Hatchback | 5.0000           | 1          | France      | 1           | 1
-- Ford F-150       | Pickup    | 6.0000           | 1          | USA         | 1           | 1
