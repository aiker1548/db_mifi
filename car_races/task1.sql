-- ============================================================
-- База данных: car_races
-- Задача 1 (4 балла)
-- Автомобиль с наименьшей средней позицией в каждом классе.
-- Вывести: car_name, car_class, average_position, race_count.
-- Сортировка по average_position.
-- ============================================================

WITH car_stats AS (
    -- Считаем среднюю позицию и количество гонок для каждого авто
    SELECT
        c.name                  AS car_name,
        c.class                 AS car_class,
        AVG(r.position)         AS average_position,
        COUNT(r.race)           AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
min_per_class AS (
    -- Находим минимальную среднюю позицию в каждом классе
    SELECT
        car_class,
        MIN(average_position) AS min_avg_position
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count
FROM car_stats cs
JOIN min_per_class mpc
    ON cs.car_class = mpc.car_class
    AND cs.average_position = mpc.min_avg_position
ORDER BY cs.average_position;

-- Ожидаемый вывод:
-- car_name               | car_class    | average_position | race_count
-- Ferrari 488            | Convertible  | 1.0000           | 1
-- Ford Mustang           | SportsCar    | 1.0000           | 1
-- Toyota RAV4            | SUV          | 2.0000           | 1
-- Mercedes-Benz S-Class  | Luxury Sedan | 2.0000           | 1
-- BMW 3 Series           | Sedan        | 3.0000           | 1
-- Chevrolet Camaro       | Coupe        | 4.0000           | 1
-- Renault Clio           | Hatchback    | 5.0000           | 1
-- Ford F-150             | Pickup       | 6.0000           | 1
