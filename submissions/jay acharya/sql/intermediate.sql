-- ============================================================
-- INTERMEDIATE EXERCISES
-- Topics: JOINs, GROUP BY, HAVING, Aggregates, Subqueries
-- ============================================================

-- Exercise 1
-- Show each employee's full name along with their department name.
SELECT
e.first_name || ' ' || e.last_name AS employee_name,
d.department_name
FROM Employees e
JOIN Departments d
ON e.department_id = d.department_id;


-- Exercise 2
-- Show each employee's full name and their manager's full name.
-- If an employee has no manager, still show their name (with NULL for manager).
SELECT
e.first_name || ' ' || e.last_name AS employee_name,
m.first_name || ' ' || m.last_name AS manager_name
FROM Employees e
LEFT JOIN Employees m
ON e.manager_id = m.employee_id;


-- Exercise 3
-- Find the total number of employees in each department.
-- Show department name and employee count, sorted by count descending.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM Departments d
LEFT JOIN Employees e
    ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;


-- Exercise 4
-- Find the average salary per department.
-- Only show departments where the average salary is above 80,000.
SELECT
    d.department_name,
    AVG(e.salary) AS avg_salary
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING AVG(e.salary) > 80000;


-- Exercise 5
-- Find the highest and lowest salary in the company per job title.
SELECT
    job_title,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM Employees
GROUP BY job_title;


-- Exercise 6
-- Show each project's name and the number of employees assigned to it.
-- Include projects that have no employees assigned.
SELECT
    p.project_name,
    COUNT(ep.employee_id) AS employee_count
FROM Projects p
LEFT JOIN EmployeeProjects ep
    ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name;


-- Exercise 7
-- Find all employees who are assigned to more than one project.
-- Show their name and the number of projects.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(ep.project_id) AS project_count
FROM Employees e
JOIN EmployeeProjects ep
    ON e.employee_id = ep.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(ep.project_id) > 1;


-- Exercise 8
-- Find the total sales amount per sales employee.
-- Show their full name and total sales, sorted by total sales descending.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    SUM(s.amount) AS total_sales
FROM Employees e
JOIN Sales s
    ON e.employee_id = s.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales DESC;


-- Exercise 9
-- Find all employees who earn more than the average salary of their department.
-- Show their name, salary, and department name.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    e.salary,
    d.department_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
WHERE e.salary >
(
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);


-- Exercise 10
-- List all employees who have NOT been assigned to any project.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name
FROM Employees e
LEFT JOIN EmployeeProjects ep
    ON e.employee_id = ep.employee_id
WHERE ep.project_id IS NULL;


-- Exercise 11
-- For each department, show the name of the highest-paid employee.
SELECT
    d.department_name,
    e.first_name || ' ' || e.last_name AS employee_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
WHERE e.salary =
(
    SELECT MAX(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);


-- Exercise 12
-- Find all projects where the total hours logged by all employees exceeds 400.
-- Show project name and total hours.
SELECT
    p.project_name,
    SUM(ep.hours_logged) AS total_hours
FROM Projects p
JOIN EmployeeProjects ep
    ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(ep.hours_logged) > 400;


-- Exercise 13
-- Show each employee's full name, their department name, and their manager's full name.
-- If no manager, show 'No Manager'.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    COALESCE(
        m.first_name || ' ' || m.last_name,
        'No Manager'
    ) AS manager_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
LEFT JOIN Employees m
    ON e.manager_id = m.employee_id;


-- Exercise 14
-- Find the total sales per product.
-- Show product name and total amount, sorted by total amount descending.
SELECT
    p.product_name,
    SUM(s.amount) AS total_sales
FROM Products p
JOIN Sales s
    ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;


-- Exercise 15
-- Find all employees who share the same job title.
-- Show the job title and the names of employees who have it.
-- Exclude job titles held by only one person.
SELECT
    job_title,
    first_name || ' ' || last_name AS employee_name
FROM Employees
WHERE job_title IN
(
    SELECT job_title
    FROM Employees
    GROUP BY job_title
    HAVING COUNT(*) > 1
)
ORDER BY job_title;


-- Exercise 16
-- For each department, show the number of employees hired after 2020.
SELECT
    d.department_name,
    COUNT(*) AS employees_hired_after_2020
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
WHERE EXTRACT(YEAR FROM e.hire_date) > 2020
GROUP BY d.department_name;


-- Exercise 17
-- Find the employee who has logged the most total hours across all projects.
-- Show their name and total hours.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    SUM(ep.hours_logged) AS total_hours
FROM Employees e
JOIN EmployeeProjects ep
    ON e.employee_id = ep.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_hours DESC
FETCH FIRST 1 ROW ONLY;


-- Exercise 18
-- Show each region's total sales and the number of sales transactions.
SELECT
    r.region_name,
    SUM(s.amount) AS total_sales,
    COUNT(*) AS transaction_count
FROM Regions r
JOIN Sales s
    ON r.region_id = s.region_id
GROUP BY r.region_id, r.region_name;


-- Exercise 19
-- Find all employees who are both a manager (someone reports to them)
-- and are assigned to at least one project.
-- Show their name, department, and number of direct reports.
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    COUNT(DISTINCT r.employee_id) AS direct_reports
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
JOIN Employees r
    ON r.manager_id = e.employee_id
JOIN EmployeeProjects ep
    ON e.employee_id = ep.employee_id
GROUP BY e.employee_id,
         e.first_name,
         e.last_name,
         d.department_name;


-- Exercise 20
-- List each project with its total budget vs total hours logged.
-- Show: project name, budget, total_hours, and cost_per_hour
-- (assume cost_per_hour = budget / total_hours, rounded to 2 decimal places).
SELECT
    p.project_name,
    p.budget,
    SUM(ep.hours_logged) AS total_hours,
    ROUND(
        p.budget / NULLIF(SUM(ep.hours_logged), 0),
        2
    ) AS cost_per_hour
FROM Projects p
LEFT JOIN EmployeeProjects ep
    ON p.project_id = ep.project_id
GROUP BY p.project_id,
         p.project_name,
         p.budget;


-- Exercise 21
-- Find the top-selling product in each region.
-- Show: region, product, and total sales amount.
WITH product_sales AS
(
    SELECT
        r.region_name,
        p.product_name,
        SUM(s.amount) AS total_sales,
        RANK() OVER (
            PARTITION BY r.region_name
            ORDER BY SUM(s.amount) DESC
        ) AS rnk
    FROM Sales s
    JOIN Regions r
        ON s.region_id = r.region_id
    JOIN Products p
        ON s.product_id = p.product_id
    GROUP BY r.region_name, p.product_name
)
SELECT
    region_name,
    product_name,
    total_sales
FROM product_sales
WHERE rnk = 1;


-- Exercise 22
-- Show all employees who joined in the same year as at least one other employee
-- from a different department.
-- Show their name, department name, and hire year.
SELECT DISTINCT
    e1.first_name || ' ' || e1.last_name AS employee_name,
    d.department_name,
    EXTRACT(YEAR FROM e1.hire_date) AS hire_year
FROM Employees e1
JOIN Employees e2
    ON EXTRACT(YEAR FROM e1.hire_date) =
       EXTRACT(YEAR FROM e2.hire_date)
   AND e1.department_id <> e2.department_id
   AND e1.employee_id <> e2.employee_id
JOIN Departments d
    ON e1.department_id = d.department_id;

