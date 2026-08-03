-- ============================================================
-- ADVANCED EXERCISES
-- Topics: Window Functions, CTEs, Self-JOINs, CASE, Date functions
-- ============================================================

-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
SELECT
    d.name AS department,
    e.salary,
    e.first_name || ' ' || e.last_name AS name,
    RANK()
        OVER (PARTITION BY e.department_id ORDER BY e.salary DESC)
        AS salary_rank
FROM employees AS e
INNER JOIN departments AS d ON e.department_id = d.id
ORDER BY d.name, salary_rank;

-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.
SELECT
    e.salary,
    e.first_name || ' ' || e.last_name AS name,
    e.salary
    - AVG(e.salary) OVER (PARTITION BY e.department_id) AS diff_from_avg
FROM employees AS e
ORDER BY name;

-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.
WITH dept_ranked AS (
    SELECT
        e.id,
        d.name AS department,
        e.salary,
        e.first_name || ' ' || e.last_name AS name,
        ROW_NUMBER()
            OVER (PARTITION BY e.department_id ORDER BY e.salary DESC)
            AS rn
    FROM employees AS e
    INNER JOIN departments AS d ON e.department_id = d.id
)

SELECT
    id,
    name,
    department,
    salary
FROM dept_ranked
WHERE rn <= 2
ORDER BY department ASC, salary DESC;

-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.
SELECT
    sale_date,
    amount,
    SUM(amount)
        OVER (
            ORDER BY sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        AS running_total
FROM sales
ORDER BY sale_date;

-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).
SELECT
    hire_date,
    first_name || ' ' || last_name AS name,
    LAG(hire_date) OVER (ORDER BY hire_date) AS previous_hire_date
FROM employees
ORDER BY hire_date;

-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.
SELECT
    salary,
    first_name || ' ' || last_name AS name,
    CASE
        WHEN salary < 75000 THEN 'Junior'
        WHEN salary < 100000 THEN 'Mid'
        ELSE 'Senior'
    END AS band,
    COUNT(*) OVER (PARTITION BY CASE
        WHEN salary < 75000 THEN 'Junior'
        WHEN salary < 100000 THEN 'Mid'
        ELSE 'Senior'
    END) AS band_count
FROM employees
ORDER BY band ASC, salary DESC;

-- Exercise 7
-- Find the month-over-month sales growth for 2023.
-- Show: month, total_sales, previous_month_sales, and growth percentage.
SELECT
    month,
    total_sales,
    previous_month_sales,
    CASE
        WHEN previous_month_sales IS NULL THEN NULL
        ELSE
            ROUND(
                (total_sales - previous_month_sales)
                * 100.0
                / previous_month_sales,
                2
            )
    END AS growth_percentage
FROM (
    SELECT
        STRFTIME('%Y-%m', sale_date) AS month,
        SUM(amount) AS total_sales,
        LAG(SUM(amount))
            OVER (ORDER BY STRFTIME('%Y-%m', sale_date))
            AS previous_month_sales
    FROM sales
    WHERE sale_date BETWEEN DATE '2023-01-01' AND DATE '2023-12-31'
    GROUP BY STRFTIME('%Y-%m', sale_date)
) AS q
ORDER BY month;

-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.
WITH RECURSIVE management_chain AS (
    SELECT
        id,
        first_name || ' ' || last_name AS employee_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE id = 3

    UNION ALL

    SELECT
        m.id,
        m.first_name || ' ' || m.last_name AS employee_name,
        m.manager_id,
        c.level + 1
    FROM management_chain AS c
    INNER JOIN employees AS m ON c.manager_id = m.id
)

SELECT
    c.level,
    c.employee_name AS employee,
    COALESCE(m.first_name || ' ' || m.last_name, 'No Manager') AS manager_name
FROM management_chain AS c
LEFT JOIN employees AS m ON c.manager_id = m.id
ORDER BY c.level;

-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.
SELECT
    p.name AS project_name,
    p.budget,
    ROUND(p.budget * 100.0 / SUM(p.budget) OVER (), 2) AS budget_percentage
FROM projects AS p
ORDER BY p.name;

-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.
SELECT
    hire_date,
    salary,
    first_name || ' ' || last_name AS name
FROM employees
WHERE
    hire_date <= CURRENT_DATE - INTERVAL '5 years'
    AND salary < (SELECT MEDIAN(salary) FROM employees)
ORDER BY hire_date;

-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.
SELECT
    q.region,
    q.total_sales,
    q.region_top_sales,
    e.first_name || ' ' || e.last_name AS name,
    q.region_top_sales - q.total_sales AS gap
FROM (
    SELECT
        employee_id,
        region,
        SUM(amount) AS total_sales,
        MAX(SUM(amount)) OVER (PARTITION BY region) AS region_top_sales
    FROM sales
    GROUP BY employee_id, region
) AS q
INNER JOIN employees AS e ON q.employee_id = e.id
ORDER BY q.region ASC, q.total_sales DESC;

-- Exercise 12 (Challenge)
-- Write a query that shows, for each department:
--   - Department name
--   - Total headcount
--   - Total salary budget
--   - Number of active projects their employees are on
--   - Average hours logged per employee on projects
SELECT
    d.name AS department_name,
    COUNT(DISTINCT e.id) AS total_headcount,
    COALESCE(SUM(e.salary), 0) AS total_salary_budget,
    COUNT(DISTINCT CASE WHEN p.status = 'active' THEN p.id END)
        AS active_project_count,
    ROUND(
        COALESCE(SUM(ep.hours_logged), 0)
        * 1.0
        / NULLIF(COUNT(DISTINCT e.id), 0),
        2
    ) AS avg_hours_per_employee
FROM departments AS d
LEFT JOIN employees AS e ON d.id = e.department_id
LEFT JOIN employee_projects AS ep ON e.id = ep.employee_id
LEFT JOIN projects AS p ON ep.project_id = p.id
GROUP BY d.id, d.name
ORDER BY d.name;

-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.
SELECT
    salary,
    first_name || ' ' || last_name AS name,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM employees
ORDER BY salary_quartile, salary;

-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.
SELECT
    hire_date,
    first_name || ' ' || last_name AS name,
    DATE_DIFF('day', hire_date, CURRENT_DATE) AS days_employed
FROM employees
ORDER BY hire_date;

-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.
WITH high_earners AS (
    SELECT
        id,
        salary,
        first_name || ' ' || last_name AS name
    FROM employees
    WHERE salary > (SELECT AVG(salary) FROM employees)
)

SELECT
    name,
    salary,
    ROUND(
        SUM(salary) OVER () * 100.0 / (SELECT SUM(salary) FROM employees), 2
    ) AS pct_of_total_salary_bill
FROM high_earners
ORDER BY salary DESC;

-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).
WITH ranked_sales AS (
    SELECT
        s.employee_id,
        s.sale_date,
        s.amount,
        e.first_name || ' ' || e.last_name AS name,
        ROW_NUMBER()
            OVER (PARTITION BY s.employee_id ORDER BY s.sale_date ASC)
            AS rn_first,
        ROW_NUMBER()
            OVER (PARTITION BY s.employee_id ORDER BY s.sale_date DESC)
            AS rn_last
    FROM sales AS s
    INNER JOIN employees AS e ON s.employee_id = e.id
)

SELECT
    employee_id,
    name,
    MAX(CASE WHEN rn_first = 1 THEN sale_date END) AS first_sale_date,
    MAX(CASE WHEN rn_first = 1 THEN amount END) AS first_sale_amount,
    MAX(CASE WHEN rn_last = 1 THEN sale_date END) AS last_sale_date,
    MAX(CASE WHEN rn_last = 1 THEN amount END) AS last_sale_amount
FROM ranked_sales
GROUP BY employee_id, name
ORDER BY name;

-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.
SELECT
    d.name AS department,
    e1.hire_date AS hire_date_1,
    e2.hire_date AS hire_date_2,
    e1.first_name || ' ' || e1.last_name AS employee_1,
    e2.first_name || ' ' || e2.last_name AS employee_2
FROM employees AS e1
INNER JOIN employees AS e2
    ON
        e1.department_id = e2.department_id
        AND e1.id < e2.id
        AND e1.hire_date BETWEEN e2.hire_date
        - INTERVAL '6 months' AND e2.hire_date
        + INTERVAL '6 months'
INNER JOIN departments AS d ON e1.department_id = d.id
ORDER BY department, hire_date_1, hire_date_2;

-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.
WITH monthly_sales AS (
    SELECT
        STRFTIME('%Y-%m', sale_date) AS month,
        SUM(amount) AS monthly_total
    FROM sales
    WHERE sale_date BETWEEN DATE '2023-01-01' AND DATE '2023-12-31'
    GROUP BY STRFTIME('%Y-%m', sale_date)
)

SELECT
    month,
    monthly_total,
    ROUND(
        AVG(monthly_total)
            OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
        2
    ) AS rolling_avg_3_months
FROM monthly_sales
ORDER BY month;

-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.
WITH overdue_projects AS (
    SELECT
        ep.employee_id,
        p.name AS project_name,
        p.end_date
    FROM employee_projects AS ep
    INNER JOIN projects AS p ON ep.project_id = p.id
    WHERE
        p.status = 'active'
        AND p.end_date IS NOT NULL
        AND p.end_date < CURRENT_DATE
)

SELECT
    op.project_name,
    op.end_date AS planned_end_date,
    e.first_name || ' ' || e.last_name AS employee_name
FROM overdue_projects AS op
INNER JOIN employees AS e ON op.employee_id = e.id
ORDER BY planned_end_date;

-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
SELECT
    salary,
    first_name || ' ' || last_name AS name,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 2) AS percentile_rank
FROM employees
ORDER BY salary;

-- Exercise 21 (Challenge)
-- Build a full employee summary report. For each employee show:
--   - Full name
--   - Department name
--   - Manager name (or 'No Manager')
--   - Salary band (Junior / Mid / Senior)
--   - Salary rank within their department
--   - Number of projects they are on
--   - Total hours logged across all projects
--   - Total sales amount (0 if not in sales)
-- Order by department name, then salary rank.
WITH project_summary AS (
    SELECT
        employee_id,
        COUNT(DISTINCT project_id) AS project_count,
        SUM(hours_logged) AS total_hours
    FROM employee_projects
    GROUP BY employee_id
),

sales_summary AS (
    SELECT
        employee_id,
        SUM(amount) AS total_sales
    FROM sales
    GROUP BY employee_id
)

SELECT
    d.name AS department_name,
    e.first_name || ' ' || e.last_name AS full_name,
    COALESCE(m.first_name || ' ' || m.last_name, 'No Manager') AS manager_name,
    CASE
        WHEN e.salary < 75000 THEN 'Junior'
        WHEN e.salary < 100000 THEN 'Mid'
        ELSE 'Senior'
    END AS salary_band,
    RANK()
        OVER (PARTITION BY e.department_id ORDER BY e.salary DESC)
        AS salary_rank,
    COALESCE(ps.project_count, 0) AS num_projects,
    COALESCE(ps.total_hours, 0) AS total_hours,
    COALESCE(ss.total_sales, 0) AS total_sales
FROM employees AS e
LEFT JOIN departments AS d ON e.department_id = d.id
LEFT JOIN employees AS m ON e.manager_id = m.id
LEFT JOIN project_summary AS ps ON e.id = ps.employee_id
LEFT JOIN sales_summary AS ss ON e.id = ss.employee_id
ORDER BY department_name, salary_rank;
