> This document outlines the technical implementation of the project, from raw data ingestion and quality assessment to the final analytical model used for dashboard reporting.

## Dataset Overview
The dataset represents a fictional global fashion retailer operating across multiple countries and regions. It provides comprehensive transactional data capturing end-to-end retail operations, including customer orders, product sales, store performance, and multi-currency transactions.    

[Download Dataset](https://www.kaggle.com/datasets/ricgomes/global-fashion-retail-stores-dataset) 

#### Dataset Summary:
| Attribute             | Detail                                      |
| --------------------- | ------------------------------------------- |
| Date Range            | 2023-01-01 to 2025-03-18                    |
| Transaction Records   | 6.4M+                                       |
| Stores                | 35                                          |
| Countries             | 7 (China, USA, Portugal, Spain, France, Germany, UK) |
| Categories            | 3 (Masculine, Feminine, Children's)           |
| Subcategories        | 21                                          |
| Tables                | 6 relational tables                         |

### Tech Stack & Data Architecture
**Tools:** Tableau • PostgreSQL • DBeaver   
**Architecture:** Raw → Clean → Dashboard
```text
Raw Tables
   ↓
Clean Layer → Standardized views (type casting, validation, currency normalization)
   ↓
Tableau Dashboard
```
<br>

<img src="docs/philea_ERD.svg" width="700" alt="Philea ERD">

---

### Data Quality Assessment
After loading the source files into the raw schema, data quality checks identified minor inconsistencies related to standardization, missing values, duplicate records, and multi-currency transactions. These issues were resolved through standardized SQL views before analysis and visualization.

**Issues Identified and Resolved:**

| Table        | Column                            | Issue                                           | Fix Applied                           |
| ------------ | --------------------------------- | ----------------------------------------------- | ------------------------------------- |
| customers    | country                           | Mixed language country names                    | Standardized using CASE               |
|              | gender                            | Encoded values (M, F, D)                        | Converted to descriptive labels       |
|              | job_title                         | Empty strings                                   | NULLIF()                              |
| products     | color                             | Missing values, inconsistent casing             | LOWER(), COALESCE()                   |
|              | sizes                             | Missing values                                  | COALESCE('unknown')                   |
|              | production_cost                   | Inconsistent decimal precision                  | ROUND()                               |
| stores       | country                           | Mixed language country names                    | Standardized using CASE               |
|              | city, store_name                  | Chinese city, store names                       | Translated to English                 |
| discounts    | category, sub_category            | Empty strings                                   | NULLIF()                              |
|              | discount                          | Inconsistent decimal precision                  | ROUND()                               |
| transactions | duplicate records                 | Duplicate transaction lines                     | ROW_NUMBER() deduplication            |
|              | color                             | Missing values, whitespace, inconsistent casing | TRIM(), LOWER(), COALESCE()           |
|              | size                              | Empty strings                                   | NULLIF()                              |
|              | unit_price, line_total            | Multiple currencies                             | Converted to USD                      |
|              | discount                          | Inconsistent decimal precision                  | ROUND()                               |
|              | transaction_id                    | Missing surrogate key                           | Generated using ROW_NUMBER()          |

<br>

#### SQL Scripts

- **DDL** [View scripts](sql/ddl)    
- **Database Initialization** [View script](sql/db_init.sql)    
- **Data Quality Checks** [View scripts](sql/test/raw_quality_checks.sql)   