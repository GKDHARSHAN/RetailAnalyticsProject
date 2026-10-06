# Retail Analytics Project

An end-to-end **Retail Analytics & Business Intelligence** project built
using Python, MySQL, Power Query, DAX, and Power BI.

The project transforms retail transaction data into an interactive
five-page analytical report covering sales, products, regions,
customers, employees, returns, and payments.

------------------------------------------------------------------------

## 📌 Project Overview

This project simulates a retail business environment with transactional
data across customers, products, orders, order items, employees,
regions, returns, suppliers, and payments.

The solution follows an end-to-end analytics workflow:

``` text
Python / Faker
      ↓
Synthetic Retail Data
      ↓
MySQL Database
      ↓
SQL Analysis & Validation
      ↓
Power Query
      ↓
Star Schema
      ↓
DAX Measures
      ↓
Power BI
      ↓
5-Page Interactive Dashboard
```

------------------------------------------------------------------------

## 🎯 Business Problem

Retail businesses generate large volumes of transactional data across
products, customers, orders, employees, regions, payments, and returns.

Without an integrated analytical solution, it can be difficult to:

-   Monitor revenue and order performance
-   Identify high-performing products and categories
-   Understand regional revenue contribution
-   Analyze customer and employee performance
-   Track return behavior
-   Monitor payment outcomes
-   Analyze trends over time

This project converts raw retail transaction data into a structured BI
solution that enables stakeholders to explore these areas through
interactive dashboards.

------------------------------------------------------------------------

## 💡 Business Objectives

The project focuses on:

-   Monitoring revenue and order performance
-   Measuring average order value
-   Analyzing product, brand, and category performance
-   Identifying top-performing products
-   Measuring regional revenue contribution
-   Analyzing customer purchasing behavior
-   Evaluating employee performance
-   Monitoring return volume and returned-item revenue
-   Analyzing payment modes and payment statuses
-   Tracking revenue and return trends over time

------------------------------------------------------------------------

## 🏗️ Project Architecture

### End-to-End Architecture

![Project Architecture](Docs/architecture.png)

### Power BI Data Model

![Power BI Data Model](Docs/data_model.png)

The Power BI semantic model follows a **star-schema approach** with
shared dimensions filtering independent fact tables.

### Fact Tables

-   **FactSales** --- order-item level sales transactions
-   **FactReturns** --- returned order items
-   **FactPayments** --- payment transactions

### Dimension Tables

-   **DimCustomer**
-   **DimProduct**
-   **DimEmployee**
-   **DimRegion**
-   **DimDate**

> **Important:** The final model contains **no fact-to-fact
> relationships**. Each fact table is connected through shared/conformed
> dimensions to avoid ambiguous filter paths and maintain a clean
> analytical model.

------------------------------------------------------------------------

## 🗂️ Data Model

### FactSales

**Grain:** One row per order item.

Key fields include:

-   order_id
-   order_item_id
-   product_id
-   customer_id
-   employee_id
-   region_id
-   order_date
-   quantity
-   unit_price
-   discount

### FactReturns

**Grain:** One row per return record.

Key fields include:

-   order_item_id
-   order_id
-   customer_id
-   employee_id
-   region_id
-   return_date
-   refund_status
-   return_reason

### FactPayments

**Grain:** One row per payment/order.

Key fields include:

-   order_id
-   customer_id
-   employee_id
-   region_id
-   payment_date
-   payment_mode
-   payment_status
-   amount

### Shared Dimensions

The fact tables are filtered through:

``` text
DimCustomer
DimProduct
DimEmployee
DimRegion
DimDate
```

This allows consistent slicing and filtering without creating direct
fact-to-fact relationships.

------------------------------------------------------------------------

## 🛠️ Technology Stack

  Technology     Purpose
  -------------- -------------------------------------
  Python         Synthetic retail data generation
  Faker          Realistic test data generation
  MySQL          Data storage
  SQL            Analysis and independent validation
  Power Query    Data transformation and preparation
  Power BI       Interactive reporting
  DAX            KPI and business calculations
  Git / GitHub   Version control and documentation

------------------------------------------------------------------------

## 🔄 Data Preparation & Transformation

Power Query was used to:

-   Connect to the MySQL source data
-   Clean and transform source tables
-   Configure data types
-   Create fact and dimension tables
-   Merge order-level attributes into transactional tables
-   Integrate supplier/category information into the product dimension
-   Build the analytical model used by Power BI

The model was designed around the **grain of each fact table** to
prevent double counting.

A key example was the payment pipeline: the payment merge was corrected
to use `order_id` as the appropriate merge key so that one payment
remained one payment.

------------------------------------------------------------------------

## 🧮 Key DAX Measures

### Revenue

``` dax
Revenue =
SUMX(
    FactSales,
    FactSales[quantity] * FactSales[unit_price]
)
```

### Average Order Value

``` dax
Average Order Value =
DIVIDE(
    [Revenue],
    [Order Count]
)
```

### Net Revenue

``` dax
Net Revenue =
[Revenue] - [Total Discount Amount]
```

### Previous Month Revenue

``` dax
Previous Month Revenue =
CALCULATE(
    [Revenue],
    DATEADD(DimDate[Date], -1, MONTH)
)
```

### Revenue Growth

``` dax
Revenue Growth % =
DIVIDE(
    [Revenue] - [Previous Month Revenue],
    [Previous Month Revenue]
)
```

### Payment Success Rate

``` dax
Payment Success Rate =
DIVIDE(
    CALCULATE(
        [Payment Count],
        FactPayments[payment_status] = "Paid"
    ),
    [Payment Count]
)
```

The complete set of project measures is available in the Power BI
project files.

------------------------------------------------------------------------

# 📊 Power BI Dashboard

The final report contains **five analytical pages**.

## 1. Executive Overview

Provides a high-level business view covering:

-   Net Revenue
-   Revenue Growth
-   Order Count
-   Average Order Value
-   Return Percentage
-   Monthly Revenue Trend
-   Revenue by Region
-   Revenue by Category
-   Top 5 Products by Revenue

## 2. Product Analysis

Analyzes:

-   Revenue
-   Total Quantity
-   Average Order Value
-   Average Discount
-   Revenue by Category
-   Revenue by Brand
-   Top 5 Products
-   Product-level performance

## 3. Regional Analysis

Analyzes:

-   Regional Revenue
-   Order Count
-   Average Order Value
-   Revenue Contribution
-   Monthly Revenue by Region
-   Regional Performance

## 4. Customer & Employee Analysis

Analyzes:

-   Customer Count
-   Top 10 Customers by Revenue
-   Revenue by Employee
-   Employee Performance
-   Customer Performance

## 5. Returns & Payments

Analyzes:

-   Return Count
-   Return Rate
-   Revenue from Returned Items
-   Net Revenue After Returns
-   Payment Success Rate
-   Return Reasons
-   Returns by Category
-   Returns Trend
-   Payment Mode
-   Payment Status

------------------------------------------------------------------------

## 📈 Key Business Insights

Based on the validated dashboard:

### Revenue

-   Gross revenue is approximately **₹6.41B**
-   The dataset contains **10,000 orders**
-   Overall average order value is approximately **₹640.82K**
-   Net revenue after discounts is approximately **₹5.77B**

### Regional Performance

-   **North India** is the highest-revenue region at approximately
    **₹1.32B**
-   North India contributes approximately **20.58%** of total revenue
-   The five regions together account for **100%** of revenue

### Product Performance

-   **Canon EOS R5** is the highest-revenue product name at
    approximately **₹2.10B**
-   Dell XPS 15 follows at approximately **₹1.29B**

### Returns

-   There are **2,937 return records**
-   Return rate is approximately **29.37%**
-   Revenue associated with returned items is approximately **₹615M**
-   Net revenue after returned-item revenue is approximately **₹5.15B**

> "Revenue from Returned Items" represents revenue associated with order
> items that have a return record. It should not automatically be
> interpreted as cash actually refunded because the source contains
> multiple refund statuses.

### Payments

-   There are **10,000 payment records**
-   **4,833** payments are marked Paid
-   Payment success rate is approximately **48.33%**

------------------------------------------------------------------------

## ✅ Data Validation

A major part of the project was independently validating Power BI
results against SQL calculations.

The following were validated:

-   Gross Revenue
-   Order Count
-   Average Order Value
-   Return Count
-   Revenue from Returned Items
-   Net Revenue After Returns
-   Payment Count
-   Payment Status
-   Payment Success Rate
-   Regional Revenue
-   Category Revenue
-   Top 5 Products
-   Monthly Revenue

### Data-quality issue identified

During payment validation, Power BI initially showed approximately **19K
FactPayments rows** even though the source contained **10K payments**.

The issue was traced to an incorrect Power Query merge configuration
where both `order_id` and `customer_id` had been used as merge keys.

The merge was corrected to use:

``` text
generated_payments[order_id]
        ↓
generated_orders[order_id]
```

After correction:

``` text
FactPayments rows = 10,000
Distinct payment orders = 10,000
```

The Power BI payment status counts then matched the SQL source exactly.

This validation process helped ensure that the dashboard metrics
represented the underlying data correctly.

------------------------------------------------------------------------

## 📁 Repository Structure

``` text
RetailAnalyticsProject/
│
├── SQL/
│   ├── schema.sql
│   ├── Phase1/
│   ├── Phase2/
│   ├── Phase3/
│   ├── Phase4/
│   ├── Top-N/
│   └── Sum-Window/
│
├── Python/
│   ├── generate_customers.py
│   ├── generate_products.py
│   ├── generate_employees.py
│   ├── generate_orders.py
│   ├── generate_regions.py
│   └── generate_suppliers.py
│
├── datasets/
│
├── Power BI/
│
├── Docs/
│   ├── architecture.png
│   └── data_model.png
│
└── README.md
```

------------------------------------------------------------------------

## 🚀 How to Run the Project

### 1. Generate the data

Run the Python scripts in the `Python/` directory to generate the retail
datasets.

### 2. Load the data into MySQL

Create the database schema using the SQL scripts and load the generated
datasets.

### 3. Run SQL analysis

Use the SQL files in the `SQL/` directory for analytical queries and
validation.

### 4. Open the Power BI report

Open the `.pbix` file from the `Power BI/` directory.

### 5. Refresh the model

Refresh the Power BI data model after configuring the MySQL connection.

### 6. Explore the dashboard

Use the five report pages and their slicers/cross-filtering capabilities
to analyze the retail business.

------------------------------------------------------------------------

## 🎯 Skills Demonstrated

This project demonstrates practical experience with:

-   Data generation and preparation
-   Relational database concepts
-   SQL querying
-   Aggregations and analytical SQL
-   Power Query / ETL
-   Star-schema modeling
-   Fact and dimension design
-   DAX
-   Time intelligence
-   KPI development
-   Data validation
-   Power BI visualization
-   Business analysis
-   Git/GitHub version control

------------------------------------------------------------------------

## 👨‍💻 Author

**Dharshan Gowda G K**

Data Analyst / BI Analyst

GitHub: [GKDHARSHAN](https://github.com/GKDHARSHAN)

LinkedIn: [Dharshan Gowda G
K](https://www.linkedin.com/in/dharshan-gowda-g-k/)

------------------------------------------------------------------------

## ⭐ Project Status

**Completed**

The project includes end-to-end data generation, SQL analysis, Power
Query transformation, star-schema modeling, DAX calculations, Power BI
reporting, interactive filtering, and SQL-to-Power BI validation.
