-- ============================================================
-- База данных: organization
-- Задача 2 (4 балла)
-- То же что задача 1, плюс:
--   TotalTasks       — общее количество задач сотрудника
--   TotalSubordinates — количество ПРЯМЫХ подчинённых (не рекурсивно)
-- Сортировка по имени сотрудника.
-- ============================================================

WITH RECURSIVE subordinates AS (
    SELECT EmployeeID, Name, ManagerID, DepartmentID, RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    SELECT e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    FROM Employees e
    JOIN subordinates s ON e.ManagerID = s.EmployeeID
),
direct_sub_count AS (
    -- Считаем прямых подчинённых для каждого сотрудника
    SELECT
        ManagerID,
        COUNT(*) AS direct_count
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT
    s.EmployeeID,
    s.Name                                                          AS EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    NULLIF(STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName), '')
                                                                    AS ProjectNames,
    NULLIF(STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName), '')
                                                                    AS TaskNames,
    COUNT(DISTINCT t.TaskID)                                        AS TotalTasks,
    COALESCE(dsc.direct_count, 0)                                   AS TotalSubordinates
FROM subordinates s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Roles r ON s.RoleID = r.RoleID
LEFT JOIN Projects p ON p.DepartmentID = s.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = s.EmployeeID
LEFT JOIN direct_sub_count dsc ON dsc.ManagerID = s.EmployeeID
GROUP BY s.EmployeeID, s.Name, s.ManagerID, d.DepartmentName, r.RoleName, dsc.direct_count
ORDER BY s.Name;

-- Ожидаемый вывод (30 строк):
-- EmployeeID | EmployeeName | ManagerID | DepartmentName | RoleName | ProjectNames | TaskNames | TotalTasks | TotalSubordinates
-- 20 | Александр Александров | 3 | Отдел маркетинга | Менеджер | Проект B | NULL | 0 | 0
-- 4  | Алексей Алексеев      | 2 | Отдел продаж     | Менеджер | Проект A | Задача 14:..., Задача 1:... | 2 | 4
