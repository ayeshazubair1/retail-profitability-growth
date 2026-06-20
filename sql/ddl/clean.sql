/*=======================================================================================
LAYER: Clean / Standardized Views
Schema: clean
Purpose: 
	- Creates transformed views, derived from the source tables in the 'raw' schema
    - Resolves known data quality issues (formats, casing, NULL, duplicates)
Usage:
	- Run this script to create or refresh views showing cleaned data
    - Analysis-ready source for SQL queries and visualization
=========================================================================================*/

-- ============================
-- clean.customers
-- ============================
CREATE OR REPLACE VIEW clean.customers AS
SELECT
    "Customer ID"::integer                AS customer_id,
    "Name"                                AS name,
    "City"                                AS city,
    CASE "Country"
        WHEN 'Deutschland' THEN 'Germany'
        WHEN 'España'      THEN 'Spain'
        WHEN '中国'         THEN 'China'
        ELSE "Country"
    END                                   AS country,
    CASE "Gender"
        WHEN 'M' THEN 'male'
        WHEN 'F' THEN 'female'
        WHEN 'D' THEN 'other'
    END                                   AS gender,
    "Date Of Birth"::date                 AS date_of_birth,
    NULLIF("Job Title"	, '')     	      AS job_title
FROM raw.customers;

-- ============================
-- clean.products
-- ============================
CREATE OR REPLACE VIEW clean.products AS
SELECT
    "Product ID"::integer                           AS product_id,
    "Category"                                      AS category,
    "Sub Category"                                  AS sub_category,
    "Description EN"                                AS description,
    LOWER(COALESCE(NULLIF("Color", ''), 'unknown')) AS color,
    	  COALESCE(NULLIF("Sizes", ''), 'unknown')  AS sizes,
    ROUND("Production Cost"::numeric, 2)            AS production_cost
FROM raw.products;

-- ============================
-- clean.stores
-- ============================
CREATE OR REPLACE VIEW clean.stores AS
SELECT
    "Store ID"::integer                          AS store_id,
    CASE "Country"
        WHEN 'Deutschland' THEN 'Germany'
        WHEN 'España'      THEN 'Spain'
        WHEN '中国'         THEN 'China'
        ELSE "Country"
    END                                          AS country,
    CASE "City"
        WHEN '上海' THEN 'Shanghai'
        WHEN '北京' THEN 'Beijing'
        WHEN '广州' THEN 'Guangzhou'
        WHEN '深圳' THEN 'Shenzhen'
        WHEN '重庆' THEN 'Chongqing'
        ELSE "City"
    END                                          AS city,
    CASE "Store Name"
        WHEN 'Store 上海' THEN 'Store Shanghai'
        WHEN 'Store 北京' THEN 'Store Beijing'
        WHEN 'Store 广州' THEN 'Store Guangzhou'
        WHEN 'Store 深圳' THEN 'Store Shenzhen'
        WHEN 'Store 重庆' THEN 'Store Chongqing'
        ELSE "Store Name"
    END                                          AS store_name,
    "Number of Employees"::integer               AS total_employees,
    "Latitude"::float                         	 AS latitude,
    "Longitude"::float                        	 AS longitude
FROM raw.stores;

-- ============================
-- clean.employees
-- ============================
CREATE OR REPLACE VIEW clean.employees AS
SELECT
    "Employee ID"::integer AS employee_id,
    "Store ID"::integer    AS store_id,
    "Name"                 AS name,
    "Position"             AS position
FROM raw.employees;

-- ============================
-- clean.discounts
-- ============================
CREATE OR REPLACE VIEW clean.discounts AS
SELECT
    "Start"::date                AS start_date,
    "End"::date                  AS end_date,
    ROUND("Discont"::NUMERIC, 2) AS discount,
    "Description"                AS description,
    NULLIF("Category", '')       AS category,
    NULLIF("Sub Category", '')   AS sub_category
FROM raw.discounts;

-- ============================
-- clean.transactions
-- ============================
CREATE OR REPLACE VIEW clean.transactions AS
WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY "Invoice ID", "Line", "Customer ID", "Product ID"
            ORDER BY "Invoice ID") 						  AS row_num
    FROM raw.transactions
)
SELECT
    ROW_NUMBER() OVER (ORDER BY "Invoice ID", "Line")     AS transaction_id,
    "Invoice ID"                                          AS invoice_id,
    "Line"::integer                                       AS line,
    "Customer ID"::integer                                AS customer_id,
    "Product ID"::integer                                 AS product_id,
    NULLIF("Size", '')                              	  AS size,
    LOWER(COALESCE(NULLIF(TRIM("Color"), ''), 'unknown')) AS color,
    ROUND(CASE "Currency"
            WHEN 'EUR' THEN "Unit Price"::numeric * 1.08
            WHEN 'GBP' THEN "Unit Price"::numeric * 1.27
            WHEN 'CNY' THEN "Unit Price"::numeric * 0.14
            ELSE "Unit Price"::numeric
        END, 2)                                           AS unit_price,
    "Quantity"::integer                                   AS quantity,
    "Date"::date                                          AS date,
    ROUND("Discount"::numeric, 2)                         AS discount,
    ROUND(CASE "Currency"
            WHEN 'EUR' THEN "Line Total"::numeric * 1.08
            WHEN 'GBP' THEN "Line Total"::numeric * 1.27
            WHEN 'CNY' THEN "Line Total"::numeric * 0.14
            ELSE "Line Total"::numeric
        END, 2)                                           AS line_total,
    "Store ID"::integer                                   AS store_id,
    "Employee ID"::integer                                AS employee_id,
    'USD'                                                 AS currency,
    "Transaction Type"                                    AS transaction_type,
    "Payment Method"                                      AS payment_method
FROM deduplicated
WHERE row_num = 1;