# Employees Database Queries

This document contains instructions for setting up the sample "Employees" database and a collection of SQL queries for data analysis.

## Setup Instructions

To get the database, clone the repository into your local VM or server and import it:

```bash
# Clone the repository
git clone https://github.com/datacharmer/test_db.git

# Navigate to the directory
cd test_db/

# Import the database (using the user created in the setup guide)
mysql -ubig_data_user -pexample123 < employees.sql
```

---

## SQL Queries and Explanations

### 1. Initial Data Exploration

**View departments:**
```sql
select * from departments;
```
*Explanation: Retrieves all columns and records from the `departments` table.*

**View first 15 job titles:**
```sql
select * from titles limit 15;
```
*Explanation: Retrieves the first 15 records from the `titles` table to understand its structure.*

---

### 2. Using DISTINCT and COUNT

**Unique job titles:**
```sql
select distinct title from titles;
```
*Explanation: Lists every unique job title held by employees across the company.*

**Unique name combinations:**
```sql
select distinct first_name, last_name from employees;
```
*Explanation: Returns all unique combinations of first and last names.*

**Count unique full names:**
```sql
select count(distinct concat(first_name , last_name)) from employees;
```
*Explanation: Concatenates first and last names and counts how many unique full names exist in the database.*

---

### 3. Cartesian Product Demonstration

**Count departments:**
```sql
select count(*) from departments;
```

**Count managers:**
```sql
select count(*) from dept_manager;
```

**Cross Join (Cartesian Product):**
```sql
select count(*) from dept_manager, departments;
```
*Explanation: This performs a cross join, meaning it multiplies the number of rows in `dept_manager` by the number of rows in `departments`. This is useful for understanding how joins work without conditions.*

---

### 4. Joining Tables

**Implicit Join:**
```sql
select * from employees, salaries 
where employees.emp_no = salaries.emp_no limit 10;
```
*Explanation: Joins the `employees` and `salaries` tables on the employee number field.*

**Join with Ordering:**
```sql
select * from employees, salaries 
where employees.emp_no = salaries.emp_no 
order by employees.emp_no, salaries.to_date limit 10;
```
*Explanation: Similar to the previous join, but sorts the results by employee number and then by the date the salary was valid.*

**Using Table Aliases:**
```sql
select * from employees e, salaries s 
where e.emp_no = s.emp_no 
order by e.emp_no, s.to_date limit 10;
```
*Explanation: Uses `e` and `s` as shorthand for table names to make the query more readable.*

---

### 5. Filtering and Aggregations

**Filter by specific employee:**
```sql
select * from employees e, salaries s 
where e.emp_no = s.emp_no and e.emp_no=10001 
order by s.to_date;
```
*Explanation: Shows the salary history for a single employee (ID: 10001).*

**Find maximum salary for an employee:**
```sql
select e.emp_no, max(salary) 
from employees e, salaries s 
where e.emp_no = s.emp_no and e.emp_no=10001 
group by e.emp_no;
```
*Explanation: Retrieves the highest salary ever recorded for employee 10001.*

**Salary statistics by job title:**
```sql
select t.title, max(s.salary), min(s.salary), avg(s.salary), std(s.salary) 
from salaries s, titles t 
where s.emp_no=t.emp_no 
group by t.title;
```
*Explanation: Calculates the maximum, minimum, average, and standard deviation of salaries for every job title in the company.*

---

### 6. Complex Joins and Subqueries

**Complex Relationship Join:**
```sql
select distinct d.dept_no, t.title 
from employees e, titles t, dept_emp de, departments d 
where e.emp_no=t.emp_no 
and e.emp_no=de.emp_no 
and de.dept_no=d.dept_no 
order by d.dept_no, t.title;
```
*Explanation: Lists the unique job titles present in each department by joining employees, titles, department assignments, and departments.*

**Subquery with HAVING:**
```sql
select count(*) from 
	(select e.emp_no, count(*) 
	from employees e inner join titles t 
	on e.emp_no=t.emp_no 
	group by e.emp_no 
	having count(*) > 2) tc;
```
*Explanation: First finds employees who have held more than two titles, then counts how many such employees exist.*

**List Department Managers:**
```sql
select d.dept_name, concat(e.first_name , ' ' ,e.last_name) 
from departments d, dept_manager dm, employees e 
where d.dept_no=dm.dept_no and dm.emp_no=e.emp_no;
```
*Explanation: Joins departments with their managers to display the department name and the manager's full name.*

**Find Duplicate Full Names:**
```sql
select concat(first_name , ' ' , last_name), count(*) 
from employees 
group by concat(first_name , last_name) 
having count(*) > 2;
```
*Explanation: Identifies cases where more than two employees share the exact same first and last name combination.*

---

## Knowledge Check: SQL Challenges

Test your skills by writing queries for the following questions. You can find the answers in the companion document `3_challenge_answers.md`.

1.  **Current Average Salary**: What is the average salary of all employees currently employed at the company? (Hint: Current employees have a `to_date` of `9999-01-01`).
2.  **Research Department Staff**: List the first and last names of all employees who have ever worked in the 'Research' department.
3.  **Department Manager Count**: Which departments have had more than 2 managers throughout their history? List the department name and the count.
4.  **Top Earning Titles**: Find the top 5 job titles with the highest average salary for current employees.
5.  **Gender Distribution by Dept**: For each department, show the count of male vs female employees.
6.  **Promotion History**: Identify employees who have held more than 3 different job titles during their tenure. List their employee number and the count of titles.
