--Que1
--Query to select first name, last name and job title of all employees
SELECT
    first_name,
    last_name,
    job_title
FROM employees;

--Que2
--Query to select all employees who work in department 1
SELECT *
FROM employees
WHERE department_id = 1;

--Que3
--Query to select all employees with salary greater than 90,000 and show their full name and salary sorted by salary highest to lowest
SELECT
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > 90000
ORDER BY salary DESC;

--Que4
--Query to select the 5 most recently hired employees and show their name and hire_date
SELECT
    first_name,
    last_name,
    hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 5;

--Que5
--Query to select all unique job titles in the company
SELECT DISTINCT job_title
FROM employees;

--Que6
--Query to find all employees whose last name starts with the letter 'M'
SELECT *
FROM employees
WHERE last_name LIKE 'M%';

--Que7
--Query to find all employees who do NOT have a manager (manager_id is NULL)
SELECT *
FROM employees
WHERE manager_id IS null;

--Que8
--Query to select all projects that are currently 'active' and show the project name, budget
SELECT
    name,
    budget,
    start_date
FROM projects
WHERE status = 'active';


--Que9
--Query to select all sales where the amount is between 10,000 and 25,000 and sort by amount ascending
SELECT *
FROM sales
WHERE amount BETWEEN 10000 AND 25000
ORDER BY amount ASC;


--Que10
--Query to count the total number of employees in the company
SELECT count(*)
FROM employees;


--Que11
--Query to select all employees hired in the year 2020 and show their full name and hire_date
SELECT
    first_name,
    last_name,
    hire_date
FROM employees
WHERE hire_date BETWEEN '2020-01-01' AND '2020-12-31';

--Que12
--Query to select all sales made in the east region and show the sale_id, amount, and sale_date
SELECT
    id AS sale_id,
    amount,
    sale_date
FROM sales
WHERE region = 'East';

--Que13
--Query to select all employees whose salary is not between 70,000 and 90,000 
SELECT *
FROM employees
WHERE salary NOT BETWEEN 70000 AND 90000;

--Que14
--Query to select all projects that have an end_date (i.e. end_date is not NULL) and show project name and end_date, sorted by end_date ascending
SELECT
    name,
    end_date
FROM projects
WHERE end_date IS NOT null
ORDER BY end_date ASC;


--Que15
--Query to select all employees whose first name contains the letter 'a' (case-insensitive)
SELECT *
FROM employees
WHERE lower(first_name) LIKE '%a%';

--que16
--Query to show the total salary of all employees in the company
SELECT sum(salary) AS total_salary
FROM employees;

--Que17
--Query to select all employees by department id in ascending order and salary in descending order
SELECT *
FROM employees
ORDER BY department_id ASC, salary DESC;

--Que18
--Query to select all sales for the product 'Enterprise' and show employee_id, amount, and sale_date
SELECT
    employee_id,
    amount,
    sale_date
FROM sales
WHERE product = 'Enterprise';

--Que19
--Query to show maximum, minimum and average salary of all employees in the company
SELECT
    max(salary) AS maximum_salary,
    min(salary) AS minimum_salary,
    avg(salary) AS average_salary
FROM employees;

--Que20
--Query to select all employees deparment located in 'New York'
SELECT *
FROM departments
WHERE location = 'New York';
