-- ============================================================
-- База данных: car_races
-- Задача 4 (4 балла)
-- Автомобили, у которых средняя позиция лучше (меньше) средней
-- по своему классу. Класс должен содержать минимум 2 автомобиля.
-- Вывести: car_name, car_class, average_position, race_count, car_country.
-- Сортировка: по классу, затем по average_position.
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
class_stats AS (
    -- Средняя позиция и количество авто по классу
    SELECT
        car_class,
        AVG(average_position)   AS class_avg_position,
        COUNT(*)                AS cars_in_class
    FROM car_stats
    GROUP BY car_class
    HAVING COUNT(*) >= 2        -- только классы с минимум двумя авто
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country                  AS car_country
FROM car_stats cs
JOIN class_stats cls ON cs.car_class = cls.car_class
JOIN Classes cl ON cs.car_class = cl.class
WHERE cs.average_position < cls.class_avg_position
ORDER BY cs.car_class, cs.average_position;

-- Ожидаемый вывод:
-- car_name        | car_class | average_position | race_count | car_country
-- BMW 3 Series    | Sedan     | 3.0000           | 1          | Germany
-- Toyota RAV4     | SUV       | 2.0000           | 1          | Japan
