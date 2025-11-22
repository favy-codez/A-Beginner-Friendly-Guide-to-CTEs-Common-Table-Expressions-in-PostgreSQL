-- Create customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    referrer_id INT
);

-- Insert sample customers
INSERT INTO customers (name, city, referrer_id) VALUES
('Alice', 'Lagos', NULL),
('Bob', 'Abuja', 1),
('Chika', 'Port Harcourt', 2),
('David', 'Enugu', NULL);
-- Create orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    amount NUMERIC
);
-- Insert sample orders
INSERT INTO orders (customer_id, order_date, amount) VALUES
(1, '2025-01-05', 250),
(2, '2025-01-07', 120),
(1, '2025-02-10', 300),
(3, '2025-02-15', 150),
(4, '2025-03-01', 400);


-- Example: Get All Orders Above $100
-- Without a CTE:
SELECT order_id, customer_id, amount
FROM orders
WHERE amount > 100;

-- With a CTE:
WITH high_orders AS (
    SELECT order_id, customer_id, amount
    FROM orders
    WHERE amount > 100
)
SELECT *
FROM high_orders

-- We want to: Calculate total spending per customer and Get only customers who spent more than $500
WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
big_spenders AS (
    SELECT customer_id, total_spent
    FROM customer_totals
    WHERE total_spent > 500
)
SELECT *
FROM big_spenders;

-- Example : Number Each Customer’s Orders
WITH ordered AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS rn
    FROM orders
)
SELECT *
FROM ordered;

-- Example 2: Running Total Per Customer
WITH totals AS (
    SELECT customer_id, order_id, amount,
           SUM(amount) OVER (
             PARTITION BY customer_id
             ORDER BY order_date
           ) AS running_total
    FROM orders
)
SELECT * FROM totals;

-- Example 3: Previous and Next Order Amount
WITH deltas AS (
    SELECT customer_id, order_id, order_date, amount,
           LAG(amount) OVER (
             PARTITION BY customer_id ORDER BY order_date
           ) AS prev_amount,
           LEAD(amount) OVER (
             PARTITION BY customer_id ORDER BY order_date
           ) AS next_amount
    FROM orders
)
SELECT * FROM deltas;

-- Recursive CTEs: Referral Chains
-- Example: Who Referred Whom?
WITH RECURSIVE referral_chain AS (
    -- Start with customers who have no referrer
    SELECT customer_id, name, referrer_id
    FROM customers
    WHERE referrer_id IS NULL
UNION ALL
    -- Add people referred by those already in the chain
    SELECT c.customer_id, c.name, c.referrer_id
    FROM customers c
    JOIN referral_chain rc ON c.referrer_id = rc.customer_id
)
SELECT * FROM referral_chain;

-- Example 1: Replace NULL amounts with 0
WITH cleaned AS (
    SELECT order_id,
           COALESCE(amount, 0) AS safe_amount
    FROM orders
)
SELECT * FROM cleaned;

-- Example 2: Clean Customer Names
WITH cleaned AS (
    SELECT name,
           TRIM(LOWER(name)) AS clean_name
    FROM customers
)
SELECT * FROM cleaned;


-- Top 5 Customers Last Month
WITH monthly AS (
    SELECT customer_id, amount
    FROM orders
    WHERE EXTRACT(MONTH FROM order_date) = 2
),
customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM monthly
    GROUP BY customer_id
)
SELECT *
FROM customer_totals
ORDER BY total_spent DESC
LIMIT 5;