-- ===========================================
-- DROP & CREATE DATABASE
-- ===========================================

DROP DATABASE IF EXISTS retail_analytics;

CREATE DATABASE retail_analytics;

USE retail_analytics;

-- ===========================================
-- CATEGORIES
-- ===========================================

CREATE TABLE categories (

    category_id INT PRIMARY KEY,

    category_name VARCHAR(100) NOT NULL UNIQUE

);

-- ===========================================
-- SUPPLIERS
-- ===========================================

CREATE TABLE suppliers (

    supplier_id INT AUTO_INCREMENT PRIMARY KEY,

    supplier_name VARCHAR(150) NOT NULL,

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(50) NOT NULL

);

-- ===========================================
-- CUSTOMERS
-- ===========================================

CREATE TABLE customers (

    customer_id INT AUTO_INCREMENT PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    gender VARCHAR(10) NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,

    phone VARCHAR(20),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(50) NOT NULL,

    signup_date DATE NOT NULL

);

-- ===========================================
-- DEPARTMENTS
-- ===========================================

CREATE TABLE departments (

    department_id INT PRIMARY KEY,

    department_name VARCHAR(100) NOT NULL

);

-- ===========================================
-- REGIONS
-- ===========================================

CREATE TABLE regions (

    region_id INT PRIMARY KEY,

    region_name VARCHAR(100) NOT NULL

);

-- ===========================================
-- EMPLOYEES
-- ===========================================

CREATE TABLE employees (

    employee_id INT AUTO_INCREMENT PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    department_id INT NOT NULL,

    manager_id INT,

    hire_date DATE NOT NULL,

    salary DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id),

    FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id)

);

-- ===========================================
-- PRODUCTS
-- ===========================================

CREATE TABLE products (

    product_id INT AUTO_INCREMENT PRIMARY KEY,

    product_name VARCHAR(100) NOT NULL,

    brand VARCHAR(50) NOT NULL,

    category_id INT NOT NULL,

    supplier_id INT NOT NULL,

    color VARCHAR(25),

    unit_price DECIMAL(10,2) NOT NULL,

    cost_price DECIMAL(10,2) NOT NULL,

    stock_quantity INT NOT NULL,

    created_date DATE NOT NULL,

    is_active BOOLEAN NOT NULL,

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)

);

-- ===========================================
-- ORDERS
-- ===========================================

CREATE TABLE orders (

    order_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,

    employee_id INT NOT NULL,

    region_id INT NOT NULL,

    order_date DATE NOT NULL,

    payment_mode VARCHAR(20) NOT NULL,

    order_status VARCHAR(20) NOT NULL,

    total_amount DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    FOREIGN KEY (region_id)
        REFERENCES regions(region_id)

);

-- ===========================================
-- ORDER ITEMS
-- ===========================================

CREATE TABLE order_items (

    order_item_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL,

    product_id INT NOT NULL,

    quantity INT NOT NULL,

    unit_price DECIMAL(10,2) NOT NULL,

    discount DECIMAL(5,2) DEFAULT 0,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)

);

-- ===========================================
-- PAYMENTS
-- ===========================================

CREATE TABLE payments (

    payment_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL,

    payment_mode VARCHAR(20) NOT NULL,

    payment_status VARCHAR(20) NOT NULL,

    payment_date DATE NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)

);

-- ===========================================
-- RETURNS
-- ===========================================

CREATE TABLE returns (

    return_id INT AUTO_INCREMENT PRIMARY KEY,

    order_item_id INT NOT NULL,

    return_date DATE,

    return_reason VARCHAR(100),

    refund_status VARCHAR(20),

    FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id)

);