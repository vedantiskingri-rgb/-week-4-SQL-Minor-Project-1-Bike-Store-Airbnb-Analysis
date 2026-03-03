-- Select the database (create if it doesn't exist)
CREATE DATABASE IF NOT EXISTS bike_store;
USE bike_store;

-- Drop tables in reverse order of dependencies (to avoid FK errors)
DROP TABLE IF EXISTS stocks;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS brands;

-- Create brands table
CREATE TABLE brands (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(255) NOT NULL
);

-- Create categories table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) NOT NULL
);

-- Create products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT,
    category_id INT,
    model_year SMALLINT,
    list_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Create stores table
CREATE TABLE stores (
    store_id INT PRIMARY KEY AUTO_INCREMENT,
    store_name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    state VARCHAR(255)
);

-- Create customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    state VARCHAR(255),
    zip_code VARCHAR(10)
);

-- Create staff table
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Create orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    store_id INT,
    staff_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

-- Create order_items table
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(4, 2) DEFAULT 0.00,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create stocks table
CREATE TABLE stocks (
    store_id INT,
    product_id INT,
    quantity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data
INSERT INTO brands (brand_name) VALUES ('Trek'), ('Giant'), ('Specialized');
INSERT INTO categories (category_name) VALUES ('Mountain Bike'), ('Road Bike'), ('Hybrid');
INSERT INTO products (product_name, brand_id, category_id, model_year, list_price) VALUES
('Trek X-Caliber 9', 1, 1, 2022, 2500.00),
('Giant Talon 3', 2, 1, 2022, 2200.00),
('Specialized Allez', 3, 2, 2023, 1800.00),
('Trek Verve+', 1, 3, 2023, 2000.00);
INSERT INTO stores (store_name, city, state) VALUES
('Downtown Bike Shop', 'New York', 'NY'),
('Suburban Cycles', 'Los Angeles', 'CA');
INSERT INTO customers (first_name, last_name, city, state, zip_code) VALUES
('John', 'Doe', 'New York', 'NY', '10001'),
('Jane', 'Smith', 'Los Angeles', 'CA', '90210');
INSERT INTO staff (first_name, last_name, store_id) VALUES
('Alice', 'Johnson', 1),
('Bob', 'Brown', 2);
INSERT INTO orders (customer_id, order_date, store_id, staff_id) VALUES
(1, '2023-10-01', 1, 1),
(2, '2023-10-02', 2, 2);
INSERT INTO order_items (order_id, product_id, quantity, list_price, discount) VALUES
(1, 1, 2, 2500.00, 0.10),
(1, 3, 1, 1800.00, 0.00),
(2, 2, 1, 2200.00, 0.05);
INSERT INTO stocks (store_id, product_id, quantity) VALUES
(1, 1, 10),
(1, 2, 0),
(1, 3, 5),
(2, 1, 8),
(2, 2, 3),
(2, 3, 0);

SELECT 
    s.store_name,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_revenue
FROM 
    stores s
INNER JOIN 
    orders o ON s.store_id = o.store_id
INNER JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    s.store_id, s.store_name
ORDER BY 
    total_revenue DESC;
    
    SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    products p
INNER JOIN 
    order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_quantity_sold DESC
LIMIT 5;

SELECT 
    c.first_name,
    c.last_name,
    c.city AS customer_city,
    c.state AS customer_state,
    s.store_name
FROM 
    customers c
INNER JOIN 
    orders o ON c.customer_id = o.customer_id
INNER JOIN 
    stores s ON o.store_id = s.store_id
ORDER BY 
    c.last_name, c.first_name;
    
    SELECT 
    b.brand_name,
    COUNT(p.product_id) AS total_products
FROM 
    brands b
INNER JOIN 
    products p ON b.brand_id = p.brand_id
GROUP BY 
    b.brand_id, b.brand_name
ORDER BY 
    total_products DESC;
    
    SELECT 
    p.product_name,
    s.store_name,
    st.quantity
FROM 
    products p
INNER JOIN 
    stocks st ON p.product_id = st.product_id
INNER JOIN 
    stores s ON st.store_id = s.store_id
WHERE 
    st.quantity = 0
ORDER BY 
    p.product_name, s.store_name;
    
    