-- ============================================================
-- SQL TRAINING - DATABASE SETUP
-- Run this file first to create all tables and sample data
-- ============================================================

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS departments;

-- DEPARTMENTS
CREATE TABLE departments (
    id          INT PRIMARY KEY,
    name        VARCHAR(100),
    location    VARCHAR(100)
);

INSERT INTO departments VALUES
(1, 'Engineering',  'New York'),
(2, 'Sales',        'Chicago'),
(3, 'HR',           'New York'),
(4, 'Marketing',    'Los Angeles'),
(5, 'Finance',      'Chicago');

-- EMPLOYEES
-- Hierarchy is 4 levels deep for some branches:
--   CEO (id=16) -> VP (id=1,4,7,9,11) -> Manager (id=2,5,12) -> Engineer/Rep (id=3,13,14,15,17-26)
CREATE TABLE employees (
    id              INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    email           VARCHAR(100),
    department_id   INT REFERENCES departments(id),
    manager_id      INT REFERENCES employees(id),
    salary          DECIMAL(10,2),
    hire_date       DATE,
    job_title       VARCHAR(100)
);

INSERT INTO employees VALUES
-- Level 1: CEO
(16, 'Sam',     'CEO',      'sam@company.com',     1, NULL,  200000, '2010-01-01', 'CEO');

INSERT INTO employees VALUES
-- Level 2: VPs / Directors
(1,  'Alice',   'Smith',    'alice@company.com',   1, 16,   120000, '2018-03-15', 'VP Engineering'),
(4,  'David',   'Brown',    'david@company.com',   2, 16,   110000, '2017-11-20', 'VP Sales'),
(7,  'Grace',   'Wilson',   'grace@company.com',   3, 16,    95000, '2016-09-30', 'HR Director'),
(9,  'Iris',    'Taylor',   'iris@company.com',    4, 16,   105000, '2019-08-22', 'Marketing Director'),
(11, 'Karen',   'Thomas',   'karen@company.com',   5, 16,   115000, '2015-05-18', 'CFO');

INSERT INTO employees VALUES
-- Level 3: Managers
(2,  'Bob',     'Jones',    'bob@company.com',     1, 1,     90000, '2019-06-01', 'Senior Engineer'),
(5,  'Eva',     'Davis',    'eva@company.com',     2, 4,     75000, '2021-04-05', 'Sales Manager'),
(12, 'Leo',     'Jackson',  'leo@company.com',     5, 11,    80000, '2020-10-07', 'Finance Manager');

INSERT INTO employees VALUES
-- Level 4: Individual contributors
(3,  'Carol',   'White',    'carol@company.com',   1, 2,     85000, '2020-01-10', 'Engineer'),
(13, 'Mia',     'Harris',   'mia@company.com',     1, 2,     88000, '2020-03-25', 'Engineer'),
(15, 'Olivia',  'Garcia',   'olivia@company.com',  1, 2,     92000, '2018-12-01', 'Senior Engineer'),
(6,  'Frank',   'Miller',   'frank@company.com',   2, 5,     72000, '2021-07-15', 'Sales Rep'),
(14, 'Nathan',  'Martin',   'nathan@company.com',  2, 5,     68000, '2022-09-12', 'Sales Rep'),
(17, 'Paula',   'Lee',      'paula@company.com',   2, 5,     71000, '2022-03-08', 'Sales Rep'),
(18, 'Quinn',   'Adams',    'quinn@company.com',   2, 5,     69000, '2023-05-22', 'Sales Rep'),
(8,  'Henry',   'Moore',    'henry@company.com',   3, 7,     65000, '2022-02-14', 'HR Specialist'),
(19, 'Rachel',  'Scott',    'rachel@company.com',  3, 7,     63000, '2021-11-30', 'HR Specialist'),
(20, 'Steve',   'King',     'steve@company.com',   3, 7,     67000, '2019-04-17', 'HR Analyst'),
(10, 'Jack',    'Anderson', 'jack@company.com',    4, 9,     70000, '2023-01-03', 'Marketing Analyst'),
(21, 'Tina',    'Wright',   'tina@company.com',    4, 9,     74000, '2020-06-15', 'Marketing Analyst'),
(22, 'Uma',     'Lopez',    'uma@company.com',     4, 9,     78000, '2018-08-20', 'Senior Marketing Analyst'),
(23, 'Victor',  'Hill',     'victor@company.com',  5, 12,    76000, '2021-02-28', 'Financial Analyst'),
(24, 'Wendy',   'Green',    'wendy@company.com',   5, 12,    73000, '2022-07-11', 'Financial Analyst'),
(25, 'Xander',  'Baker',    'xander@company.com',  1, 2,     82000, '2021-09-05', 'Engineer'),
(26, 'Yara',    'Nelson',   'yara@company.com',    1, 2,     79000, '2023-03-14', 'Junior Engineer');

-- PROJECTS
CREATE TABLE projects (
    id          INT PRIMARY KEY,
    name        VARCHAR(100),
    budget      DECIMAL(12,2),
    start_date  DATE,
    end_date    DATE,
    status      VARCHAR(20)   -- 'active', 'completed', 'on_hold'
);

INSERT INTO projects VALUES
(1, 'Website Redesign',    50000,  '2023-01-01', '2023-06-30', 'completed'),
(2, 'Mobile App v2',       120000, '2023-03-01', '2024-02-28', 'active'),
(3, 'Data Migration',      80000,  '2023-05-15', '2023-12-31', 'completed'),
(4, 'CRM Integration',     95000,  '2023-07-01', NULL,         'active'),
(5, 'Security Audit',      30000,  '2024-01-01', NULL,         'on_hold'),
(6, 'Analytics Dashboard', 70000,  '2023-09-01', '2024-03-31', 'active'),
(7, 'HR Portal',           45000,  '2022-06-01', '2023-03-31', 'completed'),
(8, 'Finance Reporting',   60000,  '2023-11-01', '2024-06-30', 'active');

-- EMPLOYEE_PROJECTS (many-to-many)
CREATE TABLE employee_projects (
    employee_id INT REFERENCES employees(id),
    project_id  INT REFERENCES projects(id),
    role        VARCHAR(50),
    hours_logged INT,
    PRIMARY KEY (employee_id, project_id)
);

INSERT INTO employee_projects VALUES
-- Mobile App v2 (project 2) - large team
(1,  2, 'Sponsor',    10),
(2,  2, 'Lead',       350),
(3,  2, 'Developer',  290),
(13, 2, 'Developer',  300),
(15, 2, 'Developer',  275),
(25, 2, 'Developer',  260),
-- Website Redesign (project 1) - completed
(2,  1, 'Lead',       200),
(3,  1, 'Developer',  180),
(26, 1, 'Developer',  160),
-- Data Migration (project 3) - completed
(3,  3, 'Developer',  220),
(15, 3, 'Developer',  190),
(23, 3, 'Analyst',    170),
-- CRM Integration (project 4) - active
(4,  4, 'Sponsor',    20),
(5,  4, 'Lead',       130),
(6,  4, 'Analyst',    110),
(15, 4, 'Lead',       150),
(17, 4, 'Analyst',    95),
-- Security Audit (project 5) - on_hold
(7,  5, 'Lead',       40),
(8,  5, 'Analyst',    35),
(20, 5, 'Analyst',    30),
-- Analytics Dashboard (project 6) - active
(9,  6, 'Lead',       180),
(10, 6, 'Analyst',    210),
(12, 6, 'Lead',       200),
(21, 6, 'Analyst',    175),
(22, 6, 'Analyst',    195),
(23, 6, 'Analyst',    190),
(24, 6, 'Analyst',    160),
-- HR Portal (project 7) - completed
(7,  7, 'Lead',       120),
(8,  7, 'Developer',  110),
(19, 7, 'Developer',  100),
-- Finance Reporting (project 8) - active
(11, 8, 'Sponsor',    15),
(12, 8, 'Lead',       180),
(23, 8, 'Developer',  160),
(24, 8, 'Developer',  145);

-- SALES
CREATE TABLE sales (
    id              INT PRIMARY KEY,
    employee_id     INT REFERENCES employees(id),
    amount          DECIMAL(10,2),
    sale_date       DATE,
    product         VARCHAR(100),
    region          VARCHAR(50)
);

INSERT INTO sales VALUES
-- January 2023 (multiple sales same month to make aggregation meaningful)
(1,  5,  15000, '2023-01-05', 'Pro Plan',      'East'),
(2,  6,  18000, '2023-01-12', 'Pro Plan',      'West'),
(3,  14, 11000, '2023-01-20', 'Starter Plan',  'East'),
(4,  17, 13500, '2023-01-25', 'Pro Plan',      'West'),
-- February 2023
(5,  5,  22000, '2023-02-08', 'Enterprise',    'East'),
(6,  6,   9500, '2023-02-14', 'Starter Plan',  'West'),
(7,  18, 16000, '2023-02-22', 'Pro Plan',      'East'),
-- March 2023
(8,  14, 27000, '2023-03-10', 'Enterprise',    'East'),
(9,  17, 21000, '2023-03-18', 'Enterprise',    'West'),
(10, 6,  12000, '2023-03-25', 'Pro Plan',      'West'),
-- April 2023
(11, 5,  19000, '2023-04-03', 'Pro Plan',      'East'),
(12, 18,  8500, '2023-04-15', 'Starter Plan',  'East'),
(13, 14, 14000, '2023-04-28', 'Pro Plan',      'East'),
-- May 2023
(14, 6,  31000, '2023-05-07', 'Enterprise',    'West'),
(15, 17, 17500, '2023-05-19', 'Pro Plan',      'West'),
(16, 5,   7500, '2023-05-30', 'Starter Plan',  'East'),
-- June 2023
(17, 14, 24000, '2023-06-11', 'Enterprise',    'East'),
(18, 18, 20000, '2023-06-22', 'Enterprise',    'East'),
-- July 2023
(19, 5,  16000, '2023-07-04', 'Pro Plan',      'East'),
(20, 6,  11000, '2023-07-17', 'Pro Plan',      'West'),
(21, 17,  9000, '2023-07-29', 'Starter Plan',  'West'),
-- August 2023
(22, 14, 28000, '2023-08-08', 'Enterprise',    'East'),
(23, 5,  23000, '2023-08-21', 'Enterprise',    'East'),
-- September 2023
(24, 6,  15000, '2023-09-05', 'Pro Plan',      'West'),
(25, 18, 19000, '2023-09-18', 'Pro Plan',      'East'),
(26, 17, 13000, '2023-09-27', 'Pro Plan',      'West'),
-- October 2023
(27, 14, 10000, '2023-10-09', 'Starter Plan',  'East'),
(28, 5,  26000, '2023-10-23', 'Enterprise',    'East'),
-- November 2023
(29, 6,  18000, '2023-11-06', 'Pro Plan',      'West'),
(30, 17, 22000, '2023-11-19', 'Enterprise',    'West'),
(31, 18, 12000, '2023-11-28', 'Pro Plan',      'East'),
-- December 2023
(32, 14, 32000, '2023-12-05', 'Enterprise',    'East'),
(33, 5,   9000, '2023-12-18', 'Starter Plan',  'East'),
(34, 6,  14000, '2023-12-29', 'Pro Plan',      'West');
