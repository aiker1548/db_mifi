-- ============================================================
-- База данных: hotel_booking
-- Задача 3 (4 балла)
-- Категоризация отелей по средней цене номера:
--   Дешевый  < 175$
--   Средний  175–300$
--   Дорогой  > 300$
-- Определить предпочитаемый тип отеля для каждого клиента
-- по приоритету: дорогой > средний > дешевый.
-- Вывести: ID_customer, name, preferred_hotel_type, visited_hotels.
-- Сортировка: дешевый -> средний -> дорогой.
-- ============================================================

WITH hotel_category AS (
    -- Категория каждого отеля по средней цене номера
    SELECT
        h.ID_hotel,
        h.name                                              AS hotel_name,
        AVG(r.price)                                        AS avg_price,
        CASE
            WHEN AVG(r.price) < 175   THEN 'Дешевый'
            WHEN AVG(r.price) <= 300  THEN 'Средний'
            ELSE                           'Дорогой'
        END                                                 AS hotel_type
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
customer_hotels AS (
    -- Все посещённые отели каждого клиента с их категорией
    SELECT
        c.ID_customer,
        c.name                                              AS customer_name,
        hc.hotel_name,
        hc.hotel_type
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN hotel_category hc ON r.ID_hotel = hc.ID_hotel
),
customer_preference AS (
    -- Предпочитаемый тип: приоритет дорогой > средний > дешевый
    SELECT
        ID_customer,
        customer_name,
        CASE
            WHEN SUM(CASE WHEN hotel_type = 'Дорогой' THEN 1 ELSE 0 END) > 0
                THEN 'Дорогой'
            WHEN SUM(CASE WHEN hotel_type = 'Средний' THEN 1 ELSE 0 END) > 0
                THEN 'Средний'
            ELSE 'Дешевый'
        END                                                 AS preferred_hotel_type,
        STRING_AGG(DISTINCT hotel_name, ',' ORDER BY hotel_name) AS visited_hotels
    FROM customer_hotels
    GROUP BY ID_customer, customer_name
)
SELECT
    ID_customer,
    customer_name                                           AS name,
    preferred_hotel_type,
    visited_hotels
FROM customer_preference
ORDER BY
    CASE preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END,
    ID_customer;

-- Ожидаемый вывод:
-- ID_customer | name               | preferred_hotel_type | visited_hotels
-- 10          | Hannah Montana     | Дешевый              | City Center Inn
-- 1           | John Doe           | Средний              | City Center Inn,Grand Hotel
-- 2           | Jane Smith         | Средний              | Grand Hotel
-- 3           | Alice Johnson      | Средний              | Grand Hotel
-- 4           | Bob Brown          | Средний              | Grand Hotel,Ocean View Resort
-- 5           | Charlie White      | Средний              | Ocean View Resort
-- 6           | Diana Prince       | Средний              | Ocean View Resort
-- 7           | Ethan Hunt         | Дорогой              | Mountain Retreat,Ocean View Resort
-- 8           | Fiona Apple        | Дорогой              | Mountain Retreat
-- 9           | George Washington  | Дорогой              | City Center Inn,Mountain Retreat
