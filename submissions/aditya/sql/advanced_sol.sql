-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
SELECT
    e.first_name,
    e.last_name,
    d.name AS department_name,
    e.salary,
    RANK() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS salary_rank
FROM employees AS e
INNER JOIN departments AS d
    ON e.department_id = d.id;


-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.

SELECT
    e.first_name,
    e.last_name,
    e.salary,
    AVG(e.salary) OVER (
        PARTITION BY e.department_id
    ) AS dept_avg,
    e.salary
    - AVG(e.salary) OVER (
        PARTITION BY e.department_id
    ) AS diff_from_avg
FROM employees AS e;


-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.

WITH ranked_employees AS (
    SELECT
        e.first_name,
        e.last_name,
        d.name AS department_name,
        e.salary,
        ROW_NUMBER() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        ) AS rn
    FROM employees AS e
    INNER JOIN departments AS d
        ON e.department_id = d.id
)

SELECT *
FROM ranked_employees
WHERE rn <= 2;


-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.


SELECT
    sale_date,
    amount,
    SUM(amount) OVER (
        ORDER BY sale_date
    ) AS running_total
FROM sales;


-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).

SELECT
    first_name,
    last_name,
    hire_date,
    LAG(hire_date) OVER (
        ORDER BY hire_date
    ) AS previous_hire_date
FROM employees;


-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.

SELECT
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary < 75000 THEN 'Junior'
        WHEN salary BETWEEN 75000 AND 99999 THEN 'Mid'
        ELSE 'Senior'
    END AS band
FROM employees;

SELECT
    CASE
        WHEN salary < 75000 THEN 'Junior'
        WHEN salary BETWEEN 75000 AND 99999 THEN 'Mid'
        ELSE 'Senior'
    END AS band,
    COUNT(*) AS employee_count
FROM employees
GROUP BY band;


-- Exercise 7
-- Find the month-over-month sales growth for 2023.
-- Show: month, total_sales, previous_month_sales, and growth percentage.
-- Hint: use LAG and date functions.


WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(amount) AS total_sales
    FROM sales
    GROUP BY DATE_TRUNC('month', sale_date)
)

SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales,
    ROUND(
        (
            total_sales
            - LAG(total_sales) OVER (ORDER BY month)
        )
        * 100.0
        /
        LAG(total_sales) OVER (ORDER BY month),
        2
    ) AS growth_percentage
FROM monthly_sales;


-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.

WITH RECURSIVE management_chain AS (
    SELECT
        id,
        first_name,
        last_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE id = 3

    UNION ALL

    SELECT
        e.id,
        e.first_name,
        e.last_name,
        e.manager_id,
        mc.level + 1
    FROM employees AS e
    INNER JOIN management_chain AS mc
        ON e.id = mc.manager_id
)

SELECT *
FROM management_chain;


-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.

SELECT
    name AS project_name,
    budget,
    ROUND(
        budget * 100.0
        / SUM(budget) OVER (),
        2
    ) AS budget_percentage
FROM projects;


-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.

SELECT
    first_name,
    last_name,
    hire_date,
    salary
FROM employees
WHERE
    hire_date <= CURRENT_DATE - INTERVAL '5 years'
    AND salary
    < (
        SELECT AVG(salary)
        FROM employees
    );


-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.

WITH rep_sales AS (
    SELECT
        e.first_name,
        e.last_name,
        s.region,
        SUM(s.amount) AS total_sales
    FROM employees AS e
    INNER JOIN sales AS s
        ON e.id = s.employee_id
    GROUP BY
        e.id,
        e.first_name,
        e.last_name,
        s.region
)

SELECT
    first_name,
    last_name,
    region,
    total_sales,
    MAX(total_sales) OVER (
        PARTITION BY region
    ) AS region_top_sales,
    MAX(total_sales) OVER (
        PARTITION BY region
    ) - total_sales AS gap
FROM rep_sales;


-- Exercise 12 (Challenge)
-- Write a query that shows, for each department:
--   - Department name
--   - Total headcount
--   - Total salary budget
--   - Number of active projects their employees are on
--   - Average hours logged per employee on projects

SELECT
    d.name AS department_name,
    COUNT(DISTINCT e.id) AS headcount,
    SUM(e.salary) AS total_salary_budget,
    COUNT(DISTINCT ep.project_id) AS active_projects,
    AVG(ep.hours_logged) AS avg_hours_logged
FROM departments AS d
INNER JOIN employees AS e
    ON d.id = e.department_id
LEFT JOIN employee_projects AS ep
    ON e.id = ep.employee_id
GROUP BY d.id, d.name;


-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.

SELECT
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (
        ORDER BY salary
    ) AS salary_quartile
FROM employees;


-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.

SELECT
    first_name,
    last_name,
    hire_date,
    CURRENT_DATE - hire_date AS days_employed
FROM employees;


-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.

WITH above_avg AS (
    SELECT *
    FROM employees
    WHERE
        salary
        > (
            SELECT AVG(salary)
            FROM employees
        )
)

SELECT
    first_name,
    last_name,
    salary,
    ROUND(
        salary * 100.0
        / (
            SELECT SUM(salary)
            FROM employees
        ),
        2
    ) AS salary_bill_percentage
FROM above_avg;


-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).

WITH sales_ranked AS (
    SELECT
        employee_id,
        sale_date,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY sale_date
        ) AS first_sale,

        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY sale_date DESC
        ) AS last_sale
    FROM sales
)

SELECT *
FROM sales_ranked;


-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.

SELECT
    e1.first_name,
    e1.last_name,
    e2.first_name,
    e2.last_name,
    d.name AS department_name,
    e1.hire_date,
    e2.hire_date
FROM employees AS e1
INNER JOIN employees AS e2
    ON
        e1.department_id = e2.department_id
        AND e1.id < e2.id
INNER JOIN departments AS d
    ON e1.department_id = d.id
WHERE ABS(
    DATE_DIFF('day', e1.hire_date, e2.hire_date)
) <= 180;


-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(amount) AS monthly_total
    FROM sales
    GROUP BY DATE_TRUNC('month', sale_date)
)

SELECT
    month,
    monthly_total,
    AVG(monthly_total) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
    ) AS rolling_avg_3_months
FROM monthly_sales;


-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.

WITH overdue_projects AS (
    SELECT *
    FROM projects
    WHERE
        end_date < CURRENT_DATE
        AND status = 'active'
)

SELECT
    e.first_name,
    e.last_name,
    p.name AS project_name,
    p.end_date
FROM employees AS e
INNER JOIN employee_projects AS ep
    ON e.id = ep.employee_id
INNER JOIN overdue_projects AS p
    ON ep.project_id = p.id;


-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
-- Hint: use PERCENT_RANK().

SELECT
    first_name,
    last_name,
    salary,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY salary
        ),
        2
    ) AS percentile_rank
FROM employees;


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

SELECT
    d.name AS department_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(
        m.first_name || ' ' || m.last_name,
        'No Manager'
    ) AS manager_name,

    CASE
        WHEN e.salary < 75000 THEN 'Junior'
        WHEN e.salary BETWEEN 75000 AND 99999 THEN 'Mid'
        ELSE 'Senior'
    END AS salary_band,

    RANK() OVER (
        PARTITION BY d.id
        ORDER BY e.salary DESC
    ) AS salary_rank,

    COUNT(DISTINCT ep.project_id) AS project_count,

    COALESCE(
        SUM(ep.hours_logged),
        0
    ) AS total_hours_logged,

    COALESCE(
        SUM(s.amount),
        0
    ) AS total_sales

FROM employees AS e
INNER JOIN departments AS d
    ON e.department_id = d.id

LEFT JOIN employees AS m
    ON e.manager_id = m.id

LEFT JOIN employee_projects AS ep
    ON e.id = ep.employee_id

LEFT JOIN sales AS s
    ON e.id = s.employee_id

GROUP BY
    e.id,
    e.first_name,
    e.last_name,
    d.id,
    d.name,
    m.first_name,
    m.last_name,
    e.salary

ORDER BY
    d.name,
    salary_rank;
