-- ============================================================
-- RETAIL ANALYTICS PROJECT
-- SQL PHASE 3 - INTERVIEW SQL
-- 10 advanced interview questions
-- Database: MySQL
-- ============================================================

-- Q01. Customers with at least one order where 100% of their orders are cancelled
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
JOIN customer_orders co
    ON c.customer_id = co.customer_id
WHERE co.total_orders > 0
  AND co.total_orders = co.cancelled_orders;

-- Q02. Second-highest completed spending customer, including ties
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_revenue
)
SELECT *
FROM ranked
WHERE revenue_rank = 2;

-- Q03. Customers with at least 3 orders and every order completed
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE (
    SELECT COUNT(*)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) >= 3
AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status <> 'Completed'
);

-- Q04. Customers whose latest completed order amount is greater than their previous completed order
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

-- Q05. Customers whose completed monthly revenue increased in every consecutive active month
-- Gaps in calendar months are ignored.
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
comparison AS (
    SELECT
        *,
        LAG(total_revenue) OVER (
            PARTITION BY customer_id
            ORDER BY year, month
        ) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    customer_id
FROM comparison
GROUP BY customer_id
HAVING COUNT(*) >= 2
   AND SUM(
        CASE
            WHEN previous_revenue IS NOT NULL
             AND total_revenue <= previous_revenue
            THEN 1 ELSE 0
        END
   ) = 0;

-- Q06. Customers whose latest active month revenue is greater than their average active-month revenue
-- Requires at least 2 active months.
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
stats AS (
    SELECT
        *,
        AVG(total_revenue) OVER (PARTITION BY customer_id) AS avg_monthly_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY year DESC, month DESC
        ) AS latest_rank
    FROM monthly_revenue
)
SELECT
    customer_id,
    total_revenue AS latest_month_revenue,
    avg_monthly_revenue
FROM stats
WHERE latest_rank = 1
  AND total_revenue > avg_monthly_revenue;

-- Q07. Top 2 customers per region by percentage of region completed revenue
-- Ties included.
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
WHERE revenue_rank <= 2;

-- Q08. Longest consecutive increasing streak of monthly completed revenue
-- Calendar gaps are ignored; streak is based on active months.
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

-- Q09. Customers with at least 3 categories and the category with highest total quantity
-- Ties included.
WITH customer_category_quantity AS (
    SELECT
        o.customer_id,
        p.category_id,
        SUM(oi.quantity) AS total_quantity
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id, p.category_id
),
category_count AS (
    SELECT
        customer_id,
        COUNT(*) AS category_count
    FROM customer_category_quantity
    GROUP BY customer_id
    HAVING COUNT(*) >= 3
),
ranked AS (
    SELECT
        ccq.*,
        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY total_quantity DESC
        ) AS quantity_rank
    FROM customer_category_quantity ccq
    JOIN category_count cc
        ON ccq.customer_id = cc.customer_id
)
SELECT
    customer_id,
    category_id,
    total_quantity
FROM ranked
WHERE quantity_rank = 1;

-- Q10. Per-region customer with greatest improvement from first to latest active month
WITH monthly_revenue AS (
    SELECT
        region_id,
        customer_id,
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY region_id, customer_id, YEAR(order_date), MONTH(order_date)
),
ranked_months AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY year, month
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY year DESC, month DESC
        ) AS latest_rank
    FROM monthly_revenue
),
customer_improvement AS (
    SELECT
        region_id,
        customer_id,
        MAX(CASE WHEN first_rank = 1 THEN total_revenue END) AS first_revenue,
        MAX(CASE WHEN latest_rank = 1 THEN total_revenue END) AS latest_revenue
    FROM ranked_months
    GROUP BY region_id, customer_id
),
improvement AS (
    SELECT
        *,
        latest_revenue - first_revenue AS improvement
    FROM customer_improvement
),
ranked_regions AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region_id
            ORDER BY improvement DESC
        ) AS region_rank
    FROM improvement
)
SELECT *
FROM ranked_regions
WHERE region_rank = 1;

-- ============================================================
-- END OF SQL PHASE 3
-- ============================================================
