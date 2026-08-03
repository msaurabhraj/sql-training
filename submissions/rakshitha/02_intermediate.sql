-- ============================================================
-- INTERMEDIATE EXERCISES
-- Topics: JOINs, GROUP BY, HAVING, Aggregates, Subqueries
-- ============================================================

-- Exercise 1
-- Show each employee's full name along with their department name.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.name AS department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.id;

-- Exercise 2
-- Show each employee's full name and their manager's full name.
-- If an employee has no manager, still show their name (with NULL for manager).
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.id;

-- Exercise 3
-- Find the total number of employees in each department.
-- Show department name and employee count, sorted by count descending.
SELECT
    d.name AS department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY employee_count DESC;

-- Exercise 4
-- Find the average salary per department.
-- Only show departments where the average salary is above 80,000.
SELECT
    d.name AS department_name,
    AVG(e.salary) AS average_salary
FROM departments d
JOIN employees e
    ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING AVG(e.salary) > 80000
ORDER BY average_salary DESC;

-- Exercise 5
-- Find the highest and lowest salary in the company per job title.
SELECT
    job_title,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY job_title
ORDER BY job_title;

-- Exercise 6
-- Show each project's name and the number of employees assigned to it.
-- Include projects that have no employees assigned.
SELECT
    p.name AS project_name,
    COUNT(ep.employee_id) AS employee_count
FROM projects p
LEFT JOIN employee_projects ep
    ON p.id = ep.project_id
GROUP BY p.id, p.name
ORDER BY p.name;

-- Exercise 7
-- Find all employees who are assigned to more than one project.
-- Show their name and the number of projects.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep
    ON e.id = ep.employee_id
GROUP BY e.id, e.first_name, e.last_name
HAVING COUNT(ep.project_id) > 1
ORDER BY project_count DESC, employee_name;

-- Exercise 8
-- Find the total sales amount per sales employee.
-- Show their full name and total sales, sorted by total sales descending.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    SUM(s.amount) AS total_sales_amount
FROM employees e
JOIN sales s
    ON e.id = s.employee_id
GROUP BY e.id, e.first_name, e.last_name
ORDER BY total_sales_amount DESC;

-- Exercise 9
-- Find all employees who earn more than the average salary of their department.
-- Show their name, salary, and department name.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.salary,
    d.name AS department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.salary DESC;

-- Exercise 10
-- List all employees who have NOT been assigned to any project.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM employees e
LEFT JOIN employee_projects ep
    ON e.id = ep.employee_id
WHERE ep.employee_id IS NULL
ORDER BY employee_name;

-- Exercise 11
-- For each department, show the name of the highest-paid employee.
SELECT
    d.name AS department_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM departments d
JOIN employees e
    ON d.id = e.department_id
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = d.id
)
ORDER BY d.name;

-- Exercise 12
-- Find all projects where the total hours logged by all employees exceeds 400.
-- Show project name and total hours.
SELECT
    p.name AS project_name,
    SUM(ep.hours_logged) AS total_hours
FROM projects p
JOIN employee_projects ep
    ON p.id = ep.project_id
GROUP BY p.id, p.name
HAVING SUM(ep.hours_logged) > 400
ORDER BY total_hours DESC;

-- Exercise 13
-- Show each employee's full name, their department name, and their manager's full name.
-- If no manager, show 'No Manager'.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.name AS department_name,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'No Manager') AS manager_name
FROM employees e
JOIN departments d
    ON e.department_id = d.id
LEFT JOIN employees m
    ON e.manager_id = m.id;

-- Exercise 14
-- Find the total sales per product.
-- Show product name and total amount, sorted by total amount descending.
SELECT
    s.product,
    SUM(s.amount) AS total_amount
FROM sales s
GROUP BY s.product
ORDER BY total_amount DESC;

-- Exercise 15
-- Find all employees who share the same job title.
-- Show the job title and the names of employees who have it.
-- Exclude job titles held by only one person.
SELECT
    job_title,
    CONCAT(first_name, ' ', last_name) AS employee_name
FROM employees
WHERE job_title IN (
    SELECT job_title
    FROM employees
    GROUP BY job_title
    HAVING COUNT(*) > 1
)
ORDER BY job_title, employee_name;

-- Exercise 16
-- For each department, show the number of employees hired after 2020.
SELECT
    d.name AS department_name,
    COUNT(e.id) AS employee_count
FROM departments d
JOIN employees e
    ON d.id = e.department_id
WHERE e.hire_date > '2020-12-31'
GROUP BY d.id, d.name
ORDER BY employee_count DESC;

-- Exercise 17
-- Find the employee who has logged the most total hours across all projects.
-- Show their name and total hours.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    SUM(ep.hours_logged) AS total_hours
FROM employees e
JOIN employee_projects ep
    ON e.id = ep.employee_id
GROUP BY e.id, e.first_name, e.last_name
ORDER BY total_hours DESC
LIMIT 1;

-- Exercise 18
-- Show each region's total sales and the number of sales transactions.
SELECT
    region,
    SUM(amount) AS total_sales,
    COUNT(*) AS sales_transactions
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- Exercise 19
-- Find all employees who are both a manager (someone reports to them)
-- and are assigned to at least one project.
-- Show their name, department, and number of direct reports.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.name AS department_name,
    COUNT(DISTINCT r.id) AS direct_reports
FROM employees e
JOIN departments d
    ON e.department_id = d.id
JOIN employee_projects ep
    ON e.id = ep.employee_id
JOIN employees r
    ON r.manager_id = e.id
GROUP BY e.id, e.first_name, e.last_name, d.name
ORDER BY direct_reports DESC, employee_name;

-- Exercise 20
-- List each project with its total budget vs total hours logged.
-- Show: project name, budget, total_hours, and cost_per_hour
-- (assume cost_per_hour = budget / total_hours, rounded to 2 decimal places).
SELECT
    p.name AS project_name,
    p.budget,
    SUM(ep.hours_logged) AS total_hours,
    CASE
        WHEN SUM(ep.hours_logged) = 0 THEN NULL
        ELSE ROUND(p.budget / SUM(ep.hours_logged), 2)
    END AS cost_per_hour
FROM projects p
LEFT JOIN employee_projects ep
    ON p.id = ep.project_id
GROUP BY p.id, p.name, p.budget
ORDER BY p.name;

-- Exercise 21
-- Find the top-selling product in each region.
-- Show: region, product, and total sales amount.
SELECT
    region,
    product,
    total_sales_amount
FROM (
    SELECT
        s.region,
        s.product,
        SUM(s.amount) AS total_sales_amount,
        ROW_NUMBER() OVER (
            PARTITION BY s.region
            ORDER BY SUM(s.amount) DESC
        ) AS rn
    FROM sales s
    GROUP BY s.region, s.product
) ranked
WHERE rn = 1
ORDER BY region;

-- Exercise 22
-- Show all employees who joined in the same year as at least one other employee
-- from a different department.
-- Show their name, department name, and hire year.
SELECT
    CONCAT(e1.first_name, ' ', e1.last_name) AS employee_name,
    d.name AS department_name,
    EXTRACT(YEAR FROM e1.hire_date) AS hire_year
FROM employees e1
JOIN departments d
    ON e1.department_id = d.id
WHERE EXISTS (
    SELECT 1
    FROM employees e2
    WHERE EXTRACT(YEAR FROM e2.hire_date) = EXTRACT(YEAR FROM e1.hire_date)
      AND e2.department_id <> e1.department_id
)
ORDER BY hire_year, employee_name;
