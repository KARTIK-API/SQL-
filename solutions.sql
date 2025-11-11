 * solutions.sql
 * PostgreSQL-only solutions for LeetCode SQL 50

-- 1204. Last Person to Fit in the Bus
-- Topic: Window functions, cumulative sum
-- Given a queue with turn order and weights; bus limit 1000 kg -> last person who fits
WITH cte AS (
  SELECT person_name, weight, turn,
         SUM(weight) OVER (ORDER BY turn) AS total_weight
  FROM Queue
)
SELECT person_name
FROM cte
WHERE total_weight <= 1000
ORDER BY total_weight DESC
LIMIT 1;

-- 1907. Count Salary Categories
-- Topic: Aggregation with CASE
SELECT 'Low Salary' AS category, SUM(CASE WHEN income < 20000 THEN 1 ELSE 0 END) AS accounts_count
FROM Accounts
UNION ALL
SELECT 'Average Salary' AS category, SUM(CASE WHEN income >= 20000 AND income <= 50000 THEN 1 ELSE 0 END)
FROM Accounts
UNION ALL
SELECT 'High Salary' AS category, SUM(CASE WHEN income > 50000 THEN 1 ELSE 0 END)
FROM Accounts;

-- 626. Exchange Seats
-- Topic: Window functions, swapping every pair
SELECT id,
       CASE
         WHEN id % 2 = 0 THEN LAG(student) OVER (ORDER BY id)
         ELSE LEAD(student) OVER (ORDER BY id)
       END AS student
FROM Seat;

-- 1327. List the Products Ordered in a Period
-- Topic: JOIN, aggregation, HAVING
SELECT p.product_name, SUM(o.unit) AS unit
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE TO_CHAR(order_date, 'YYYY-MM') = '2020-02'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100;

-- 1484. Group Sold Products By The Date
-- Topic: Aggregation, string aggregation
SELECT sell_date,
       COUNT(DISTINCT product) AS num_sold,
       STRING_AGG(DISTINCT product, ',') AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;

-- 1341. Movie Rating (two-part)
-- Topic: Aggregation + subqueries + UNION ALL
(
  SELECT u.name AS result
  FROM Users u
  LEFT JOIN MovieRating mr ON u.user_id = mr.user_id
  GROUP BY u.name
  ORDER BY COUNT(mr.rating) DESC, u.name ASC
  LIMIT 1
)
UNION ALL
(
  SELECT m.title
  FROM Movies m
  LEFT JOIN MovieRating mr ON m.movie_id = mr.movie_id
  WHERE TO_CHAR(mr.created_at, 'YYYY-MM') = '2020-02'
  GROUP BY m.title
  ORDER BY AVG(mr.rating) DESC, m.title ASC
  LIMIT 1
);

-- 1321. Restaurant Growth
-- Topic: Window frames, rolling sum (last 7 days)
WITH daily AS (
  SELECT visited_on,
         SUM(amount) OVER (ORDER BY visited_on
                           RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW) AS amount,
         MIN(visited_on) OVER () AS day_1
  FROM Customer
)
SELECT visited_on, amount, ROUND(amount/7::numeric, 2) AS average_amount
FROM daily
WHERE visited_on >= day_1 + INTERVAL '6 days';

-- 602. Friend Requests II: Who Has the Most Friends
-- Topic: UNION ALL then aggregation
WITH cte AS (
  SELECT requester_id AS id FROM RequestAccepted
  UNION ALL
  SELECT accepter_id AS id FROM RequestAccepted
)
SELECT id, COUNT(*) AS num
FROM cte
GROUP BY id
ORDER BY num DESC
LIMIT 1;

-- 585. Investments in 2016
-- Topic: Filtering using grouped subqueries
SELECT ROUND(SUM(tiv_2016)::numeric, 2) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN (
    SELECT tiv_2015
    FROM insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) IN (
    SELECT lat, lon
    FROM insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
);

-- 181. Employees Earning More Than Their Managers
-- Topic: Self-join
SELECT e.name
FROM Employee e
JOIN Employee m ON e.managerId = m.id
WHERE e.salary > m.salary;

-- 1757. Recyclable and Low Fat Products
-- Topic: Filtering
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';

-- 584. Find Customer Referee
-- Topic: Simple WHERE with NULL handling
SELECT name
FROM Customer
WHERE referee_id IS DISTINCT FROM 2; -- covers NULL as well

-- 595. Big Countries
-- Topic: Filtering numeric columns
SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;

-- 1148. Article Views I
-- Topic: DISTINCT and self relation
SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY author_id;

-- 1683. Invalid Tweets
-- Topic: String length
SELECT tweet_id
FROM Tweets
WHERE CHAR_LENGTH(content) > 15;

-- 1378. Replace Employee ID With The Unique Identifier
-- Topic: JOIN to map IDs
SELECT eu.unique_id, e.name
FROM Employees e
LEFT JOIN EmployeeUNI eu ON e.id = eu.id;

-- 1068. Product Sales Analysis I
-- Topic: JOIN basic
SELECT p.product_name, s.year, s.price
FROM Sales s
LEFT JOIN Product p ON s.product_id = p.product_id;

-- 1581. Customer Who Visited but Did Not Make Any Transactions
-- Topic: Subquery NOT IN (distinct visit IDs)
SELECT customer_id, COUNT(*) AS count_no_trans
FROM Visits
WHERE visit_id NOT IN (
  SELECT DISTINCT visit_id FROM Transactions
)
GROUP BY customer_id;

-- 197. Rising Temperature
-- Topic: Self-join with date difference
SELECT w1.id
FROM Weather w1
JOIN Weather w2 ON w1.recordDate = w2.recordDate + INTERVAL '1 day'
WHERE w1.temperature > w2.temperature;

-- 1661. Average Time of Process per Machine
-- Topic: Aggregation on derived start/end timestamps
SELECT machine_id, ROUND(AVG(end_ts - start_ts)::numeric, 3) AS processing_time
FROM (
  SELECT machine_id, process_id,
         MAX(CASE WHEN activity_type = 'start' THEN timestamp END) AS start_ts,
         MAX(CASE WHEN activity_type = 'end' THEN timestamp END) AS end_ts
  FROM Activity
  GROUP BY machine_id, process_id
) sub
GROUP BY machine_id;

-- 577. Employee Bonus
-- Topic: LEFT JOIN with NULL handling
SELECT e.name, b.bonus
FROM Employee e
LEFT JOIN Bonus b ON e.empId = b.empId
WHERE b.bonus < 1000 OR b.bonus IS NULL;

-- 1280. Students and Examinations
-- Topic: JOIN + LEFT JOIN + COUNT
SELECT a.student_id, a.student_name, b.subject_name,
       COUNT(c.subject_name) AS attended_exams
FROM Students a
JOIN Subjects b ON 1=1
LEFT JOIN Examinations c
  ON a.student_id = c.student_id
  AND b.subject_name = c.subject_name
GROUP BY a.student_id, a.student_name, b.subject_name
ORDER BY a.student_id, b.subject_name;

-- 570. Managers with at Least 5 Direct Reports
-- Topic: GROUP BY + HAVING
SELECT name
FROM Employee
WHERE id IN (
  SELECT managerId
  FROM Employee
  GROUP BY managerId
  HAVING COUNT(*) >= 5
);

-- 1934. Confirmation Rate
-- Topic: Conditional aggregation with COALESCE and rounding
SELECT s.user_id,
       ROUND(
         COALESCE(
           SUM(CASE WHEN c.action = 'confirmed' THEN 1.0 ELSE 0 END) / NULLIF(COUNT(*),0), 0
         )::numeric, 2
       ) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON s.user_id = c.user_id
GROUP BY s.user_id;

-- 620. Not Boring Movies
-- Topic: Filtering with modulo, string inequality
SELECT *
FROM Cinema
WHERE (id % 2) <> 0
  AND description <> 'boring'
ORDER BY rating DESC;

-- 1251. Average Selling Price
-- Topic: Weighted average via SUM(price*units)/SUM(units)
SELECT p.product_id,
       ROUND(SUM(p.price * s.units) / NULLIF(SUM(s.units),0)::numeric, 2) AS average_price
FROM Prices p
LEFT JOIN UnitsSold s
  ON p.product_id = s.product_id
  AND s.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;

-- 1075. Project Employees I
-- Topic: AVG aggregation by project
SELECT p.project_id, ROUND(AVG(e.experience_years)::numeric, 2) AS average_years
FROM Project p
LEFT JOIN Employee e ON p.employee_id = e.employee_id
GROUP BY p.project_id;

-- 1633. Percentage of Users Attended a Contest
-- Topic: Percentage calculation using DISTINCT
SELECT r.contest_id,
       ROUND(COUNT(DISTINCT r.user_id) * 100.0 / NULLIF((SELECT COUNT(DISTINCT user_id) FROM Users),0)::numeric, 2) AS percentage
FROM Register r
GROUP BY r.contest_id
ORDER BY percentage DESC, r.contest_id ASC;

-- 1211. Queries Quality and Percentage
-- Topic: AVG and conditional percentages
SELECT query_name,
       ROUND(AVG(rating::numeric / position)::numeric, 2) AS quality,
       ROUND(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(rating)::numeric, 2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;

-- 1174. Immediate Food Delivery II
-- Topic: Subquery per-customer earliest order
SELECT ROUND(
  (SUM(CASE WHEN d.order_date = sub.min_order_date AND d.order_date = d.customer_pref_delivery_date THEN 1 ELSE 0 END)::numeric
   / NULLIF(COUNT(*)::numeric,0)) * 100.0, 2) AS immediate_percentage
FROM Delivery d
JOIN (
  SELECT customer_id, MIN(order_date) AS min_order_date
  FROM Delivery
  GROUP BY customer_id
) sub ON d.customer_id = sub.customer_id
AND d.order_date = sub.min_order_date;

-- 550. Game Play Analysis IV
-- Topic: With CTEs and fraction of players who returned next day
WITH login_date AS (
  SELECT player_id, MIN(event_date) AS first_login
  FROM Activity
  GROUP BY player_id
),
recent_login AS (
  SELECT player_id, first_login + INTERVAL '1 day' AS next_day
  FROM login_date
)
SELECT ROUND(
       ( (SELECT COUNT(DISTINCT player_id) FROM Activity a
          WHERE (a.player_id, a.event_date) IN (
            SELECT player_id, next_day FROM recent_login
          )
         )::numeric
         / NULLIF((SELECT COUNT(DISTINCT player_id) FROM Activity),0)::numeric
       )::numeric, 2) AS fraction;

-- 2356. Number of Unique Subjects Taught by Each Teacher
-- Topic: COUNT DISTINCT
SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;

-- 1141. User Activity for the Past 30 Days I
-- Topic: Date ranges and grouping
SELECT activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN (DATE '2019-07-27' - INTERVAL '29 days') AND DATE '2019-07-27'
GROUP BY activity_date;

-- 1070. Product Sales Analysis III
-- Topic: earliest year per product then select those rows
WITH first_year_sales AS (
  SELECT s.product_id, MIN(s.year) AS first_year
  FROM Sales s
  JOIN Product p ON s.product_id = p.product_id
  GROUP BY s.product_id
)
SELECT f.product_id, f.first_year, s.quantity, s.price
FROM first_year_sales f
JOIN Sales s ON f.product_id = s.product_id AND f.first_year = s.year;

-- 596. Classes More Than 5 Students
-- Topic: GROUP BY and HAVING
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(student) >= 5;

-- 1729. Find Followers Count
-- Topic: COUNT DISTINCT
SELECT user_id, COUNT(DISTINCT follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id ASC;

-- 619. Biggest Single Number
-- Topic: find largest number that appears exactly once
SELECT COALESCE((
  SELECT num
  FROM MyNumbers
  GROUP BY num
  HAVING COUNT(num) = 1
  ORDER BY num DESC
  LIMIT 1
), NULL) AS num;

-- 1045. Customers Who Bought All Products
-- Topic: Relational division using HAVING
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (
  SELECT COUNT(product_key) FROM Product
);

-- 1731. The Number of Employees Which Report to Each Employee
-- Topic: Self-join for reports
SELECT e1.employee_id, e1.name, COUNT(e2.employee_id) AS reports_count,
       ROUND(AVG(e2.age)::numeric, 0) AS average_age
FROM Employees e1
JOIN Employees e2 ON e1.employee_id = e2.reports_to
GROUP BY e1.employee_id, e1.name
HAVING COUNT(e2.employee_id) > 0
ORDER BY e1.employee_id;

-- 1789. Primary Department for Each Employee
-- Topic: Primary flag OR when only one department exists
SELECT employee_id, department_id
FROM Employee
WHERE primary_flag = 'Y'
UNION
SELECT employee_id, department_id
FROM Employee
GROUP BY employee_id, department_id
HAVING COUNT(employee_id) = 1;

-- 610. Triangle Judgement
-- Topic: Simple CASE expression
SELECT x, y, z,
  CASE WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes' ELSE 'No' END AS triangle
FROM Triangle;

-- 180. Consecutive Numbers
-- Topic: Using LEAD/LAG to detect runs
WITH cte AS (
  SELECT id, num,
         LEAD(num) OVER (ORDER BY id) AS next,
         LAG(num) OVER (ORDER BY id) AS prev
  FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte
WHERE num = next AND num = prev;

-- 1164. Product Price at a Given Date
-- Topic: Latest price <= given date or fallback
SELECT product_id, new_price AS price
FROM products
WHERE (product_id, change_date) IN (
  SELECT product_id, MAX(change_date)
  FROM products
  WHERE change_date <= DATE '2019-08-16'
  GROUP BY product_id
)
UNION ALL
SELECT product_id, 10 AS price
FROM products
WHERE product_id NOT IN (
  SELECT product_id FROM products WHERE change_date <= DATE '2019-08-16'
);

-- 1978. Employees Whose Manager Left the Company
-- Topic: NOT IN and salary filter
SELECT employee_id
FROM Employees
WHERE manager_id NOT IN (SELECT employee_id FROM Employees)
  AND salary < 30000
ORDER BY employee_id;

-- 185. Department Top Three Salaries
-- Topic: Window function DENSE_RANK
WITH RankedSalaries AS (
  SELECT e.id AS employee_id, e.name AS employee, e.salary, e.departmentId,
         DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS salary_rank
  FROM Employee e
)
SELECT d.name AS Department, r.employee, r.salary
FROM Department d
JOIN RankedSalaries r ON r.departmentId = d.id
WHERE r.salary_rank <= 3;

-- 1667. Fix Names in a Table
-- Topic: Capitalize first letter, lower rest (INITCAP handles many cases)
SELECT user_id, INITCAP(LOWER(name)) AS name
FROM Users
ORDER BY user_id;

-- 1527. Patients With a Condition
-- Topic: LIKE operator (pattern may vary)
SELECT patient_id, patient_name, conditions
FROM patients
WHERE conditions LIKE '%DIAB1%';

-- 196. Delete Duplicate Emails
-- Topic: DELETE using USING (Postgres) and self join
DELETE FROM Person p
USING Person q
WHERE p.id > q.id
  AND p.Email = q.Email;

-- 176. Second Highest Salary
-- Topic: Subquery with offset
SELECT (
  SELECT DISTINCT Salary
  FROM Employee
  ORDER BY Salary DESC
  OFFSET 1 LIMIT 1
) AS SecondHighestSalary;
