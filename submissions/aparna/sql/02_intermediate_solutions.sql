-- ============================================================
-- INTERMEDIATE EXERCISES
-- Topics: JOINs, GROUP BY, HAVING, Aggregates, Subqueries
-- ============================================================

-- Exercise 1
-- Show each employee's full name along with their department name.
--Solution:
select e.first_name,e.last_name,d.name as Dept_name from employees e
join departments d on e.department_id=d.id;


-- Exercise 2
-- Show each employee's full name and their manager's full name.
-- If an employee has no manager, still show their name (with NULL for manager).
--Solution:
select e.first_name,e.last_name, m.first_name as Manager_first_name, m.last_name as Manager_last_name from employees e
left join employees m on e.manager_id=m.id;


-- Exercise 3
-- Find the total number of employees in each department.
-- Show department name and employee count, sorted by count descending.
--Solution:
select count(*) as Employee_count, d.name as Dept_name from employees e
join departments d on e.department_id=d.id
group by d.name
order by Employee_count desc;


-- Exercise 4
-- Find the average salary per department.
-- Only show departments where the average salary is above 80,000.
--Solution:
select avg(e.salary) as Avg_salary,d.name as Dept_name from employees e
join departments d on e.department_id=d.id
group by Dept_name
having Avg_salary>80000;


-- Exercise 5
-- Find the highest and lowest salary in the company per job title.
--Solution:
select e.job_title, max(e.salary) as Max_salary, min(e.salary) as Min_salary from employees e
group by e.job_title;


-- Exercise 6
-- Show each project's name and the number of employees assigned to it.
-- Include projects that have no employees assigned.
--Solution:
select p.name as Project_name, count(ep.employee_id) as Employee_count from projects p
left join employee_projects ep on p.id=ep.project_id
group by p.name;

-- Exercise 7
-- Find all employees who are assigned to more than one project.
-- Show their name and the number of projects.
--Solution:
select e.first_name,e.last_name, count(ep.project_id) as Project_count from employees e
join employee_projects ep on e.id=ep.employee_id
group by e.first_name,e.last_name
having Project_count>1;

-- Exercise 8
-- Find the total sales amount per sales employee.
-- Show their full name and total sales, sorted by total sales descending.
--Solution:
select e.first_name,e.last_name,e.job_title,sum(s.amount)as Total_sales from employees e
join sales s on e.id=s.employee_id
group by e.first_name,e.last_name,e.job_title
having e.job_title like '%Sales%'
order by Total_sales desc;

-- Exercise 9
-- Find all employees who earn more than the average salary of their department.
-- Show their name, salary, and department name.
--Solution:
select e.first_name,e.last_name,e.salary,d.name as Dept_name from employees e
join departments d on e.department_id=d.id
where e.salary>(
    select avg(salary) from employees where department_id=e.department_id
);


-- Exercise 10
-- List all employees who have NOT been assigned to any project.
--Solution:
select e.first_name,e.last_name from employees e
left join employee_projects ep on e.id=ep.employee_id
where ep.project_id is null;


-- Exercise 11
-- For each department, show the name of the highest-paid employee.
--Solution:
select e.first_name,e.last_name,d.name as Dept_name from employees e
join departments d on e.department_id=d.id
where e.salary in (
    select max(salary) from employees where department_id=e.department_id
);

-- Exercise 12
-- Find all projects where the total hours logged by all employees exceeds 400.
-- Show project name and total hours.
--Solution:
select p.name,sum(ep.hours_logged) as Total_hours from projects p 
join employee_projects ep on p.id=ep.project_id
group by p.name
having total_hours>400;

-- Exercise 13
-- Show each employee's full name, their department name, and their manager's full name.
-- If no manager, show 'No Manager'.
--Solution:
select e.first_name||''||e.last_name as Employee_name,d.name as Department_name,coalesce(m.first_name||''||m.last_name,'No Manager') as manager_name from employees e
join departments as d on e.department_id=d.id
left join employees as m on e.manager_id=m.id;


-- Exercise 14
-- Find the total sales per product.
-- Show product name and total amount, sorted by total amount descending.
--Solution:
select product,sum(amount) as Total_sales from sales
group by product 
order by Total_sales desc;

-- Exercise 15
-- Find all employees who share the same job title
-- Show the job title and the names of employees who have it.
-- Exclude job titles held by only one person.
--Solution:
select e.job_title, e.first_name||''||e.last_name as Employee_name from employees e
where e.job_title in (
    select job_title from employees group by job_title having count(*)>1
);

-- Exercise 16
-- For each department, show the number of employees hired after 2020.
--Solution:
select d.name as Dept_name,count(e.id) as Employee_count from departments d
left join employees e on d.id=e.department_id and e.hire_date>'2020-12-31'
group by d.name;    



-- Exercise 17
-- Find the employee who has logged the most total hours across all projects.
-- Show their name and total hours.
--Solution:
select e.first_name||''||e.last_name as Employee_name,sum(ep.hours_logged) as Total_hours from employees e
join employee_projects ep on e.id=ep.employee_id
group by e.first_name||''||e.last_name
order by Total_hours desc
limit 1;

-- Exercise 18
-- Show each region's total sales and the number of sales transactions.
--Solution:
select region,sum(amount) as Total_sales,count(*) as total_transactions from sales
group by region;


-- Exercise 19
-- Find all employees who are both a manager (someone reports to them)
-- and are assigned to at least one project.
-- Show their name, department, and number of direct reports.
--Solution:
select e.first_name||''||e.last_name as Employee_name,d.name as Dept_name,count(r.id) as direct_reports from employees e
join  departments d on e.department_id=d.id
left join employees r on r.manager_id=e.id
where e.id in (select employee_id from employee_projects)
group by e.id,e.first_name,e.last_name,d.name
having count(r.id)>0;

-- Exercise 20
-- List each project with its total budget vs total hours logged.
-- Show: project name, budget, total_hours, and cost_per_hour
-- (assume cost_per_hour = budget / total_hours, rounded to 2 decimal places).
--Solution:
select p.name,p.budget,sum(ep.hours_logged) as total_hours,round(p.budget/sum(ep.hours_logged),2) as cost_per_hour from projects p
join employee_projects ep on p.id=ep.project_id
group by p.name,p.id,p.budget;


-- Exercise 21
-- Find the top-selling product in each region.
-- Show: region, product, and total sales amount.
--Solution:
select p.region,p.product,p.total_sales
from (
    select region,product,sum(amount) as Total_sales from sales,
    group by region,product
)p
join(
    select region,max(total_sales) as max_total from (
        select region,product,sum(amount) as Total_sales from sales
        group by region,product
    )t
    group by region
)m
on p.region=m.region and p.total_sales=m.max_total;

-- Exercise 22
-- Show all employees who joined in the same year as at least one other employee
-- from a different department.
-- Show their name, department name, and hire year.
--Solution:
select distinct e1.first_name||''||e1.last_name as Employee_name,d.name as Dept_name,extract(year from e1.hire_date) as Hire_year from employees e1
join departments d on e1.department_id=d.id
join employees e2 on extract(year from e1.hire_date)=extract(year from e2.hire_date) and e1.department_id!=e2.department_id;