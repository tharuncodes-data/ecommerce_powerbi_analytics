/*		RUN DIRECT VIEWS HERE 


SELECT * FROM pbi_executive_business_overview

SELECT * FROM bi_sales_product_performance_overview

SELECT * FROM bi_customer_retention_overview

SELECT * FROM bi_geographic_sales_overview

*/

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    customer_city TEXT,
    customer_state CHAR(2)
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC
);


CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city TEXT,
    seller_state CHAR(2)
);

CREATE TABLE reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state CHAR(2)
);

CREATE TABLE categories (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

/*	EXECUTIVE PERFORMANCE OVERVIEW	*/

CREATE OR REPLACE VIEW pbi_executive_business_overview AS
WITH base_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        oi.price
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),

customer_order_counts AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM base_orders
    GROUP BY customer_unique_id
)

SELECT
    bo.order_month,

    ROUND(SUM(bo.price), 2) AS total_revenue,

    COUNT(DISTINCT bo.order_id) AS total_orders,

    COUNT(DISTINCT bo.customer_unique_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN coc.total_orders > 1 THEN bo.customer_unique_id
    END) AS repeat_customers,

    ROUND(
        SUM(bo.price) / COUNT(DISTINCT bo.order_id),
        2
    ) AS avg_order_value

FROM base_orders bo
LEFT JOIN customer_order_counts coc
    ON bo.customer_unique_id = coc.customer_unique_id

GROUP BY bo.order_month
ORDER BY bo.order_month;

select * from pbi_executive_business_overview

/*	SALES PRODUCT PERFORMANCE	*/


CREATE OR REPLACE VIEW bi_sales_product_performance_overview AS
WITH base_sales AS (
    SELECT
        o.order_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        oi.product_id,
        p.product_category_name,
        oi.price
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
),

product_level_sales AS (
    SELECT
        order_month,
        product_id,
        product_category_name,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(product_id) AS total_quantity_sold,
        ROUND(SUM(price), 2) AS total_revenue,
        ROUND(AVG(price), 2) AS avg_selling_price
    FROM base_sales
    GROUP BY
        order_month,
        product_id,
        product_category_name
),

monthly_revenue AS (
    SELECT
        order_month,
        SUM(total_revenue) AS monthly_total_revenue
    FROM product_level_sales
    GROUP BY order_month
)

SELECT
    pls.order_month,
    pls.product_id,
    pls.product_category_name,
    pls.total_orders,
    pls.total_quantity_sold,
    pls.total_revenue,
    pls.avg_selling_price,

    ROUND(
        (pls.total_revenue / mr.monthly_total_revenue) * 100,
        2
    ) AS revenue_contribution_pct

FROM product_level_sales pls
JOIN monthly_revenue mr
    ON pls.order_month = mr.order_month
ORDER BY
    pls.order_month,
    pls.total_revenue DESC;

/*	CUSTOMER RETENTION OVERVIEW	*/

CREATE OR REPLACE VIEW bi_customer_retention_overview AS
WITH base_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        oi.price
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),

customer_first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS first_purchase_month
    FROM base_orders
    GROUP BY customer_unique_id
),

customer_monthly_activity AS (
    SELECT
        bo.customer_unique_id,
        bo.order_month,
        COUNT(DISTINCT bo.order_id) AS total_orders,
        ROUND(SUM(bo.price), 2) AS total_spend
    FROM base_orders bo
    GROUP BY
        bo.customer_unique_id,
        bo.order_month
)

SELECT
    cma.customer_unique_id,
    cfp.first_purchase_month,
    cma.order_month,
    cma.total_orders,
    cma.total_spend,

    CASE
        WHEN cma.order_month = cfp.first_purchase_month
            THEN 'New Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    ROUND(
        cma.total_spend / NULLIF(cma.total_orders, 0),
        2
    ) AS avg_order_value

FROM customer_monthly_activity cma
JOIN customer_first_purchase cfp
    ON cma.customer_unique_id = cfp.customer_unique_id
ORDER BY
    total_orders desc

	

/*	GEOGRAPHIC SALES OVERVIEW	*/
CREATE OR REPLACE VIEW bi_geographic_sales_overview AS
WITH base_data AS (
    SELECT
        o.order_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        c.customer_state,
        c.customer_city,
        oi.price,
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
),

delivery_calculation AS (
    SELECT
        order_id,
        order_month,
        customer_state,
        customer_city,
        price,

        CASE
            WHEN order_delivered_customer_date IS NOT NULL
                THEN (order_estimated_delivery_date - order_delivered_customer_date)
        END AS delivery_interval
    FROM base_data
)

SELECT
    order_month,
    customer_state,
    customer_city,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(SUM(price), 2) AS total_revenue,

    ROUND(
        AVG(EXTRACT(EPOCH FROM delivery_interval) / 96400),
        1
    ) AS avg_delivery_days

FROM delivery_calculation
GROUP BY
    order_month,
    customer_state,
    customer_city
ORDER BY
    total_revenue DESC,
	avg_delivery_days desc,
	order_month desc
