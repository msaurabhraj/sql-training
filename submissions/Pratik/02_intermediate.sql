-- ============================================================
-- INTERMEDIATE EXERCISES
-- Topics: JOINs, GROUP BY, HAVING, Aggregates, Subqueries
-- ============================================================

-- Exercise 1
-- Show each employee's full name along with their department name.
select e.first_name, e.last_name, d.name as department_name
from employees e
join departments d on e.department_id = d.id;

-- Exercise 2
-- Show each employee's full name and their manager's full name.
-- If an employee has no manager, still show their name (with NULL for manager).
select e.first_name, e.last_name, m.first_name as manager_first_name, m.last_name as manager_last_name
from employees e
left join employees m on e.manager_id = m.id;

-- Exercise 3
-- Find the total number of employees in each department.
-- Show department name and employee count, sorted by count descending.
select d.name as department_name, count(e.id) as employee_count
from departments d
left join employees e on d.id = e.department_id
group by d.name
order by employee_count desc;

-- Exercise 4
-- Find the average salary per department.
-- Only show departments where the average salary is above 80,000.
select d.name as department_name, avg(e.salary) as average_salary
from departments d
left join employees e on d.id = e.department_id
group by d.name
having avg(e.salary) > 80000;

-- Exercise 5
-- Find the highest and lowest salary in the company per job title.
select job_title, max(salary) as highest_salary, min(salary) as lowest_salary
from employees
group by job_title;

-- Exercise 6
-- Show each project's name and the number of employees assigned to it.
-- Include projects that have no employees assigned.
select p.name as project_name, count(ep.employee_id) as employee_count
from projects p
left join employee_projects ep on p.id = ep.project_id
group by p.name;

-- Exercise 7
-- Find all employees who are assigned to more than one project.
-- Show their name and the number of projects.
select e.first_name, e.last_name, count(ep.project_id) as project_count
from employees e
left join employee_projects ep on e.id = ep.employee_id
group by e.id, e.first_name, e.last_name
having count(ep.project_id) > 1;

-- Exercise 8
-- Find the total sales amount per sales employee.
-- Show their full name and total sales, sorted by total sales descending.
select e.first_name, e.last_name, sum(s.amount) as total_sales
from employees e
left join sales s on e.id = s.employee_id
group by e.id, e.first_name, e.last_name
order by total_sales desc;

-- Exercise 9
-- Find all employees who earn more than the average salary of their department.
-- Show their name, salary, and department name.
select e.first_name, e.last_name, e.salary, d.name as department_name
from employees e
left join departments d on e.department_id = d.id
where e.salary > (select avg(salary) from employees where department_id = e.department_id);


-- Exercise 10
-- List all employees who have NOT been assigned to any project.
select e.first_name, e.last_name
from employees e
left join employee_projects ep on e.id = ep.employee_id
where ep.employee_id is null;

-- Exercise 11
-- For each department, show the name of the highest-paid employee.
select d.name as department_name, e.first_name, e.last_name, e.salary
from departments d
left join employees e on d.id = e.department_id
where e.salary = (select max(salary) from employees where department_id = d.id);


-- Exercise 12
-- Find all projects where the total hours logged by all employees exceeds 400.
-- Show project name and total hours.
select p.name as project_name, sum(ep.hours_logged) as total_hours
from projects p
left join employee_projects ep on p.id = ep.project_id
group by p.name
having sum(ep.hours_logged) > 400;

-- Exercise 13
-- Show each employee's full name, their department name, and their manager's full name.
-- If no manager, show 'No Manager'.
select e.first_name, e.last_name, d.name as department_name,
       coalesce(m.first_name || ' ' || m.last_name, 'No Manager') as manager_name
from employees e
left join departments d on e.department_id = d.id
left join employees m on e.manager_id = m.id;

-- Exercise 14
-- Find the total sales per product.
-- Show product name and total amount, sorted by total amount descending.
select product, sum(amount) as total_sales
from sales
group by product
order by total_sales desc;

-- Exercise 15
-- Find all employees who share the same job title.
-- Show the job title and the names of employees who have it.
-- Exclude job titles held by only one person.
select job_title, group_concat(first_name || ' ' || last_name) as employees
from employees
group by job_title
having count(*) > 1;

-- Exercise 16
-- For each department, show the number of employees hired after 2020.
select d.name as department_name, count(e.id) as employees_hired_after_2020
from departments d
left join employees e on d.id = e.department_id
where e.hire_date > '2020-12-31'
group by d.name;

-- Exercise 17
-- Find the employee who has logged the most total hours across all projects.
-- Show their name and total hours.
select e.first_name, e.last_name, sum(ep.hours_logged) as total_hours
from employees e
left join employee_projects ep on e.id = ep.employee_id
group by e.id, e.first_name, e.last_name
order by total_hours desc
limit 1;

-- Exercise 18
-- Show each region's total sales and the number of sales transactions.
select region, sum(amount) as total_sales, count(*) as transaction_count
from sales
group by region;

-- Exercise 19
-- Find all employees who are both a manager (someone reports to them)
-- and are assigned to at least one project.
-- Show their name, department, and number of direct reports.
select e.first_name, e.last_name, d.name as department_name, count(r.id) as direct_reports
from employees e
left join departments d on e.department_id = d.id
left join employees r on e.id = r.manager_id
group by e.id, e.first_name, e.last_name, d.name
having count(r.id) > 0;

-- Exercise 20
-- List each project with its total budget vs total hours logged.
-- Show: project name, budget, total_hours, and cost_per_hour
-- (assume cost_per_hour = budget / total_hours, rounded to 2 decimal places).
select p.name as project_name, p.budget, sum(ep.hours_logged) as total_hours,
       round(p.budget / nullif(sum(ep.hours_logged), 0), 2) as cost_per_hour
from projects p
left join employee_projects ep on p.id = ep.project_id
group by p.name, p.budget;


-- Exercise 21
-- Find the top-selling product in each region.
-- Show: region, product, and total sales amount.
select region, product, sum(amount) as total_sales
from sales
group by region, product;

-- Exercise 22
-- Show all employees who joined in the same year as at least one other employee
-- from a different department.
-- Show their name, department name, and hire year.
select e.first_name, e.last_name, d.name as department_name, strftime('%Y', e.hire_date) as hire_year
from employees e
left join departments d on e.department_id = d.id
where strftime('%Y', e.hire_date) in (
    select strftime('%Y', hire_date)
    from employees
    where department_id != e.department_id
);
