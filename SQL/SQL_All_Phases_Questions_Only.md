# Retail Analytics Project — SQL Interview Practice
## Questions Only — All Phases

> **Purpose:** Practice the SQL problems without seeing the solutions.
> This file contains questions only; no SQL answers are included.

---

# PHASE 1 — FOUNDATIONS & INTERMEDIATE SQL

### Q01
Calculate the total revenue excluding cancelled orders.

### Q02
Calculate the average order value excluding cancelled orders.

### Q03
Count the number of completed orders.

### Q04
Count the number of unique customers who have placed non-cancelled orders.

### Q05
Calculate revenue by order status.

### Q06
Calculate total revenue by customer, excluding cancelled orders.

### Q07
Find the top 5 customers by revenue, excluding cancelled orders.

### Q08
Find the top 3 regions by revenue, excluding cancelled orders.

### Q09
Find the top 5 products by quantity sold.

### Q10
Calculate product revenue excluding cancelled orders, accounting for quantity, unit price, and discount.

### Q11
Find the top 5 customers by revenue and display their names.

### Q12
Find the top 5 employees by revenue.

### Q13
Create a regional order and revenue summary showing total orders, total revenue, and average revenue.

### Q14
Find products with at least 20 units sold and show their total revenue.

### Q15
Calculate monthly revenue excluding cancelled orders.

### Q16
Calculate month-over-month revenue change and revenue growth percentage.

### Q17
Find customers with at least 5 non-cancelled orders.

### Q18
For each non-cancelled order, find the next non-cancelled order date.

### Q19
Find repeat customers who have placed at least 2 non-cancelled orders.

### Q20
Calculate revenue by payment mode, excluding cancelled orders.

### Q21
Calculate the average order value by payment mode, excluding cancelled orders.

### Q22
Create an order-status summary by payment mode showing total orders, completed orders, shipped orders, processing orders, and total revenue.

### Q23
Find customers who do not have a phone number.

### Q24
Calculate the percentage of orders that are completed for each payment mode, excluding cancelled orders.

### Q25
Find the top 3 customers by revenue among customers with at least 2 non-cancelled orders.

### Q26
Find customers with at least 2 non-cancelled orders whose revenue is above the average customer revenue, and rank them by revenue.

---

# PHASE 2 — ADVANCED SQL

## Section 1 — Advanced JOINs & Anti-JOINs

### Q01
Find customers who have placed at least one order.

### Q02
Find customers who have never placed an order.

### Q03
Find customers who have at least one completed order.

### Q04
Find customers who have no completed orders.

### Q05
Find customers who have both completed and cancelled orders.

### Q06
Find customers who have placed at least one order and whose every order is completed.

### Q07
Find customers who have orders but no cancelled orders.

### Q08
Find regions with no completed orders.

## Section 2 — EXISTS vs IN

### Q09
Find customers with at least one completed order using `IN`.

### Q10
Find customers with at least one completed order using `EXISTS`.

### Q11
Find customers with no orders using `NOT IN`, while handling possible NULL values safely.

### Q12
Find customers with no orders using the safer `NOT EXISTS` anti-join approach.

## Section 3 — LEFT JOIN & Anti-JOIN Patterns

### Q13
Find customers with no orders using a `LEFT JOIN`.

### Q14
Find customers with no completed orders using a `LEFT JOIN`.

## Section 4 — WHERE vs ON with LEFT JOIN

### Q15
Using a `LEFT JOIN`, return all customers while matching only their completed orders.

### Q16
Using a `LEFT JOIN`, return only customers who have completed orders by applying the completed-order filter in the `WHERE` clause.

## Section 5 — Multi-Table JOIN Analysis

### Q17
Calculate completed revenue by region.

### Q18
Calculate completed revenue by customer and region.

### Q19
Calculate completed product quantity by customer.

## Section 6 — GROUP BY, HAVING & Subqueries

### Q20
Find customers with at least 3 completed orders.

### Q21
Find customers whose completed revenue is above the average completed customer revenue.

### Q22
Find regions whose completed revenue is above the average regional completed revenue.

## Section 7 — Correlated Subqueries

### Q23
Find customers who have at least one completed order whose amount is greater than that customer's average completed order value.

### Q24
Find the latest completed order for each customer using a correlated subquery.

## Section 8 — Window Functions

### Q25
For each customer, show the previous completed order amount.

### Q26
For each customer, show the next completed order date.

### Q27
Rank customers by completed revenue.

### Q28
Find the top 3 customers per region by completed revenue.

## Section 9 — Monthly Analysis

### Q29
Calculate monthly completed revenue for each customer.

### Q30
Calculate month-over-month completed revenue for each customer.

## Section 10 — Conditional Aggregation

### Q31
Create a customer order-status summary showing completed, shipped, processing, and cancelled orders.

### Q32
Create a customer revenue split by order status.

---

# PHASE 3 — INTERVIEW SQL

### Q01
Find customers who have placed at least one order where 100% of their orders are cancelled.

### Q02
Find the second-highest customer by completed spending, including ties.

### Q03
Find customers with at least 3 orders where every order is completed.

### Q04
Find customers whose latest completed order amount is greater than their previous completed order amount.

### Q05
Find customers whose completed monthly revenue increased in every consecutive active month. Ignore gaps in calendar months.

### Q06
Find customers whose latest active-month completed revenue is greater than their average active-month revenue. Require at least 2 active months.

### Q07
For each region, find the top 2 customers by percentage contribution to the region's completed revenue. Include ties.

### Q08
Find the longest consecutive increasing streak of monthly completed revenue for each customer. Ignore calendar-month gaps and return customers with a streak of at least 3 months.

### Q09
Find customers who have purchased from at least 3 categories and identify the category with the highest total quantity purchased. Include ties.

### Q10
For each region, find the customer with the greatest improvement between their first and latest active month's completed revenue. Include ties.

---

# PHASE 4 — SQL OPTIMIZATION & INTERVIEW FINISHING

## Section 1 — Logical Query Execution

### Q01
Explain the logical execution order of a SQL query containing `FROM`, `JOIN`, `WHERE`, `GROUP BY`, aggregates, `HAVING`, `SELECT`, `ORDER BY`, and `LIMIT`.

### Q02
Explain why `WHERE` filters rows while `HAVING` filters groups.

## Section 2 — WHERE vs ON

### Q03
Explain the difference between putting a right-table filter in the `ON` clause versus the `WHERE` clause of a `LEFT JOIN`.

### Q04
Given a `LEFT JOIN` between customers and orders, return all customers while matching only completed orders.

### Q05
Given the same `LEFT JOIN`, return only customers with completed orders.

## Section 3 — EXISTS vs IN

### Q06
Find customers who have at least one completed order using `IN`.

### Q07
Find customers who have at least one completed order using `EXISTS`.

### Q08
Explain when `EXISTS` is preferable to `IN` for existence checks.

## Section 4 — NOT IN & NULL

### Q09
Explain why `NOT IN` can produce unexpected results when the subquery contains `NULL`.

### Q10
Rewrite a customer anti-join using `NOT EXISTS` so that NULL behavior does not cause the classic `NOT IN` problem.

## Section 5 — Indexes

### Q11
Explain what a database index is and how it helps a query locate rows.

### Q12
Explain why high-selectivity columns are often good candidates for indexes.

### Q13
Explain why an index is not automatically beneficial for every column.

### Q14
For a large `orders` table, identify an appropriate index for queries that frequently filter by `customer_id`.

## Section 6 — Composite Indexes

### Q15
For queries that filter by `customer_id` and an `order_date` range, design an appropriate composite index.

### Q16
Explain why column order matters in a composite index.

### Q17
Given an index on `(customer_id, order_date)`, identify which of the following types of predicates can efficiently use the index:
- `customer_id = ...`
- `customer_id = ... AND order_date >= ...`
- `order_date >= ...` only
- the same predicates written in a different order in the `WHERE` clause

## Section 7 — EXPLAIN

### Q18
Use `EXPLAIN` to investigate a query that filters and aggregates orders by customer.

### Q19
Interpret a plan where `type = ALL`, `key = NULL`, and the estimated number of rows is very large.

### Q20
Identify the main performance concerns you would investigate when a query scans millions of rows.

## Section 8 — JOIN Performance

### Q21
Identify which join columns should be indexed when joining customers to orders on `customer_id`.

### Q22
Explain why indexing the join column on the large `orders` table can be important.

## Section 9 — CTE vs Subquery

### Q23
Explain whether a CTE is inherently faster than a subquery.

### Q24
Explain when you would choose a CTE over a subquery.

### Q25
Explain how `EXPLAIN` can be used to compare different query structures.

## Section 10 — Window Functions

### Q26
For each customer, retrieve the previous order amount using `LAG()`.

### Q27
Explain what `PARTITION BY customer_id` does inside a window function.

### Q28
Explain why a window-function result generally needs an outer query or CTE when you want to filter on that result.

## Section 11 — NULL & Aggregates

### Q29
Explain the difference between `COUNT(*)` and `COUNT(column)` when NULL values are present.

### Q30
Explain how `SUM(column)` behaves when some values are NULL.

### Q31
Explain what happens when an aggregate such as `SUM()` has no non-NULL values.

### Q32
Show how `COALESCE()` can be used when an aggregate result should be returned as zero instead of NULL.

## Section 12 — Date Filtering & Indexes

### Q33
Explain why `WHERE YEAR(order_date) = 2026` can make efficient index usage harder.

### Q34
Rewrite a year-based date filter so that it can use an index on `order_date` more effectively.

## Section 13 — JOIN Explosion & Grain

### Q35
Explain what happens to the number of rows when an `orders` table is joined to `order_items`.

### Q36
Explain why joining `orders` to `order_items` and then summing `orders.total_amount` can inflate revenue.

### Q37
Given an order worth 1000 with 3 order-item rows, explain what happens to the order amount after the join.

### Q38
Explain why identifying the grain of every table or CTE is important before joining and aggregating.

## Section 14 — Composite-Index Query Optimization

### Q39
Optimize a query that filters orders using:
`YEAR(order_date) = 2026`
and
`customer_id = 12345`,
assuming an index exists on `(customer_id, order_date)`.

---

# PHASE 4 — FINAL SQL MOCK INTERVIEW

### Mock Q01
Find the top 2 customers per region by completed revenue, including ties.

### Mock Q02
Find customers whose latest completed order amount is greater than their previous completed order amount.

### Mock Q03
Find customers with at least 3 completed orders whose completed revenue is below the average completed customer revenue within their region.

### Mock Q04
For each region, find the customer with the highest percentage contribution to completed regional revenue, including ties.

### Mock Q05
Find the longest increasing streak of monthly completed revenue for each customer, ignoring calendar gaps, and require a streak of at least 3 months.

---

# END — QUESTIONS ONLY
