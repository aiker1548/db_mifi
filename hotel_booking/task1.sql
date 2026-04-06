-- ============================================================
-- База данных: hotel_booking
-- Задача 1 (4 балла)
-- Клиенты с более чем 2 бронированиями в разных отелях.
-- Вывести: name, email, phone, total_bookings, hotels (через запятую),
--          avg_stay (средняя длительность в днях).
-- Сортировка по total_bookings убывающей.
-- ============================================================

SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking)                                     AS total_bookings,
    STRING_AGG(DISTINCT h.name, ',' ORDER BY h.name)         AS hotels,
    AVG(b.check_out_date - b.check_in_date)                 AS avg_stay
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(b.ID_booking) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC;

-- Ожидаемый вывод:
-- name        | email                    | phone         | total_bookings | hotels                              | avg_stay
-- Bob Brown   | bob.brown@example.com    | +2233445566   | 3              | Grand Hotel,Ocean View Resort       | 3.0000
-- Ethan Hunt  | ethan.hunt@example.com   | +5566778899   | 3              | Mountain Retreat,Ocean View Resort  | 3.0000
