-- ============================================================
-- База данных: organization
-- Задача 1 (4 балла)
-- Рекурсивно найти всех подчинённых Ивана Иванова (EmployeeID = 1),
-- включая его самого.
-- Вывести: EmployeeID, EmployeeName, ManagerID, DepartmentName,
--          RoleName, ProjectNames (через запятую), TaskNames (через запятую).
-- NULL если нет проектов или задач.
-- Сортировка по имени сотрудника.
-- ============================================================

WITH RECURSIVE subordinates AS (
    -- Базовый случай: сам Иван Иванов
    SELECT EmployeeID, Name, ManagerID, DepartmentID, RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    -- Рекурсивный шаг: добавляем прямых подчинённых
    SELECT e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    FROM Employees e
    JOIN subordinates s ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name                                                          AS EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    -- Проекты через отдел сотрудника
    NULLIF(STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName), '')
                                                                    AS ProjectNames,
    -- Задачи, назначенные непосредственно сотруднику
    NULLIF(STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName), '')
                                                                    AS TaskNames
FROM subordinates s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Roles r ON s.RoleID = r.RoleID
LEFT JOIN Projects p ON p.DepartmentID = s.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = s.EmployeeID
GROUP BY s.EmployeeID, s.Name, s.ManagerID, d.DepartmentName, r.RoleName
ORDER BY s.Name;

-- Ожидаемый вывод: 30 сотрудников, отсортированных по алфавиту
-- Пример первых строк:
-- EmployeeID | EmployeeName          | ManagerID | DepartmentName   | RoleName | ProjectNames | TaskNames
-- 20         | Александр Александров | 3         | Отдел маркетинга | Менеджер | Проект B     | NULL
-- 4          | Алексей Алексеев      | 2         | Отдел продаж     | Менеджер | Проект A     | Задача 14: ..., Задача 1: ...
