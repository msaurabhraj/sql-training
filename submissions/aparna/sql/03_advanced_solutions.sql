-- ============================================================
-- ADVANCED EXERCISES
-- Topics: Window Functions, CTEs, Self-JOINs, CASE, Date functions
-- ============================================================

-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
--Solution:
select
    e.first_name,
    e.last_name,
    d.name,
    e.salary,
    row_number() over (partition by d.name order by e.salary desc) as rank
from employees as e inner join departments as d
    on e.department_id = d.id;

-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.
--Solution:
select
    e.first_name,
    e.last_name,
    d.name as department,
    e.salary,
    abs(e.salary - avg(e.salary) over (partition by e.department_id))
        as diff_from_avg
from employees as e
inner join departments as d
    on e.department_id = d.id;

-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.
--Solution:
with ranked_employees as (
    select
        e.first_name,
        e.last_name,
        d.name,
        e.salary,
        row_number() over (partition by d.name order by e.salary desc) as rank
    from employees as e inner join departments as d
        on e.department_id = d.id
)

select
    first_name,
    last_name,
    name,
    salary
from ranked_employees
where rank <= 2;


-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.
--Solution:
select
    sale_date,
    amount,
    sum(amount) over (order by sale_date) as running_total
from sales;


-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).

--Solution:
select
    e.first_name,
    e.last_name,
    e.hire_date,
    lag(e.hire_date) over (order by e.hire_date) as previous_hire_date
from employees as e;


-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.

--Solution:
select
    e.first_name,
    e.last_name,
    e.salary,
    case
        when e.salary < 75000 then 'Junior'
        when e.salary between 75000 and 99999 then 'Mid'
        else 'Senior'
    end as band
from employees as e;

-- Exercise 7
-- Find the month-over-month sales growth for 2023.
-- Show: month, total_sales, previous_month_sales, and growth percentage.
-- Hint: use LAG and date functions.

--Solution:
with monthly_sales as (
    select
        date_trunc('month', sale_date) as month,
        sum(amount) as total_sales
    from sales
    where extract(year from sale_date) = 2023
    group by date_trunc('month', sale_date)
)

select
    month,
    total_sales,
    lag(total_sales) over (order by month) as previous_month_sales,
    round(
        (
            (total_sales - lag(total_sales) over (order by month))
            / lag(total_sales) over (order by month)
        ) * 100,
        2
    ) as growth_percentage
from monthly_sales
order by month;


-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.

--Solution:
with recursive management_chain as (
    select
        e.id,
        e.first_name,
        e.last_name,
        e.manager_id,
        1 as level
    from employees as e
    where e.id = 3
    union all
    select
        e.id,
        e.first_name,
        e.last_name,
        e.manager_id,
        mc.level + 1
    from employees as e
    inner join management_chain as mc
        on e.id = mc.manager_id
)

select
    level,
    first_name,
    last_name
from management_chain
order by level;

-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.

--Solution:
select
    name as project_name,
    budget,
    round(budget * 100 / sum(budget) over (), 2) as budget_percentage
from projects;


-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.

--Solution:
select
    e.first_name,
    e.last_name,
    e.hire_date,
    e.salary
from employees as e
where
    e.hire_date <= current_date - interval '5 years'
    and e.salary < (select median(salary) from employees);

-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.

--Solution:
with sales_sumarray as (
    select
        e.id,
        e.first_name,
        e.last_name,
        s.region,
        sum(s.amount) as total_sales
    from employees as e inner join sales as s
        on e.id = s.employee_id
    group by e.id, e.first_name, e.last_name, s.region
)

select
    first_name,
    last_name,
    region,
    total_sales,
    max(total_sales) over (partition by region) as region_top_sales,
    max(total_sales) over (partition by region) - total_sales as gap
from sales_sumarray;


-- Exercise 12 (Challenge)
-- Write a query that shows, for each department:
--   - Department name s
--   - Total headcount
--   - Total salary budget
--   - Number of active projects their employees are on
--   - Average hours logged per employee on projects

--Solution:
select
    d.name as department_name,
    count(distinct e.id) as total_headcount,
    sum(e.salary) as total_salary_budget,
    count(distinct ep.project_id) as active_projects,
    round(avg(ep.hours_logged), 2) as avg_hours_logged_per_employee
from departments as d left join employees as e
    on d.id = e.department_id
left join employee_projects as ep
    on e.id = ep.employee_id
group by d.name;

-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.

--Solution:
select
    first_name,
    last_name,
    salary,
    ntile(4) over (order by salary) as salary_quartile
from employees;


-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.
--Solution:
select
    first_name,
    last_name,
    hire_date,
    datediff('day', hire_date, current_date) as days_employed
from employees;


-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.
--Solution:
with salary_stats as (
    select
        avg(salary) as avg_salary,
        sum(salary) as total_salary
    from employees
)

select
    e.first_name,
    e.last_name,
    e.salary,
    round(e.salary * 100 / total_salary, 2) as salary_percentage
from employees as e cross join salary_stats as s
where e.salary > s.avg_salary;


-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).
--Solution:
select
    e.first_name,
    e.last_name,
    min(s.sale_date) as first_sale,
    max(s.sale_date) as last_sale
from employees as e inner join sales as s
    on e.id = s.employee_id
group by e.id, e.first_name, e.last_name;


-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.
--Solution:
select
    e.first_name as emp1_first_name,
    e.last_name as emp1_last_name,
    e2.first_name as emp2_first_name,
    e2.last_name as emp2_last_name,
    d.name as department_name,
    e.hire_date as emp1_hire_date,
    e2.hire_date as emp2_hire_date
from employees as e inner join employees as e2
    on
        e.department_id = e2.department_id and e.id < e2.id
        and abs(datediff('day', e.hire_date, e2.hire_date)) <= 183
inner join departments as d
    on e.department_id = d.id;


-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.
--Solution:
with monthly_sales as (
    select
        date_trunc('month', sale_date) as month,
        sum(amount) as monthly_total
    from sales
    where extract(year from sale_date) = 2023
    group by date_trunc('month', sale_date)
)

select
    month,
    monthly_total,
    round(
        avg(monthly_total)
            over (order by month rows between 2 preceding and current row),
        2
    ) as rolling_avg_3_months
from monthly_sales
order by month;


-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.
--Solution:
select distinct
    e.first_name,
    e.last_name,
    p.name as project_name,
    p.end_date
from employees as e
inner join employee_projects as ep
    on e.id = ep.employee_id
inner join projects as p
    on ep.project_id = p.id
where p.end_date < current_date and p.status = 'active';


-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
-- Hint: use PERCENT_RANK().
--Solution:
select
    first_name,
    last_name,
    salary,
    round(percent_rank() over (order by salary) * 100, 2) as percentile_rank
from employees
order by salary;


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
--Solution:

with project_hours as (
    select
        employee_id,
        count(distinct project_id) as num_projects,
        sum(hours_logged) as total_hours
    from employee_projects
    group by employee_id
),

sales_summary as (
    select
        employee_id,
        sum(amount) as total_sales
    from sales
    group by employee_id
)

select
    d.name as department_name,
    e.salary,
    e.first_name || ' ' || e.last_name as full_name,
    coalesce(m.first_name || ' ' || m.last_name, 'No Manager') as manager_name,
    case
        when e.salary < 75000 then 'Junior'
        when e.salary between 75000 and 99999 then 'Mid'
        else 'Senior'
    end as salary_band,
    rank() over (partition by d.name order by e.salary desc) as salary_rank,
    coalesce(ph.num_projects, 0) as num_projects,
    coalesce(ph.total_hours, 0) as total_hours,
    coalesce(ss.total_sales, 0) as total_sales
from employees as e
inner join departments as d
    on e.department_id = d.id
left join employees as m
    on e.manager_id = m.id
left join project_hours as ph
    on e.id = ph.employee_id
left join sales_summary as ss
    on e.id = ss.employee_id
order by d.name, salary_rank;
