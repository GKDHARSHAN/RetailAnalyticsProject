-- ============================================================
-- RETAIL ANALYTICS PROJECT
-- SQL PHASE 2 - ADVANCED SQL
-- Database: MySQL
--
-- NOTE:
-- This file is reconstructed from the Phase 2 work preserved in the
-- conversation context. It intentionally focuses on the advanced
-- concepts and query patterns that were actually covered.
-- ============================================================


-- ============================================================
-- SECTION 1. ADVANCED JOINs & ANTI-JOINs
-- ============================================================

-- Q01. Customers who have placed at least one order
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Q02. Customers who have never placed an order
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Q03. Customers with at least one completed order
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);


-- Q04. Customers with no completed orders
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);


-- Q05. Customers who have both completed and cancelled orders
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)
AND EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Cancelled'
);


-- Q06. Customers whose every order is completed
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status <> 'Completed'
);


-- Q07. Customers who have orders but no cancelled orders
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Cancelled'
);


-- Q08. Regions with no completed orders
SELECT
    r.region_id,
    r.region_name
FROM regions r
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.region_id = r.region_id
      AND o.order_status = 'Completed'
);


-- ============================================================
-- SECTION 2. EXISTS vs IN
-- ============================================================

-- Q09. Customers with at least one completed order using IN
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.order_status = 'Completed'
);


-- Q10. Same requirement using EXISTS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);


-- Q11. Customers with no orders using NOT IN
-- Use with caution if the subquery can contain NULL.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.customer_id IS NOT NULL
);


-- Q12. Safer anti-join version using NOT EXISTS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- ============================================================
-- SECTION 3. LEFT JOIN + ANTI-JOIN PATTERNS
-- ============================================================

-- Q13. Customers with no orders using LEFT JOIN
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- Q14. Customers with no completed orders using LEFT JOIN
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
WHERE o.order_id IS NULL;


-- ============================================================
-- SECTION 4. WHERE vs ON WITH LEFT JOIN
-- ============================================================

-- Q15. Filter completed orders in ON.
-- All customers remain, including customers with no completed orders.
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed';


-- Q16. Filter completed orders in WHERE.
-- Unmatched customers are removed because o.order_status is NULL.
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed';


-- ============================================================
-- SECTION 5. MULTI-TABLE JOIN ANALYSIS
-- ============================================================

-- Q17. Completed revenue by region
SELECT
    r.region_id,
    r.region_name,
    SUM(o.total_amount) AS completed_revenue
FROM regions r
JOIN orders o
    ON r.region_id = o.region_id
WHERE o.order_status = 'Completed'
GROUP BY r.region_id, r.region_name;


-- Q18. Completed revenue by customer and region
SELECT
    o.region_id,
    r.region_name,
    o.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS completed_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN regions r
    ON o.region_id = r.region_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.region_id,
    r.region_name,
    o.customer_id,
    c.first_name,
    c.last_name;


-- Q19. Completed product quantity by customer
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.customer_id,
    c.first_name,
    c.last_name,
    oi.product_id,
    p.product_name;


-- ============================================================
-- SECTION 6. GROUPING + HAVING + SUBQUERIES
-- ============================================================

-- Q20. Customers with at least 3 completed orders
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(*) AS completed_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id, c.first_name, c.last_name
HAVING COUNT(*) >= 3;


-- Q21. Customers whose completed revenue is above average
-- customer completed revenue
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_revenue
FROM customer_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM customer_revenue
);


-- Q22. Regions whose completed revenue is above average regional revenue
WITH region_revenue AS (
    SELECT
        region_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY region_id
)
SELECT
    region_id,
    total_revenue
FROM region_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM region_revenue
);


-- ============================================================
-- SECTION 7. CORRELATED SUBQUERIES
-- ============================================================

-- Q23. Customers whose completed revenue is greater than
-- the average completed order value for that customer.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
      AND o.total_amount > (
          SELECT AVG(o2.total_amount)
          FROM orders o2
          WHERE o2.customer_id = o.customer_id
            AND o2.order_status = 'Completed'
      )
);


-- Q24. Latest completed order for each customer using a correlated subquery
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.total_amount
FROM orders o
WHERE o.order_status = 'Completed'
  AND o.order_date = (
      SELECT MAX(o2.order_date)
      FROM orders o2
      WHERE o2.customer_id = o.customer_id
        AND o2.order_status = 'Completed'
  );


-- ============================================================
-- SECTION 8. WINDOW FUNCTIONS
-- ============================================================

-- Q25. Previous completed order amount for each customer
WITH completed_orders AS (
    SELECT
        o.*,
        LAG(total_amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_amount
    FROM orders o
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    previous_amount
FROM completed_orders;


-- Q26. Next completed order date for each customer
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS next_order_date
FROM orders
WHERE order_status = 'Completed';


-- Q27. Rank customers by completed revenue
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_revenue,
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_revenue;


-- Q28. Top 3 customers per region by completed revenue
WITH customer_revenue AS (
    SELECT
        region_id,
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY region_id, customer_id
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region_id
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT
    region_id,
    customer_id,
    total_revenue,
    revenue_rank
FROM ranked
WHERE revenue_rank <= 3;


-- ============================================================
-- SECTION 9. MONTHLY ANALYSIS
-- ============================================================

-- Q29. Monthly completed revenue by customer
SELECT
    customer_id,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY
    customer_id,
    YEAR(order_date),
    MONTH(order_date)
ORDER BY customer_id, year, month;


-- Q30. Month-over-month completed revenue by customer
WITH monthly_revenue AS (
    SELECT
        customer_id,
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY
        customer_id,
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    customer_id,
    year,
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        PARTITION BY customer_id
        ORDER BY year, month
    ) AS previous_month_revenue
FROM monthly_revenue;


-- ============================================================
-- SECTION 10. CONDITIONAL AGGREGATION
-- ============================================================

-- Q31. Customer order-status summary
SELECT
    customer_id,
    SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status = 'Shipped' THEN 1 ELSE 0 END) AS shipped_orders,
    SUM(CASE WHEN order_status = 'Processing' THEN 1 ELSE 0 END) AS processing_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders
GROUP BY customer_id;


-- Q32. Customer revenue split by status
SELECT
    customer_id,
    SUM(CASE
            WHEN order_status = 'Completed'
            THEN total_amount ELSE 0
        END) AS completed_revenue,
    SUM(CASE
            WHEN order_status = 'Cancelled'
            THEN total_amount ELSE 0
        END) AS cancelled_revenue,
    SUM(CASE
            WHEN order_status = 'Shipped'
            THEN total_amount ELSE 0
        END) AS shipped_revenue
FROM orders
GROUP BY customer_id;


-- ============================================================
-- SECTION 11. IMPORTANT INTERVIEW PATTERNS
-- ============================================================

-- Pattern A: "At least one" -> EXISTS
-- Pattern B: "None" -> NOT EXISTS
-- Pattern C: "Every row satisfies condition" ->
--           EXISTS + NOT EXISTS(disqualifying row)
-- Pattern D: "Top N per group" -> DENSE_RANK / ROW_NUMBER
-- Pattern E: "Previous row" -> LAG
-- Pattern F: "Next row" -> LEAD
-- Pattern G: "Above average" -> aggregate CTE + AVG
-- Pattern H: "No matching records" -> LEFT JOIN + IS NULL or NOT EXISTS


-- ============================================================
-- END OF SQL PHASE 2
-- ============================================================
