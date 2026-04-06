-- ============================================================
-- База данных: vehicles
-- Задача 1 (3 балла)
-- Найти производителей и модели всех мотоциклов с мощностью > 150 л.с.,
-- ценой < 20 000$ и типом Sport. Сортировка по мощности убывающей.
-- ============================================================

SELECT
    v.maker,
    m.model
FROM Motorcycle m
JOIN Vehicle v ON m.model = v.model
WHERE m.horsepower > 150
  AND m.price < 20000
  AND m.type = 'Sport'
ORDER BY m.horsepower DESC;

-- Ожидаемый вывод:
-- maker   | model
-- Yamaha  | YZF-R1
