-- ============================================================
-- База данных: organization
-- Задача 3 (4 балла)
-- Найти сотрудников с ролью «Менеджер», у которых есть подчинённые.
-- TotalSubordinates — ВСЕХ подчинённых рекурсивно (включая вложенных).
-- Вывести: EmployeeID, EmployeeName, ManagerID, DepartmentName,
--          RoleName, ProjectNames, TaskNames, TotalSubordinates.
-- ============================================================

WITH RECURSIVE all_subordinates AS (
    -- Базовый случай: все сотрудники с их прямым менеджером
    SELECT
        EmployeeID,
        ManagerID,
        ManagerID AS root_manager
    FROM Employees
    WHERE ManagerID IS NOT NULL

    UNION ALL

    -- Поднимаемся вверх рекурсивно чтобы посчитать всех подчинённых каждого менеджера
    SELECT
        e.EmployeeID,
        e.ManagerID,
        s.root_manager
    FROM Employees e
    JOIN all_subordinates s ON e.ManagerID = s.EmployeeID
    -- В PostgreSQL глубина рекурсии не ограничена жёстко (управляется max_recursion_depth)
)
-- Считаем итоговое количество подчинённых (всех уровней) для каждого менеджера
, subordinate_counts AS (
    SELECT
        root_manager        AS EmployeeID,
        COUNT(*)            AS TotalSubordinates
    FROM all_subordinates
    GROUP BY root_manager
)
SELECT
    e.EmployeeID,
    e.Name                                                          AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    NULLIF(STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName), '')
                                                                    AS ProjectNames,
    NULLIF(STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName), '')
                                                                    AS TaskNames,
    sc.TotalSubordinates
FROM Employees e
JOIN Roles r ON e.RoleID = r.RoleID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN subordinate_counts sc ON e.EmployeeID = sc.EmployeeID
LEFT JOIN Projects p ON p.DepartmentID = e.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = e.EmployeeID
WHERE r.RoleName = 'Менеджер'
  AND sc.TotalSubordinates > 0
GROUP BY e.EmployeeID, e.Name, e.ManagerID, d.DepartmentName, r.RoleName, sc.TotalSubordinates
ORDER BY e.Name;

-- Ожидаемый вывод (фрагмент):
-- EmployeeID | EmployeeName      | ManagerID | DepartmentName | RoleName | ProjectNames | TaskNames                         | TotalSubordinates
-- 4          | Алексей Алексеев  | 2         | Отдел продаж   | Менеджер | Проект A     | Задача 14:..., Задача 1:...       | 4
-- 5          | Мария Мариева     | 3         | Отдел маркетинга | Менеджер | Проект B   | Задача 5: Создание рекл. кампании | (число подчинённых)
