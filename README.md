# SQL Practice Question Solutions

> **Please make sure you attempt the questions on your own before looking at these solutions.**  
> To view the full list of questions, check the documentation here:  
> 👉 [View Documentation](https://medium.com/@ezeliorafavour/a-beginner-friendly-guide-to-ctes-common-table-expressions-in-postgresql-bf5f31416b7a)

---

## Solution 1: Customers Who Spent More Than $300
```sql
WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_totals
WHERE total_spent > 300;
```
---
## Solution 2: Most Recent Order Per Customer
```
WITH ranked_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM orders
)
SELECT *
FROM ranked_orders
WHERE rn = 1;
```
---
## Solution 3: Running Total of Spending Per Customer
```
WITH running_totals AS (
    SELECT customer_id, order_id, amount,
           SUM(amount) OVER (
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS cumulative_total
    FROM orders
)
SELECT *
FROM running_totals;
```
--- 
## Solution 4: Clean Customer Names
```
(lowercase → remove spaces → replace NULL with "unknown")

WITH cleaned_names AS (
    SELECT customer_id,
           COALESCE(TRIM(LOWER(name)), 'unknown') AS clean_name
    FROM customers
)
SELECT *
FROM cleaned_names;
```
---
## Solution 5: Customer Who Spent the Most in February
```
WITH feb_orders AS (
    SELECT customer_id, amount
    FROM orders
    WHERE EXTRACT(MONTH FROM order_date) = 2
),
customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM feb_orders
    GROUP BY customer_id
)
SELECT *
FROM customer_totals
ORDER BY total_spent DESC
LIMIT 1;
```
