-- ============================================================
-- ADVANCED EXERCISES
-- Topics: Window Functions, CTEs, Self-JOINs, CASE, Date functions
-- ============================================================

-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
   SELECT
  first_name || ''|| last_name AS name, department_id, salary,
RANK() OVER(
PARTITION BY department_id
ORDER BY salary desc) AS salary_rank
FROM employees;



-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.
     SELECT
first_name || ' ' || last_name AS name, salary, 
AVG(salary) OVER(PARTITION BY department_id) AS dept_avg,
salary -
AVG(salary) OVER(PARTITION BY department_id) AS diff_from_avg
FROM employees;



-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.
   WITH ranked_employees AS (
    SELECT
        first_name || ' ' || last_name AS name,
        department_id,
        salary,
        ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
    FROM employees
)
SELECT name, department_id, salary
FROM ranked_employees
WHERE salary_rank <= 2;



-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.
   select SUM(amount) OVER(ORDER BY sale_date) as running_total from sales;


-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).
   SELECT 
   first_name ||' '|| last_name AS name, hire_date,
LAG(hire_date) OVER(ORDER BY hire_date asc) AS previous_hire_date
FROM employees;


-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.
   SELECT
       first_name || ' ' || last_name AS name,
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
    WHERE EXTRACT(YEAR FROM sale_date) = 2023
    GROUP BY DATE_TRUNC('month', sale_date)
)

SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    ROUND(
        (
            (total_sales - LAG(total_sales) OVER (ORDER BY month))
            / LAG(total_sales) OVER (ORDER BY month)
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY month;


-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.
   WITH RECURSIVE management_chain AS (
    SELECT
        id,
        first_name || ' ' || last_name AS name,
        manager_id,
        1 AS level
    FROM employees
    WHERE id = 3

    UNION ALL

    SELECT
        e.id,
        e.first_name || ' ' || e.last_name AS name,
        e.manager_id,
        mc.level + 1
    FROM employees e
    JOIN management_chain mc ON e.id = mc.manager_id
)

SELECT
    id,
    name,
    manager_id,
    level
FROM management_chain
ORDER BY level;

-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.
   select name, budget, ROUND((budget / (select sum(budget) from projects)) * 100, 2) as budget_percentage from projects;



-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.
   select first_name || ' ' || last_name AS name, hire_date, salary from employees where hire_date < (current_date - interval '5 years') and salary < (select percentile_cont(0.5) within group (order by salary) from employees);


-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.
   SELECT
       e.first_name || ' ' || e.last_name AS name,
       s.region,
       SUM(s.amount) AS total_sales,
       MAX(SUM(s.amount)) OVER(PARTITION BY s.region) AS region_top_sales,
       MAX(SUM(s.amount)) OVER(PARTITION BY s.region) - SUM(s.amount) AS gap
   FROM employees e
   JOIN sales s ON e.id = s.employee_id
   GROUP BY e.first_name, e.last_name, s.region;

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
    SUM(e.salary) AS total_salary_budget,
    COUNT(DISTINCT CASE
        WHEN p.status = 'active'
        THEN p.id
    END) AS active_projects,
    AVG(ep.hours_logged) AS average_hours_logged
FROM departments d
LEFT JOIN employees e
    ON d.id = e.department_id
LEFT JOIN employee_projects ep
    ON e.id = ep.employee_id
LEFT JOIN projects p
    ON ep.project_id = p.id
GROUP BY d.name;

-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.
  SELECT
    first_name || ' ' || last_name AS name,
    salary,
    NTILE(4) OVER (
        ORDER BY salary
    ) AS salary_quartile
FROM employees
ORDER BY salary_quartile;

  

-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.
   SELECT first_name || ' ' || last_name AS name,
       hire_date,
       (current_date - hire_date) AS days_employed
   FROM employees;

-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.
  WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal
    FROM employees
),
total_salary AS (
    SELECT SUM(salary) AS total_sal
    FROM employees
)

SELECT
    e.first_name || ' ' || e.last_name AS name,
    e.salary,
    ROUND(
        (e.salary / ts.total_sal) * 100,
        2
    ) AS percentage_of_total_salary
FROM employees e
CROSS JOIN avg_salary a
CROSS JOIN total_salary ts
WHERE e.salary > a.avg_sal;

-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).
    SELECT DISTINCT
    e.first_name || ' ' || e.last_name AS name,

    FIRST_VALUE(s.sale_date)
        OVER (
            PARTITION BY e.id
            ORDER BY s.sale_date
        ) AS first_sale_date,

    FIRST_VALUE(s.amount)
        OVER (
            PARTITION BY e.id
            ORDER BY s.sale_date
        ) AS first_sale_amount,

    LAST_VALUE(s.sale_date)
        OVER (
            PARTITION BY e.id
            ORDER BY s.sale_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS last_sale_date,

    LAST_VALUE(s.amount)
        OVER (
            PARTITION BY e.id
            ORDER BY s.sale_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS last_sale_amount

FROM employees e
JOIN sales s
ON e.id = s.employee_id;

-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.
   SELECT
       e1.first_name || ' ' || e1.last_name AS employee1,
       e2.first_name || ' ' || e2.last_name AS employee2,
       d.name AS department,
       e1.hire_date AS hire_date1,
       e2.hire_date AS hire_date2
   FROM employees e1
   JOIN employees e2 ON e1.department_id = e2.department_id AND e1.id < e2.id
   JOIN departments d ON e1.department_id = d.id
   WHERE ABS(DATEDIFF('day', e1.hire_date, e2.hire_date)) <= 183
   ORDER BY d.name, e1.hire_date, e2.hire_date;

-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.
   select DATE_TRUNC('month', sale_date) AS month,
       SUM(amount) AS monthly_total,
       AVG(SUM(amount)) OVER(ORDER BY DATE_TRUNC('month', sale_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3_months
from sales
where EXTRACT(YEAR FROM sale_date) = 2023
group by DATE_TRUNC('month', sale_date);
       


-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.
   SELECT DISTINCT
       e.first_name || ' ' || e.last_name AS employee_name,
       p.name AS project_name,
       p.end_date AS planned_end_date
   FROM employees e
   JOIN employee_projects ep ON e.id = ep.employee_id
   JOIN projects p ON ep.project_id = p.id
   WHERE p.end_date < CURRENT_DATE
     AND p.status = 'active';

-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
-- Hint: use PERCENT_RANK().
   select first_name || ' ' || last_name AS name, salary,
ROUND(PERCENT_RANK() OVER(ORDER BY salary) * 100, 2) AS percentile_rank
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
  select e.first_name || ' ' || e.last_name AS full_name,
       d.name AS department_name,
       COALESCE(m.first_name || ' ' || m.last_name, 'No Manager') AS manager_name,
       CASE
           WHEN e.salary < 75000 THEN 'Junior'
           WHEN e.salary BETWEEN 75000 AND 99999 THEN 'Mid'
           ELSE 'Senior'
       END AS salary_band,
       RANK() OVER(PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank,
       COUNT(ep.project_id) AS number_of_projects,
       COALESCE(SUM(ep.hours_logged), 0) AS total_hours_logged,
       COALESCE(SUM(s.amount), 0) AS total_sales_amount
from employees e
left join departments d on e.department_id = d.id
left join employees m on e.manager_id = m.id
left join employee_projects ep on e.id = ep.employee_id
left join sales s on e.id = s.employee_id
group by e.id, d.name, m.first_name, m.last_name
order by d.name, salary_rank;
