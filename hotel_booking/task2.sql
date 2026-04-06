-- ============================================================
-- База данных: hotel_booking
-- Задача 2 (4 балла)
-- Клиенты, удовлетворяющие ОБОИМ условиям:
--   1) более 2 бронирований в более чем 1 отеле
--   2) потратили более 500$
-- Вывести: ID_customer, name, total_bookings, total_spent, unique_hotels.
-- Сортировка по total_spent.
-- ============================================================

-- Клиенты условия 1: > 2 бронирований И > 1 уникального отеля
WITH group1 AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking)                                 AS total_bookings,
        COUNT(DISTINCT h.ID_hotel)                          AS unique_hotels,
        SUM((b.check_out_date - b.check_in_date) * r.price) AS total_spent
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name
    HAVING COUNT(b.ID_booking) > 2
       AND COUNT(DISTINCT h.ID_hotel) > 1
),
-- Клиенты условия 2: потратили > 500$
group2 AS (
    SELECT
        c.ID_customer,
        c.name,
        SUM((b.check_out_date - b.check_in_date) * r.price) AS total_spent,
        COUNT(b.ID_booking)                                 AS total_bookings
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    GROUP BY c.ID_customer, c.name
    HAVING SUM((b.check_out_date - b.check_in_date) * r.price) > 500
)
-- Пересечение: клиенты из обеих групп
SELECT
    g1.ID_customer,
    g1.name,
    g1.total_bookings,
    g1.total_spent,
    g1.unique_hotels
FROM group1 g1
JOIN group2 g2 ON g1.ID_customer = g2.ID_customer
ORDER BY g1.total_spent;

-- Ожидаемый вывод:
-- ID_customer | name       | total_bookings | total_spent | unique_hotels
-- 4           | Bob Brown  | 3              | 820.00      | 2
-- 7           | Ethan Hunt | 3              | 850.00      | 2
