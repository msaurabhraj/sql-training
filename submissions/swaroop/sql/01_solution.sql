-- ============================================================
-- BEGINNER EXERCISES
-- Topics: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, LIKE, NULL
-- ============================================================

-- Exercise 1
-- Get the first name, last name, and job title of all employees.

select
    first_name,
    last_name,
    job_title
from employees;

-- Exercise 2
-- Get all employees who work in department_id = 1.

select *
from employees
where department_id = 1;


-- Exercise 3
-- Get all employees with a salary greater than 90,000.
-- Show their full name and salary, sorted by salary highest to lowest.

select
    first_name,
    last_name,
    salary
from employees
where salary > 90000
order by salary desc;

-- Exercise 4
-- Get the 5 most recently hired employees.
-- Show their name and hire_date.
select
    first_name,
    last_name,
    hire_date
from employees
order by hire_date desc
limit 5;

-- Exercise 5
-- Get all unique job titles in the company.
select distinct job_title
from employees;


-- Exercise 6
-- Find all employees whose last name starts with the letter 'M'.

select *
from employees
where last_name like 'M%';

-- Exercise 7 
-- Find all employees who do NOT have a manager (manager_id is NULL).

select *
from employees
where manager_id is null;

-- Exercise 8
-- Get all projects that are currently 'active'.
-- Show the project name, budget, and start date.
select
    name,
    budget,
    start_date
from projects
where status = 'active';


-- Exercise 9
-- Get all sales where the amount is between 10,000 and 25,000.
-- Sort by amount ascending.

select *
from sales
where amount between 10000 and 25000
order by amount asc;

-- Exercise 10
-- Count how many employees are in the company total.

select count(*) as total_employees
from employees;


-- Exercise 11
-- Get all employees hired in the year 2020.
-- Show their full name and hire_date.
select
    first_name,
    last_name,
    hire_date
from employees
where hire_date between '2020-01-01' and '2020-12-31';


-- Exercise 12
-- Get all sales made in the 'East' region.
-- Show the sale amount, product, and sale_date.

select
    amount,
    product,
    sale_date
from sales
where region = 'East';

-- Exercise 13
-- Show all employees whose salary is NOT between 70,000 and 90,000.

select *
from employees
where salary not between 70000 and 90000;


-- Exercise 14
-- Get all projects that have an end_date (i.e. end_date is not NULL).
-- Show project name and end_date, sorted by end_date ascending.

select
    name,
    end_date
from projects
where end_date is not null
order by end_date asc;

-- Exercise 15
-- Find all employees whose first name contains the letter 'a' (case-insensitive).

select *
from employees
where first_name like '%a%';


-- Exercise 16
-- Show the total salary paid across the entire company.

select sum(salary) as total_salary
from employees;

-- Exercise 17
-- Get all employees sorted by department_id ascending,
-- then by salary descending within each department.
select *
from employees
order by department_id asc, salary desc;

-- Exercise 18
-- Find all sales for the product 'Enterprise'.
-- Show employee_id, amount, and sale_date.

select
    employee_id,
    amount,
    sale_date
from sales
where product = 'Enterprise';

-- Exercise 19
-- Show the minimum, maximum, and average salary in the company.
-- Label the columns as min_salary, max_salary, avg_salary.

select
    min(salary) as min_salary,
    max(salary) as max_salary,
    avg(salary) as avg_salary
from employees;

-- Exercise 20
-- Get all departments located in 'New York'.
select *
from departments
where location = 'New York';
