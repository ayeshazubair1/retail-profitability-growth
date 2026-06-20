/*=======================================================================
DATA QUALITY CHECKS
Schema: raw
No. of tables: 6
=========================================================================
Purpose:
    - Validates raw/source data for completeness, accuracy,
      and consistency
    - Identifies nulls, duplicates, negative values, inconsistent
      formatting, and referential integrity issues
    - Detects standardization issues in strings, dates, and numeric fields
    - Ensures data is ready for analysis and reporting
 
Usage Notes:
    - Run prior to the clean/transformation steps
    - Investigate, correct, and document any anomalies found
=========================================================================*/
 
-- ============================
-- raw.customers
-- ============================
-- Check: Duplicates in PK 'Customer ID'
-- Result: No issues
SELECT "Customer ID", COUNT(*)
FROM raw.customers
GROUP BY "Customer ID"
HAVING COUNT(*) > 1;

-- Check: NULL or non-positive values in 'Customer ID'
-- Result: No issues
SELECT "Customer ID"
FROM raw.customers
WHERE "Customer ID" IS NULL
    OR "Customer ID" <= 0;

-- Check: NULL or empty values in 'Name'
-- Result: No issues
SELECT "Name"
FROM raw.customers
WHERE "Name" IS NULL
    OR TRIM("Name") = '';

-- Check: NULL or empty values in 'City'
-- Result: No issues
SELECT "City"
FROM raw.customers
WHERE "City" IS NULL
    OR TRIM("City") = '';

-- Check: Distinct values in 'Country' for standardization
-- Result: Non-English entries
SELECT DISTINCT "Country"
FROM raw.customers;

-- Check: Distinct values in 'Gender'
-- Result: Unknown D
SELECT DISTINCT "Gender"
FROM raw.customers;

-- Check: NULL or empty values in 'Date Of Birth'
-- Result: No issues
SELECT "Date Of Birth"
FROM raw.customers
WHERE "Date Of Birth" IS NULL
    OR TRIM("Date Of Birth") = '';

-- Check: Age range validation
-- Result: No issues
SELECT 
	EXTRACT(YEAR FROM MIN(AGE("Date Of Birth"::date))),
	EXTRACT(YEAR FROM MAX(AGE("Date Of Birth"::date)))
FROM raw.customers ;

-- Check: Empty values in 'Job Title'
-- Result: 584,185 empty records
SELECT COUNT(*) AS empty_records
FROM raw.customers
WHERE TRIM("Job Title") = '';

-- ============================
-- raw.products
-- ============================
-- Check: Duplicates in PK 'Product ID'
-- Result: No issues
SELECT "Product ID", COUNT(*)
FROM raw.products
GROUP BY "Product ID"
HAVING COUNT(*) > 1;

-- Check: NULL or non-positive values in 'Product ID'
-- Result: No issues
SELECT "Product ID"
FROM raw.products
WHERE "Product ID" IS NULL
    OR "Product ID" <= 0;

-- Check: Distinct values in 'Category'
-- Result: No issues
SELECT DISTINCT "Category"
FROM raw.products;

-- Check: Distinct values in 'Sub Category'
-- Result: No issues
SELECT DISTINCT "Sub Category"
FROM raw.products;

-- Check: Empty values in 'Color'
-- Result: 12,445 empty records
SELECT COUNT("Color")
FROM raw.products
WHERE TRIM("Color") = '';

-- Check: Empty values in 'Sizes'
-- Result: 2,070 empty records
SELECT COUNT("Sizes")
FROM raw.products
WHERE TRIM("Sizes") = '';

-- Check: Non-positive values in 'Production Cost'
-- Result: No issues
SELECT "Production Cost"
FROM raw.products
WHERE "Production Cost" <= 0;

-- Check: Production Cost range sanity check
-- Result: No issues
SELECT MIN("Production Cost") AS min_cost,
       MAX("Production Cost") AS max_cost
FROM raw.products;

-- ============================
-- raw.stores
-- ============================
-- Check: Distinct Country, City, Store Name
-- Result: Non-English entries
SELECT DISTINCT "Country", "City", "Store Name"
FROM raw.stores
ORDER BY "Country";

-- ============================
-- raw.employees
-- ============================
-- Check: NULL or non-positive values in 'Employee ID'
-- Result: No issues
SELECT "Employee ID"
FROM raw.employees
WHERE "Employee ID" IS NULL
    OR "Employee ID" <= 0;

-- Check: FK 'Store ID' referential integrity against raw.stores
-- Result: No issues
SELECT e."Store ID"
FROM raw.employees e
LEFT JOIN raw.stores s ON e."Store ID" = s."Store ID"
WHERE s."Store ID" IS NULL;

-- ============================
-- raw.discounts
-- ============================
-- Check: Date range sanity check
-- Result: No issues
SELECT MIN("Start"::date) AS earliest_start,
       MAX("End"  ::date) AS latest_end
FROM raw.discounts;

-- Check: End date before Start date (logical integrity)
-- Result: No issues
SELECT *
FROM raw.discounts
WHERE "End"::date < "Start"::date;

-- Check: Non-positive values in 'Discont'
-- Result: No issues
SELECT "Discont"
FROM raw.discounts
WHERE "Discont" < 0;

-- Check: Empty values in 'Category'
-- Result: 10 empty records
SELECT COUNT("Category")
FROM raw.discounts
WHERE TRIM("Category") = '';

-- Check: Empty values in 'Sub Category'
-- Result: 10 empty records
SELECT COUNT("Sub Category")
FROM raw.discounts
WHERE TRIM("Sub Category") = '';

-- ============================
-- raw.transactions
-- ============================
-- Check: Duplicate composite PK (Invoice ID + Line + Customer ID + Product ID)
-- Result: 8,357 duplicate groups — no natural unique key exists
SELECT "Invoice ID", "Line", "Customer ID", "Product ID", COUNT(*)
FROM raw.transactions
GROUP BY "Invoice ID", "Line", "Customer ID", "Product ID"
HAVING COUNT(*) > 1;

-- Check: NULL or empty values in 'Invoice ID'
-- Result: No issue
SELECT "Invoice ID"
FROM raw.transactions
WHERE "Invoice ID" IS NULL
    OR TRIM("Invoice ID") = '';

-- Check: FK 'Customer ID' referential integrity against raw.customers
-- Result: No issue
SELECT t."Customer ID"
FROM raw.transactions t
LEFT JOIN raw.customers c ON t."Customer ID" = c."Customer ID"
WHERE c."Customer ID" IS NULL;

-- Check: FK 'Product ID' referential integrity against raw.products
-- Result: No issue
SELECT t."Product ID"
FROM raw.transactions t
LEFT JOIN raw.products p ON t."Product ID" = p."Product ID"
WHERE p."Product ID" IS NULL;

-- Check: FK 'Store ID' referential integrity against raw.stores
-- Result: No issue
SELECT t."Store ID"
FROM raw.transactions t
LEFT JOIN raw.stores s ON t."Store ID" = s."Store ID"
WHERE s."Store ID" IS NULL;

-- Check: FK 'Employee ID' referential integrity against raw.employees
-- Result: No issue
SELECT t."Employee ID"
FROM raw.transactions t
LEFT JOIN raw.employees e ON t."Employee ID" = e."Employee ID"
WHERE e."Employee ID" IS NULL;

-- Check: Non-positive values in 'Unit Price'
-- Result: No issue
SELECT "Unit Price"
FROM raw.transactions
WHERE "Unit Price" <= 0;

-- Check: Non-positive values in 'Quantity'
-- Result: No issue
SELECT "Quantity"
FROM raw.transactions
WHERE "Quantity" <= 0;

-- Check: NULL or empty values in 'Date'
-- Result: No issue
SELECT "Date"
FROM raw.transactions
WHERE "Date" IS NULL
    OR TRIM("Date") = '';

-- Check: Date range sanity check
-- Result: No issues
SELECT MIN("Date"::timestamp) AS earliest_date,
       MAX("Date"::timestamp) AS latest_date
FROM raw.transactions;

-- Check: Non-positive values in 'Line Total'
-- Result: 339,627 negative values — linked to returns
SELECT COUNT("Line Total")
FROM raw.transactions
WHERE "Line Total" <= 0;

-- Check: Non-positive values in 'Invoice Total'
-- Result: 339,627 negative values — linked to returns
SELECT COUNT("Invoice Total")
FROM raw.transactions
WHERE "Invoice Total" <= 0;

-- Check: Empty values in 'Size'
-- Result: 413,102 empty records
SELECT COUNT("Size")
FROM raw.transactions
WHERE "Size" = '';

-- Check: Empty values in 'Color'
-- Result: 4,350,783 empty records
SELECT COUNT("Color")
FROM raw.transactions
WHERE "Color" = '';

-- Check: Distinct values in 'Currency'
-- Result: 4 currencies found — not standardized to USD
SELECT DISTINCT "Currency", COUNT(*)
FROM raw.transactions
GROUP BY "Currency";

-- Check: Distinct values in 'Transaction Type'
-- Result: No issues
SELECT DISTINCT "Transaction Type"
FROM raw.transactions;

-- Check: Distinct values in 'Payment Method'
-- Result: No issues
SELECT DISTINCT "Payment Method"
FROM raw.transactions;