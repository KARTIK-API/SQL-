# 🧠 SQL LeetCode Solutions

A comprehensive collection of **LeetCode SQL problem solutions** with clean and efficient queries.  
All solutions are written for **PostgreSQL / MySQL compatibility**, optimized for readability and reusability.

---

## 📁 Structure
Each problem follows this format:

```
Problem Number - Problem Title
```
followed by the corresponding **SQL query**.

---

## 🧩 SQL Solutions

### 1757. Recyclable and Low Fat Products
```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
AND recyclable = 'Y';
```

---

### 584. Find Customer Referee
```sql
SELECT name 
FROM Customer 
WHERE referee_id != 2 OR referee_id IS NULL;
```

---

### 595. Big Countries
```sql
SELECT name, population, area
FROM World
WHERE area >= 3000000
OR population >= 25000000;
```

---

### 1148. Article Views I
```sql
SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY author_id;
```

---

### 1683. Invalid Tweets
```sql
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;
```

---

### 1378. Replace Employee ID With The Unique Identifier
```sql
SELECT unique_id, name
FROM Employees e
LEFT JOIN EmployeeUNI eu
ON e.id = eu.id;
```

---

### 1068. Product Sales Analysis I
```sql
SELECT product_name, year, price
FROM Sales s
LEFT JOIN Product p
ON s.product_id = p.product_id;
```

---

### 1581. Customer Who Visited but Did Not Make Any Transactions
```sql
SELECT customer_id, COUNT(*) AS count_no_trans
FROM Visits 
WHERE visit_id NOT IN (SELECT DISTINCT visit_id FROM Transactions)
GROUP BY customer_id;
```

---

### 197. Rising Temperature
```sql
-- MySQL version
SELECT w1.id 
FROM Weather w1, Weather w2
WHERE DATEDIFF(w1.recordDate, w2.recordDate) = 1
AND w1.temperature > w2.temperature;

-- OR (PostgreSQL version)
SELECT w1.id
FROM Weather w1, Weather w2
WHERE w1.temperature > w2.temperature
AND w1.recordDate = w2.recordDate + INTERVAL '1 day';
```

---

### 1661. Average Time of Process per Machine
```sql
SELECT machine_id, ROUND(AVG(end - start), 3) AS processing_time
FROM (
  SELECT machine_id, process_id, 
         MAX(CASE WHEN activity_type = 'start' THEN timestamp END) AS start,
         MAX(CASE WHEN activity_type = 'end' THEN timestamp END) AS end
  FROM Activity 
  GROUP BY machine_id, process_id
) AS subq
GROUP BY machine_id;
```

---

### 577. Employee Bonus
```sql
SELECT name, bonus
FROM Employee e
LEFT JOIN Bonus b
ON e.empId = b.empId
WHERE bonus < 1000 OR bonus IS NULL;
```

---

### 1280. Students and Examinations
```sql
SELECT a.student_id, a.student_name, b.subject_name, COUNT(c.subject_name) AS attended_exams
FROM Students a
JOIN Subjects b
LEFT JOIN Examinations c
ON a.student_id = c.student_id
AND b.subject_name = c.subject_name
GROUP BY 1, 3
ORDER BY 1, 3;
```

---

### 570. Managers with at Least 5 Direct Reports
```sql
SELECT name 
FROM Employee 
WHERE id IN (
  SELECT managerId 
  FROM Employee 
  GROUP BY managerId 
  HAVING COUNT(*) >= 5
);
```

---

### 1934. Confirmation Rate
```sql
SELECT 
  s.user_id, 
  ROUND(
    COALESCE(SUM(CASE WHEN ACTION = 'confirmed' THEN 1 END) / COUNT(*), 0), 2
  ) AS confirmation_rate 
FROM Signups s 
LEFT JOIN Confirmations c 
ON s.user_id = c.user_id 
GROUP BY s.user_id;
```

---

### 620. Not Boring Movies
```sql
SELECT *
FROM Cinema
WHERE id % 2 <> 0 
AND description <> 'boring'
ORDER BY rating DESC;
```

---

### 1251. Average Selling Price
```sql
SELECT p.product_id, 
  ROUND(SUM(price * units) / SUM(units), 2) AS average_price
FROM Prices p
LEFT JOIN UnitsSold s
ON p.product_id = s.product_id
AND purchase_date BETWEEN start_date AND end_date
GROUP BY p.product_id;
```

---

### 1075. Project Employees I
```sql
SELECT project_id, ROUND(AVG(experience_years), 2) AS average_years
FROM Project p 
LEFT JOIN Employee e
ON p.employee_id = e.employee_id
GROUP BY project_id;
```

---

## ⚡ How to Use
1. Clone this repo:
   ```bash
   git clone https://github.com/<your-username>/sql-leetcode-solutions.git
   ```
2. Open `README.md` or copy specific queries for reference.
3. Compatible with **MySQL**, **PostgreSQL**, and **SQLite** (minor syntax changes may apply).

---

## 🧾 Notes
- Queries are formatted and optimized for clarity.
- Multiple valid solutions are included where applicable, clearly marked with `-- OR` comments to show alternative query approaches.
- All queries are tested on LeetCode using MySQL; PostgreSQL-compatible versions are provided where needed.
- Ideal for interview prep, SQL learning, and backend query logic improvement.

---

## 👤 Author
**Kartik**  
📍 Passionate about SQL, Data Analysis, and backend logic design.  
💡 Contributions and improvements are always welcome!

---

## ⭐ Contribute
If you have better solutions or PostgreSQL conversions, submit a pull request.

---
