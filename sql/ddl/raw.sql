/*=====================================================================================
LAYER: Raw / Source (DATA INGESTION)
Schema: raw
Purpose: 
		- Defines raw ingestion tables that mirror source files exactly
        - Preserves original structure, naming, and data types
Usage:
    	- Run this script to load unprocessed data before cleaning or transformation.
=======================================================================================*/

-- ============================
-- raw.customers
-- ============================
DROP TABLE IF EXISTS raw.customers;
CREATE TABLE raw.customers (
    "Customer ID"   int4    NULL,
    "Name"          text    NULL,
    "Email"         text    NULL,
    "Telephone"     text    NULL,
    "City"          text    NULL,
    "Country"       text    NULL,
    "Gender"        text    NULL,
    "Date Of Birth" text    NULL,
    "Job Title"     text    NULL
);

-- ============================
-- raw.products
-- ============================
DROP TABLE IF EXISTS raw.products;
CREATE TABLE raw.products (
    "Product ID"      int4    NULL,
    "Category"        text    NULL,
    "Sub Category"    text    NULL,
    "Description PT"  text    NULL,
    "Description DE"  text    NULL,
    "Description FR"  text    NULL,
    "Description ES"  text    NULL,
    "Description EN"  text    NULL,
    "Description ZH"  text    NULL,
    "Color"           text    NULL,
    "Sizes"           text    NULL,
    "Production Cost" float4  NULL
);

-- ============================
-- raw.stores
-- ============================
DROP TABLE IF EXISTS raw.stores;
CREATE TABLE raw.stores (
    "Store ID"            int4        NULL,
    "Country"             varchar(50) NULL,
    "City"                varchar(50) NULL,
    "Store Name"          varchar(50) NULL,
    "Number of Employees" int4        NULL,
    "ZIP Code"            varchar(50) NULL,
    "Latitude"            float4      NULL,
    "Longitude"           float4      NULL
);

-- ============================
-- raw.employees
-- ============================
DROP TABLE IF EXISTS raw.employees;
CREATE TABLE raw.employees (
    "Employee ID" int4        NULL,
    "Store ID"    int4        NULL,
    "Name"        varchar(50) NULL,
    "Position"    varchar(50) NULL
);

-- ============================
-- raw.discounts
-- ============================
DROP TABLE IF EXISTS raw.discounts;
CREATE TABLE raw.discounts (
    "Start"        varchar(50) NULL,
    "End"          varchar(50) NULL,
    "Discont"      float4      NULL,
    "Description"  varchar(6NULL,
    "Category"     varchar(50) NULL,
    "Sub Category" varchar(50) NULL
);

-- ============================
-- raw.transactions
-- ============================
DROP TABLE IF EXISTS raw.transactions;
CREATE TABLE raw.transactions (
    "Invoice ID"       varchar(50) NULL,
    "Line"             int4        NULL,
    "Customer ID"      int4        NULL,
    "Product ID"       int4        NULL,
    "Size"             varchar(50) NULL,
    "Color"            varchar(50) NULL,
    "Unit Price"       float4      NULL,
    "Quantity"         int4        NULL,
    "Date"             varchar(50) NULL,
    "Discount"         float4      NULL,
    "Line Total"       float4      NULL,
    "Store ID"         int4        NULL,
    "Employee ID"      int4        NULL,
    "Currency"         varchar(50) NULL,
    "Currency Symbol"  varchar(50) NULL,
    "SKU"              varchar(50) NULL,
    "Transaction Type" varchar(50) NULL,
    "Payment Method"   varchar(50) NULL,
    "Invoice Total"    float4      NULL
);