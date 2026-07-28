-- ============================================================
-- BEGINNER EXERCISES
-- Topics: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, LIKE, NULL
-- ============================================================

-- Exercise 1
-- Get the first name, last name, and job title of all employees.
   select first_name, last_name, job_title from employees;


-- Exercise 2
-- Get all employees who work in department_id = 1.
   select * from employees where department_id = 1;


-- Exercise 3
-- Get all employees with a salary greater than 90,000.
-- Show their full name and salary, sorted by salary highest to lowest.



-- Exercise 4
-- Get the 5 most recently hired employees.
-- Show their name and hire_date.



-- Exercise 5
-- Get all unique job titles in the company.



-- Exercise 6
-- Find all employees whose last name starts with the letter 'M'.



-- Exercise 7
-- Find all employees who do NOT have a manager (manager_id is NULL).



-- Exercise 8
-- Get all projects that are currently 'active'.
-- Show the project name, budget, and start date.



-- Exercise 9
-- Get all sales where the amount is between 10,000 and 25,000.
-- Sort by amount ascending.



-- Exercise 10
-- Count how many employees are in the company total.



-- Exercise 11
-- Get all employees hired in the year 2020.
-- Show their full name and hire_date.



-- Exercise 12
-- Get all sales made in the 'East' region.
-- Show the sale amount, product, and sale_date.



-- Exercise 13
-- Show all employees whose salary is NOT between 70,000 and 90,000.



-- Exercise 14
-- Get all projects that have an end_date (i.e. end_date is not NULL).
-- Show project name and end_date, sorted by end_date ascending.



-- Exercise 15
-- Find all employees whose first name contains the letter 'a' (case-insensitive).



-- Exercise 16
-- Show the total salary paid across the entire company.



-- Exercise 17
-- Get all employees sorted by department_id ascending,
-- then by salary descending within each department.



-- Exercise 18
-- Find all sales for the product 'Enterprise'.
-- Show employee_id, amount, and sale_date.



-- Exercise 19
-- Show the minimum, maximum, and average salary in the company.
-- Label the columns as min_salary, max_salary, avg_salary.



-- Exercise 20
-- Get all departments located in 'New York'.


