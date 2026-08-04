-- ============================================================
-- ADVANCED EXERCISES
-- Topics: Window Functions, CTEs, Self-JOINs, CASE, Date functions
-- ============================================================

-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
select e.first_name,e.last_name, d.name as department_name, e.salary,
       RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
from employees e
join departments d ON e.department_id = d.id;


-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.
select e.first_name, e.last_name, d.name as department_name, e.salary,
       e.salary - AVG(e.salary) OVER (PARTITION BY e.department_id) AS diff_from_avg
from employees e
join departments d ON e.department_id = d.id;


-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.
with ranked_employees AS (
    select e.first_name, e.last_name, d.name as department_name, e.salary,
           RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
    from employees e
    join departments d ON e.department_id = d.id
)
select first_name, last_name, department_name, salary
from ranked_employees
where salary_rank <= 2;

-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.
select sale_date, amount,
       SUM(amount) OVER (ORDER BY sale_date) AS running_total
from sales;


-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).
select e.first_name, e.last_name, e.hire_date,
       LAG(e.hire_date) OVER (ORDER BY e.hire_date) AS previous_hire_date
from employees e;


-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.
with salary_bands AS (
    select first_name, last_name, salary,
           CASE
               WHEN salary < 75000 THEN 'Junior'
               WHEN salary BETWEEN 75000 AND 99999 THEN 'Mid'
               ELSE 'Senior'
           END AS band
    from employees
)
select first_name, last_name, salary, band, 
count(*) over (partition by band) as band_count
from salary_bands;

-- Exercise 7
-- Find the month-over-month sales growth for 2023.
-- Show: month, total_sales, previous_month_sales, and growth percentage.
-- Hint: use LAG and date functions.
with monthly_sales AS (
    select strftime('%Y-%m', sale_date) as month,
           SUM(amount) as total_sales
    from sales
    where strftime('%Y', sale_date) = '2023'
    group by strftime('%Y-%m', sale_date)
)
select month, total_sales,
       LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    round((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month) * 100, 2) AS growth_percentage
from monthly_sales order by month;


-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.
with RECURSIVE management_chain AS (
    select id, first_name, last_name, manager_id
    from employees
    where id = 3
    union all
    select e.id, e.first_name, e.last_name, e.manager_id
    from employees e
    join management_chain mc on e.id = mc.manager_id
)
select * from management_chain;


-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.
select name as project_name, budget,
       round(budget*100.0/ sum(budget) over(),2) as budget_percentage
from projects ;


-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.
SELECT
    first_name || ' ' || last_name AS employee_name,
    hire_date,
    salary
FROM employees
WHERE hire_date <= CURRENT_DATE - INTERVAL '5 years'
  AND salary < (
        SELECT MEDIAN(salary)
        FROM employees
    )
ORDER BY salary;


-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.
with sales_per_rep as (
    select
        e.id,
        e.first_name || ' ' || e.last_name AS employee_name,
        s.region,
        SUM(s.amount) AS total_sales
    from employees e
    join sales s
        ON e.id = s.employee_id
    group by
        e.id,
        employee_name,
        s.region
)
select
    employee_name,
    region,
    total_sales,

    MAX(total_sales) OVER (
        PARTITION BY region
    ) AS region_top_sales,

    MAX(total_sales) OVER (
        PARTITION BY region
    ) - total_sales AS gap

from sales_per_rep

order by region, total_sales DESC;

-- Exercise 12 (Challenge)
-- Write a query that shows, for each department:
--   - Department name
--   - Total headcount
--   - Total salary budget
--   - Number of active projects their employees are on
--   - Average hours logged per employee on projects
WITH dept_hours AS (
    SELECT
        e.department_id,
        SUM(ep.hours_logged) AS total_hours
    FROM employees e
    JOIN employee_projects ep
        ON e.id = ep.employee_id
    GROUP BY e.department_id
),
dept_projects AS (
    SELECT
        e.department_id,
        COUNT(DISTINCT p.id) AS active_projects
    FROM employees e
    JOIN employee_projects ep
        ON e.id = ep.employee_id
    JOIN projects p
        ON ep.project_id = p.id
    WHERE p.status = 'active'
    GROUP BY e.department_id
)
SELECT
    d.name AS department_name,
    COUNT(e.id) AS total_headcount,
    SUM(e.salary) AS total_salary_budget,
    COALESCE(dp.active_projects, 0) AS active_projects,
    ROUND(
        COALESCE(dh.total_hours, 0) * 1.0 / COUNT(e.id),
        2
    ) AS avg_hours_per_employee
FROM departments d
LEFT JOIN employees e
    ON d.id = e.department_id
LEFT JOIN dept_hours dh
    ON d.id = dh.department_id
LEFT JOIN dept_projects dp
    ON d.id = dp.department_id
GROUP BY
    d.id,
    d.name,
    dp.active_projects,
    dh.total_hours
ORDER BY d.name;

-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.
select first_name, last_name, salary,
       NTILE(4) OVER (ORDER BY salary) AS salary_quartile
from employees;


-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.
SELECT
    first_name || ' ' || last_name AS employee_name,
    hire_date,
    date_diff('day', hire_date, CURRENT_DATE) AS days_employed
FROM employees
ORDER BY days_employed DESC;


-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.
WITH high_earners AS (
    SELECT
        id,
        first_name,
        last_name,
        salary
    FROM employees
    WHERE salary > (
        SELECT AVG(salary)
        FROM employees
    )
)
SELECT
    first_name || ' ' || last_name AS employee_name,
    salary,
    ROUND(
        salary * 100.0 /
        (SELECT SUM(salary) FROM employees),
        2
    ) AS salary_bill_percentage
FROM high_earners
ORDER BY salary DESC;

-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).
SELECT DISTINCT
    e.first_name || ' ' || e.last_name AS employee_name,

    FIRST_VALUE(s.sale_date) OVER (
        PARTITION BY e.id
        ORDER BY s.sale_date
    ) AS first_sale_date,

    FIRST_VALUE(s.amount) OVER (
        PARTITION BY e.id
        ORDER BY s.sale_date
    ) AS first_sale_amount,

    LAST_VALUE(s.sale_date) OVER (
        PARTITION BY e.id
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS last_sale_date,

    LAST_VALUE(s.amount) OVER (
        PARTITION BY e.id
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS last_sale_amount

FROM employees e
JOIN sales s
    ON e.id = s.employee_id

ORDER BY employee_name;


-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.
SELECT
    e1.first_name || ' ' || e1.last_name AS employee_1,
    e2.first_name || ' ' || e2.last_name AS employee_2,
    d.name AS department_name,
    e1.hire_date AS hire_date_1,
    e2.hire_date AS hire_date_2
FROM employees e1
JOIN employees e2
    ON e1.department_id = e2.department_id
   AND e1.id < e2.id
JOIN departments d
    ON e1.department_id = d.id
WHERE ABS(
    date_diff('day', e1.hire_date, e2.hire_date)
) <= 183
ORDER BY
    department_name,
    hire_date_1;


-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.
select strftime('%Y-%m', sale_date) as month,
       SUM(amount) as monthly_total,
       AVG(SUM(amount)) OVER (ORDER BY strftime('%Y-%m', sale_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3_months
from sales
where strftime('%Y', sale_date) = '2023'
group by strftime('%Y-%m', sale_date)
order by month;


-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.
SELECT
    e1.first_name || ' ' || e1.last_name AS employee_1,
    e2.first_name || ' ' || e2.last_name AS employee_2,
    d.name AS department_name,
    e1.hire_date AS hire_date_1,
    e2.hire_date AS hire_date_2
FROM employees e1
JOIN employees e2
    ON e1.department_id = e2.department_id
   AND e1.id < e2.id
JOIN departments d
    ON e1.department_id = d.id
WHERE ABS(
    date_diff('day', e1.hire_date, e2.hire_date)
) <= 183
ORDER BY
    department_name,
    hire_date_1;


-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
-- Hint: use PERCENT_RANK().
select first_name, last_name, salary,
       round(PERCENT_RANK() OVER (ORDER BY salary) * 100, 2) as percentile_rank
from employees;


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
WITH project_stats AS (
    SELECT
        employee_id,
        COUNT(project_id) AS num_projects,
        SUM(hours_logged) AS total_hours_logged
    FROM employee_projects
    GROUP BY employee_id
),
sales_stats AS (
    SELECT
        employee_id,
        SUM(amount) AS total_sales_amount
    FROM sales
    GROUP BY employee_id
)
SELECT
    e.first_name || ' ' || e.last_name AS full_name,

    d.name AS department_name,

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
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS salary_rank,

    COALESCE(ps.num_projects, 0) AS num_projects,

    COALESCE(ps.total_hours_logged, 0) AS total_hours_logged,

    COALESCE(ss.total_sales_amount, 0) AS total_sales_amount
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.id
LEFT JOIN employees m
    ON e.manager_id = m.id
LEFT JOIN project_stats ps
    ON e.id = ps.employee_id
LEFT JOIN sales_stats ss
    ON e.id = ss.employee_id
ORDER BY
    d.name,
    salary_rank;