-- ============================================================
-- RETAIL ANALYTICS PROJECT
-- SQL PHASE 1 - FOUNDATIONS & INTERMEDIATE SQL
-- 26 practice questions
-- Database: MySQL
-- ============================================================


-- Q01. Total revenue excluding cancelled orders
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status != 'Cancelled';


-- Q02. Average order value excluding cancelled orders
SELECT AVG(total_amount) AS average_order_value
FROM orders
WHERE order_status != 'Cancelled';


-- Q03. Count completed orders
SELECT COUNT(*) AS completed_orders
FROM orders
WHERE order_status = 'Completed';


-- Q04. Count unique customers with non-cancelled orders
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders
WHERE order_status != 'Cancelled';


-- Q05. Revenue by order status
SELECT
    order_status,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY order_status;


-- Q06. Revenue by customer
SELECT
    customer_id,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY customer_id;


-- Q07. Top 5 customers by revenue
SELECT
    customer_id,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;


-- Q08. Top 3 regions by revenue
SELECT
    o.region_id,
    r.region_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN regions r
    ON o.region_id = r.region_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.region_id, r.region_name
ORDER BY total_revenue DESC
LIMIT 3;


-- Q09. Top 5 products by quantity sold
SELECT
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 5;


-- Q10. Product revenue excluding cancelled orders
WITH product_revenue AS (
    SELECT
        oi.product_id,
        oi.quantity *
            (oi.unit_price - (oi.unit_price * oi.discount / 100)) AS revenue
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
)
SELECT
    pr.product_id,
    p.product_name,
    SUM(pr.revenue) AS total_revenue
FROM product_revenue pr
JOIN products p
    ON pr.product_id = p.product_id
GROUP BY pr.product_id, p.product_name
ORDER BY total_revenue DESC;


-- Q11. Top 5 customers by revenue with customer names
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS customer_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY customer_revenue DESC
LIMIT 5;


-- Q12. Top 5 employees by revenue
SELECT
    o.employee_id,
    e.first_name,
    e.last_name,
    SUM(o.total_amount) AS employee_revenue
FROM orders o
JOIN employees e
    ON o.employee_id = e.employee_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.employee_id, e.first_name, e.last_name
ORDER BY employee_revenue DESC
LIMIT 5;


-- Q13. Regional order and revenue summary
SELECT
    r.region_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_revenue
FROM orders o
JOIN regions r
    ON o.region_id = r.region_id
WHERE o.order_status != 'Cancelled'
GROUP BY r.region_name;


-- Q14. Products with at least 20 units sold and their revenue
SELECT
    oi.product_id,
    SUM(oi.quantity) AS total_quantity,
    SUM(
        oi.quantity *
        (oi.unit_price - (oi.unit_price * oi.discount / 100))
    ) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY oi.product_id
HAVING total_quantity >= 20;


-- Q15. Monthly revenue
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;


-- Q16. Month-over-month revenue change
WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status != 'Cancelled'
    GROUP BY YEAR(order_date), MONTH(order_date)
),
previous_revenue AS (
    SELECT
        year,
        month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY year, month
        ) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    year,
    month,
    total_revenue,
    previous_revenue,
    total_revenue - previous_revenue AS revenue_change,
    ((total_revenue - previous_revenue) / previous_revenue) * 100 AS growth
FROM previous_revenue;


-- Q17. Customers with at least 5 non-cancelled orders
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS non_cancelled_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.customer_id, c.first_name, c.last_name
HAVING non_cancelled_orders >= 5;


-- Q18. Next non-cancelled order date
SELECT
    order_id,
    order_date,
    total_amount,
    LEAD(order_date) OVER (
        ORDER BY order_date
    ) AS next_order_date
FROM orders
WHERE order_status != 'Cancelled';


-- Q19. Repeat customers
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.customer_id, c.first_name, c.last_name
HAVING order_count >= 2
ORDER BY order_count DESC;


-- Q20. First and last purchase date for each customer
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY customer_id;


-- Q21. Customers whose latest purchase was more than 180 days ago
WITH customer_orders AS (
    SELECT
        o.customer_id,
        c.first_name,
        c.last_name,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY o.customer_id, c.first_name, c.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    last_order_date,
    DATEDIFF(CURRENT_DATE(), last_order_date) AS days_since_last_order
FROM customer_orders
WHERE DATEDIFF(CURRENT_DATE(), last_order_date) > 180;


-- Q22. Order-status summary by payment mode
SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed,
    SUM(
        CASE
            WHEN order_status = 'Shipped' THEN 1
            ELSE 0
        END
    ) AS shipped,
    SUM(
        CASE
            WHEN order_status = 'Processing' THEN 1
            ELSE 0
        END
    ) AS processing,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY payment_mode;


-- Q23. Customers without a phone number
SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM customers
WHERE phone IS NULL;


-- Q24. Completed-order percentage by payment mode
WITH payment_summary AS (
    SELECT
        payment_mode,
        COUNT(*) AS total_orders,
        SUM(
            CASE
                WHEN order_status = 'Completed' THEN 1
                ELSE 0
            END
        ) AS completed_orders
    FROM orders
    WHERE order_status != 'Cancelled'
    GROUP BY payment_mode
)
SELECT
    payment_mode,
    total_orders,
    completed_orders,
    ROUND(
        (completed_orders / total_orders) * 100,
        2
    ) AS completed_percentage
FROM payment_summary;


-- Q25. Top 3 customers by revenue among customers with at least 2 orders
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        c.first_name,
        c.last_name,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_revenue
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY o.customer_id, c.first_name, c.last_name
    HAVING COUNT(o.order_id) >= 2
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT
    customer_id,
    first_name,
    last_name,
    order_count,
    total_revenue,
    revenue_rank
FROM ranking
WHERE revenue_rank <= 3;


-- Q26. Customers with at least 2 orders and above-average customer revenue
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        c.first_name,
        c.last_name,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_revenue
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY o.customer_id, c.first_name, c.last_name
    HAVING COUNT(o.order_id) >= 2
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
    WHERE total_revenue > (
        SELECT AVG(total_revenue)
        FROM customer_revenue
    )
)
SELECT
    customer_id,
    first_name,
    last_name,
    first_order_date,
    last_order_date,
    order_count,
    total_revenue,
    revenue_rank
FROM ranking
WHERE revenue_rank <= 3
ORDER BY revenue_rank, total_revenue DESC;


-- ============================================================
-- END OF SQL PHASE 1
-- ============================================================
