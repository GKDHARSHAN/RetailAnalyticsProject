-- ============================================================
-- RETAIL ANALYTICS PROJECT
-- SQL PHASE 4 - OPTIMIZATION & INTERVIEW FINISHING
-- Database: MySQL
-- ============================================================

-- ============================================================
-- 1. Logical execution order
-- ============================================================
-- FROM / JOIN
-- WHERE
-- GROUP BY
-- Aggregate functions
-- HAVING
-- SELECT
-- ORDER BY
-- LIMIT
--
-- Key interview rule:
-- WHERE filters individual rows before grouping.
-- HAVING filters groups after aggregation.

-- ============================================================
-- 2. WHERE vs ON with LEFT JOIN
-- ============================================================

-- Filter in ON: preserves unmatched left-table rows.
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed';

-- Filter in WHERE: removes rows that do not satisfy the right-table condition.
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed';

-- ============================================================
-- 3. EXISTS vs IN
-- ============================================================

-- IN: compare a value against a set returned by a subquery.
SELECT
    c.customer_id,
    c.first_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.order_status = 'Completed'
);

-- EXISTS: check whether at least one matching row exists.
SELECT
    c.customer_id,
    c.first_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);

-- ============================================================
-- 4. NOT IN + NULL safety
-- ============================================================
-- NOT IN can produce unexpected results when the subquery contains NULL.
-- NOT EXISTS is generally safer for anti-join logic.

SELECT
    c.customer_id,
    c.first_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- ============================================================
-- 5. Index fundamentals
-- ============================================================
-- Example indexes to investigate for this schema:

CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

-- General principles:
-- * Indexes help SQL locate rows without scanning the entire table.
-- * High-selectivity columns are often better candidates.
-- * Indexes have storage and write-maintenance costs.
-- * Do not create indexes blindly; verify with EXPLAIN.

-- ============================================================
-- 6. Composite index and leftmost-prefix example
-- ============================================================
-- Index:
-- (customer_id, order_date)
--
-- Efficient access patterns include:
--   customer_id = ?
--   customer_id = ? AND order_date >= ? AND order_date < ?
--
-- A query filtering only on order_date generally cannot seek efficiently
-- using the leading customer_id portion of this index.

-- ============================================================
-- 7. EXPLAIN
-- ============================================================

EXPLAIN
SELECT
    customer_id,
    SUM(total_amount) AS revenue
FROM orders
WHERE customer_id = 12345
GROUP BY customer_id;

-- Interview fields to inspect:
-- type
-- possible_keys
-- key
-- rows
-- Extra
--
-- type = ALL + key = NULL + very large rows estimate
-- is a common warning sign for a full table scan.

-- ============================================================
-- 8. JOIN performance
-- ============================================================

EXPLAIN
SELECT
    c.customer_id,
    c.first_name,
    SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.first_name;

-- Check whether orders.customer_id has an appropriate index,
-- especially when orders is the large table.

-- ============================================================
-- 9. CTE vs subquery
-- ============================================================
-- Neither is automatically faster.
-- Choose based on readability, optimizer behavior, and query structure.
-- Use EXPLAIN to compare actual plans.

-- ============================================================
-- 10. Window functions and filtering
-- ============================================================

WITH ranked_orders AS (
    SELECT
        o.*,
        LAG(total_amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_amount
    FROM orders o
)
SELECT *
FROM ranked_orders
WHERE previous_amount IS NOT NULL
  AND total_amount > previous_amount;

-- A window-function result is calculated after WHERE at the same query level,
-- so an outer query/CTE is used when filtering on the window result.

-- ============================================================
-- 11. NULL and aggregates
-- ============================================================

SELECT
    COUNT(*) AS row_count,
    COUNT(total_amount) AS non_null_amounts,
    SUM(total_amount) AS total_amount,
    AVG(total_amount) AS average_amount
FROM orders;

-- COUNT(*) counts rows.
-- COUNT(column) ignores NULL.
-- SUM/AVG ignore NULL values.
-- SUM can return NULL when there are no non-NULL values.
-- COALESCE can be used when a zero is required.

-- ============================================================
-- 12. Avoid functions on indexed date columns
-- ============================================================

-- Less index-friendly:
SELECT *
FROM orders
WHERE YEAR(order_date) = 2026;

-- Preferred range predicate:
SELECT *
FROM orders
WHERE order_date >= '2026-01-01'
  AND order_date < '2027-01-01';

-- ============================================================
-- 13. JOIN explosion / grain
-- ============================================================
-- orders is one row per order.
-- order_items can contain multiple rows per order.
--
-- Joining them multiplies order rows.
-- Therefore, summing an order-level measure such as orders.total_amount
-- after joining directly to order_items can inflate revenue.

-- Example of a potentially inflated calculation:
SELECT
    SUM(o.total_amount) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';

-- If an order worth 1000 has 3 item rows, the joined result contains
-- three copies of the 1000 order amount before aggregation.
--
-- Interview rule:
-- Always identify the grain of every table/CTE before joining and aggregating.

-- ============================================================
-- 14. Composite-index optimization example
-- ============================================================

-- Original:
SELECT *
FROM orders
WHERE YEAR(order_date) = 2026
  AND customer_id = 12345;

-- Rewritten:
SELECT *
FROM orders
WHERE customer_id = 12345
  AND order_date >= '2026-01-01'
  AND order_date < '2027-01-01';

-- With an index such as (customer_id, order_date), this matches
-- the leading equality predicate followed by a date range.

-- ============================================================
-- 15. Final interview mock - Q1
-- Top 2 customers per region by completed revenue, ties included.
-- ============================================================
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
SELECT *
FROM ranked
WHERE revenue_rank <= 2
ORDER BY region_id, revenue_rank, total_revenue DESC;

-- ============================================================
-- 16. Final interview mock - Q2
-- Latest completed order amount > previous completed order amount.
-- ============================================================
WITH completed_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        total_amount,
        LAG(total_amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_rank
    FROM orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    previous_amount
FROM completed_orders
WHERE latest_rank = 1
  AND previous_amount IS NOT NULL
  AND total_amount > previous_amount;

-- ============================================================
-- 17. Final interview mock - Q3
-- At least 3 completed orders but below the average completed
-- customer revenue within their region.
-- ============================================================
WITH customer_revenue AS (
    SELECT
        region_id,
        customer_id,
        COUNT(*) AS completed_orders,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY region_id, customer_id
),
region_average AS (
    SELECT
        region_id,
        AVG(total_revenue) AS avg_customer_revenue
    FROM customer_revenue
    GROUP BY region_id
)
SELECT
    cr.region_id,
    cr.customer_id,
    cr.completed_orders,
    cr.total_revenue,
    ra.avg_customer_revenue
FROM customer_revenue cr
JOIN region_average ra
    ON cr.region_id = ra.region_id
WHERE cr.completed_orders >= 3
  AND cr.total_revenue < ra.avg_customer_revenue;

-- ============================================================
-- 18. Final interview mock - Q4
-- Per region, customer with highest percentage of completed
-- regional revenue, ties included.
-- ============================================================
WITH customer_revenue AS (
    SELECT
        region_id,
        customer_id,
        SUM(total_amount) AS customer_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY region_id, customer_id
),
region_revenue AS (
    SELECT
        region_id,
        SUM(customer_revenue) AS region_revenue
    FROM customer_revenue
    GROUP BY region_id
),
percentages AS (
    SELECT
        cr.region_id,
        cr.customer_id,
        cr.customer_revenue,
        rr.region_revenue,
        cr.customer_revenue / rr.region_revenue * 100 AS revenue_percentage
    FROM customer_revenue cr
    JOIN region_revenue rr
        ON cr.region_id = rr.region_id
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region_id
            ORDER BY revenue_percentage DESC
        ) AS revenue_rank
    FROM percentages
)
SELECT *
FROM ranked
WHERE revenue_rank = 1;

-- ============================================================
-- 19. Final interview mock - Q5
-- Longest increasing streak of monthly completed revenue.
-- Gaps ignored. At least 3 months in the streak.
-- ============================================================
WITH monthly_revenue AS (
    SELECT
        customer_id,
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, YEAR(order_date), MONTH(order_date)
),
previous AS (
    SELECT
        *,
        LAG(total_revenue) OVER (
            PARTITION BY customer_id
            ORDER BY year, month
        ) AS previous_revenue
    FROM monthly_revenue
),
flagged AS (
    SELECT
        *,
        CASE
            WHEN previous_revenue IS NOT NULL
             AND total_revenue > previous_revenue
            THEN 1 ELSE 0
        END AS increasing_flag
    FROM previous
),
grouped AS (
    SELECT
        *,
        SUM(
            CASE WHEN increasing_flag = 0 THEN 1 ELSE 0 END
        ) OVER (
            PARTITION BY customer_id
            ORDER BY year, month
        ) AS streak_group
    FROM flagged
),
streak_counts AS (
    SELECT
        customer_id,
        streak_group,
        COUNT(*) AS streak_length
    FROM grouped
    WHERE increasing_flag = 1
    GROUP BY customer_id, streak_group
)
SELECT
    customer_id,
    MAX(streak_length) AS longest_increasing_streak
FROM streak_counts
GROUP BY customer_id
HAVING MAX(streak_length) >= 3;

-- ============================================================
-- END OF SQL PHASE 4
-- ============================================================
