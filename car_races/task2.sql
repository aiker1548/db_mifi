-- ============================================================
-- База данных: car_races
-- Задача 2 (4 балла)
-- Автомобиль с наименьшей средней позицией среди всех.
-- При ничье — выбрать первого по алфавиту.
-- Вывести: car_name, car_class, average_position, race_count, car_country.
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
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country              AS car_country
FROM car_stats cs
JOIN Classes cl ON cs.car_class = cl.class
WHERE cs.average_position = (SELECT MIN(average_position) FROM car_stats)
ORDER BY cs.car_name
LIMIT 1;

-- Ожидаемый вывод:
-- car_name    | car_class   | average_position | race_count | car_country
-- Ferrari 488 | Convertible | 1.0000           | 1          | Italy
