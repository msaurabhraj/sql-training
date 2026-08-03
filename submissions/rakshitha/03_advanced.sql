 -- ============================================================
-- ADVANCED EXERCISES
-- Topics: Window Functions, CTEs, Self-JOINs, CASE, Date functions
-- ============================================================

-- Exercise 1
-- Rank employees by salary within each department (highest salary = rank 1).
-- Show name, department, salary, and their rank.
    select concat(e.first_name, ' ', e.last_name) as employee_name, d.name as department_name, e.salary, rank() over (partition by d.id order by e.salary desc) as rank
    from employees e join departments d
    on e.department_id = d.id;


-- Exercise 2
-- For each employee, show their salary and the difference from
-- the average salary of their department.
-- Label the difference column as 'diff_from_avg'.
    select concat(e.first_name, ' ', e.last_name) as employee_name, d.name as department_name, e.salary, e.salary - avg(e.salary)
    over (partition by d.id) as diff_from_avg
    from employees e join departments d
    on e.department_id = d.id;


-- Exercise 3
-- Using a CTE, find the top 2 highest-paid employees in each department.
    with top_employees as (
        select concat(e.first_name, ' ', e.last_name) as employee_name, d.name as department_name, e.salary, rank()
        over (partition by d.id order by e.salary desc ) as rank
        from employees e join departments d
        on e.department_id = d.id
    )
    select * from top_employees
    where rank <= 2;


-- Exercise 4
-- Show a running total of sales amount ordered by sale_date.
-- Show: sale_date, amount, and running_total.
    select sale_date, amount, sum(amount) over (order by sale_date) as running_total
    from sales
    order by sale_date;



-- Exercise 5
-- For each employee, show their hire_date and the hire_date of the
-- person hired just before them (using LAG).
    select concat(e.first_name, ' ', e.last_name) as employee_name, e.hire_date, lag(e.hire_date) over (order by e.hire_date) as previous_hire_date
    from employees e
    order by e.hire_date;




-- Exercise 6
-- Categorize employees into salary bands using CASE:
--   'Junior'  : salary < 75,000
--   'Mid'     : salary between 75,000 and 99,999
--   'Senior'  : salary >= 100,000
-- Show name, salary, and band. Count how many fall in each band.
    select concat(first_name, ' ', last_name) as employee_name, salary,
    case
        when salary < 75000 then 'Junior'
        when salary between 75000 and 99999 then 'Mid'
        else 'Senior'
    end as band,
    count(id) over (partition by case
        when salary < 75000 then 'Junior'
        when salary between 75000 and 99999 then 'Mid'
        else 'Senior'
    end) as employee_count
    from employees;



-- Exercise 7
-- Find the month-over-month sales growth for 2023.
-- Show: month, total_sales, previous_month_sales, and growth percentage.
-- Hint: use LAG and date functions.
    select date_trunc('month', sale_date) as month, sum(amount) as total_sales,
    lag(sum(amount)) over (order by date_trunc('month', sale_date)) as previous_month_sales,
    round(((sum(amount) - lag(sum(amount)) over (order by date_trunc('month', sale_date))) / lag(sum(amount)) over (order by date_trunc('month', sale_date))) * 100, 2) as growth_percentage
    from sales
    where sale_date between '2023-01-01' and '2023-12-31'
    group by date_trunc('month', sale_date)
    order by month;



-- Exercise 8
-- Using a recursive CTE, show the full management chain for employee id = 3.
-- Output should show each level: employee name -> their manager -> their manager's manager, etc.
    with recursive management_chain as (
        select e.id, concat(e.first_name, ' ', e.last_name) as employee_name, e.manager_id, 1 as level
        from employees e
        where e.id = 3
        union all
        select m.id, concat(m.first_name, ' ', m.last_name) as employee_name, m.manager_id, mc.level + 1
        from employees m
        join management_chain mc on m.id = mc.manager_id
    )
    select * from management_chain
    order by level;



-- Exercise 9
-- For each project, calculate what percentage of the total company budget it represents.
-- Show project name, budget, and budget_percentage rounded to 2 decimal places.
    select p.name as project_name, p.budget, round((p.budget / sum(p.budget) over ()) * 100, 2) as budget_percentage
    from projects p;



-- Exercise 10
-- Find employees who have been with the company for more than 5 years
-- and have a salary below the company-wide median salary.
-- Show their name, hire_date, and salary.
    select concat(e.first_name, ' ', e.last_name) as employee_name, e.hire_date, e.salary
    from employees e 
    where e.hire_date < current_date - interval '5 years'
    and e.salary < (select percentile_cont(0.5) within group (order by salary) from employees);



-- Exercise 11
-- Show each sales rep's sales performance compared to the best performer in their region.
-- Show: name, region, their total sales, the region's top sales, and the gap.
    select concat(e.first_name, ' ', e.last_name) as employee_name, s.region, sum(s.amount) as total_sales,
    max(sum(s.amount)) over (partition by s.region) as region_top_sales,
    max(sum(s.amount)) over (partition by s.region) - sum(s.amount) as gap
    from employees e
    join sales s on e.id = s.employee_id
    group by e.id, e.first_name, e.last_name, s.region
    order by s.region, total_sales desc;



-- Exercise 12 (Challenge)
-- Write a query that shows, for each department:
--   - Department name
--   - Total headcount
--   - Total salary budget
--   - Number of active projects their employees are on
--   - Average hours logged per employee on projects
    with department_summary as (
        select department_id, count(*) as headcount, sum(salary) as total_salary_budget
        from employees
        group by department_id
    )
    select d.name as department_name, ds.headcount, ds.total_salary_budget,
    count(distinct p.id) as active_projects,
    round(avg(ep.hours_logged), 2) as avg_hours_per_employee
    from departments d
    left join department_summary ds on d.id = ds.department_id
    left join employees e on d.id = e.department_id
    left join employee_projects ep on e.id = ep.employee_id
    left join projects p on ep.project_id = p.id and p.status = 'active'
    group by d.id, d.name, ds.headcount, ds.total_salary_budget;



-- Exercise 13
-- Using NTILE, divide all employees into 4 salary quartiles.
-- Show name, salary, and which quartile (1=lowest, 4=highest) they fall in.
    select concat(e.first_name, ' ', e.last_name) as employee_name, e.salary,
    ntile(4) over (order by e.salary) as salary_quartile
    from employees e
    order by e.salary;



-- Exercise 14
-- For each employee, calculate how many days they have been with the company
-- as of today. Show name, hire_date, and days_employed.
    select concat(e.first_name, ' ', e.last_name) as employee_name, e.hire_date,
    current_date - e.hire_date as days_employed
    from employees e
    order by days_employed desc;



-- Exercise 15
-- Using a CTE, find all employees who earn more than the average salary
-- of ALL employees (not just their department).
-- Then show what percentage of the total salary bill they represent.
    with above_average_employees as (
        select e.id, concat(e.first_name, ' ', e.last_name) as employee_name, e.salary
        from employees e
        where e.salary > (select avg(salary) from employees)
    )
    select employee_name, salary, round((salary / (select sum(salary) from employees)) * 100, 2) as percentage_of_total_salary
    from above_average_employees;



-- Exercise 16
-- Show the first sale and the last sale (by date) made by each sales employee.
-- Show: name, first_sale_date, first_sale_amount, last_sale_date, last_sale_amount.
-- Use window functions (FIRST_VALUE / LAST_VALUE or ROW_NUMBER).
    select distinct concat(e.first_name, ' ', e.last_name) as employee_name,
    first_value(s.sale_date) over (partition by e.id order by s.sale_date) as first_sale_date,
    first_value(s.amount) over (partition by e.id order by s.sale_date) as first_sale_amount,
    last_value(s.sale_date) over (partition by e.id order by s.sale_date rows between unbounded preceding and unbounded following) as last_sale_date,
    last_value(s.amount) over (partition by e.id order by s.sale_date rows between unbounded preceding and unbounded following) as last_sale_amount
    from employees e
    join sales s on e.id = s.employee_id;


-- Exercise 17
-- Find pairs of employees who are in the same department AND
-- were hired within 6 months of each other.
-- Show both employee names, department, and their hire dates.
    select concat(e1.first_name, ' ', e1.last_name) as employee1_name, 
           concat(e2.first_name, ' ', e2.last_name) as employee2_name,
    d.name as department_name, e1.hire_date as employee1_hire_date, 
                               e2.hire_date as employee2_hire_date
    from employees e1
    join employees e2 on e1.department_id = e2.department_id and e1.id < e2.id
    join departments d on e1.department_id = d.id
    where abs(date_diff('day', e1.hire_date, e2.hire_date)) <= 180;



-- Exercise 18
-- Calculate a 3-month rolling average of total sales per month for 2023.
-- Show: month, monthly_total, rolling_avg_3_months.
    select date_trunc('month', sale_date) as month, sum(amount) as monthly_total,
    round(avg(sum(amount)) over (order by date_trunc('month', sale_date) rows between 2 preceding and current row), 2) as rolling_avg_3_months
    from sales
    where sale_date between '2023-01-01' and '2023-12-31'
    group by date_trunc('month', sale_date)
    order by month;


-- Exercise 19
-- Using a CTE, identify employees who have been on projects
-- that have gone over their original planned end_date (end_date < today but status = 'active').
-- Show employee name, project name, and planned end_date.
    with overdue_projects as (
        select ep.employee_id, p.name as project_name, p.end_date
        from employee_projects ep
        join projects p on ep.project_id = p.id
        where p.end_date < current_date and p.status = 'active'
    )
    select concat(e.first_name, ' ', e.last_name) as employee_name, op.project_name, op.end_date
    from overdue_projects op
    join employees e on op.employee_id = e.id;



-- Exercise 20
-- For each employee, show their salary percentile rank within the company
-- (i.e. what percentage of employees earn less than them).
-- Show name, salary, and percentile_rank rounded to 2 decimal places.
-- Hint: use PERCENT_RANK().
    select concat(e.first_name, ' ', e.last_name) as employee_name, e.salary,
    round(percent_rank() over (order by e.salary) * 100, 2) as percentile_rank
    from employees e
    order by e.salary desc;



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
    with project_summary as (
        select ep.employee_id, count(distinct ep.project_id) as project_count, sum(ep.hours_logged) as total_hours
        from employee_projects ep
        group by ep.employee_id
    ),
    sales_summary as (
        select s.employee_id, sum(s.amount) as total_sales
        from sales s
        group by s.employee_id
    )
    select concat(e.first_name, ' ', e.last_name) as employee_name, d.name as department_name,
    coalesce(concat(m.first_name, ' ', m.last_name), 'No Manager') as manager_name,

    case
        when e.salary < 75000 then 'Junior'
        when e.salary between 75000 and 99999 then 'Mid'
        else 'Senior'
    end as salary_band,

    rank() over (partition by d.id order by e.salary desc) as salary_rank,
    coalesce(ps.project_count, 0) as number_of_projects,
    coalesce(ps.total_hours, 0) as total_hours_logged,
    coalesce(ss.total_sales, 0) as total_sales_amount

    from employees e
    left join departments d on e.department_id = d.id
    left join employees m on e.manager_id = m.id
    left join project_summary ps on e.id = ps.employee_id
    left join sales_summary ss on e.id = ss.employee_id
    group by e.id, e.first_name, e.last_name, e.salary, d.id,d.name, m.first_name, m.last_name, ps.project_count, ps.total_hours, ss.total_sales
    order by d.name, salary_rank;


