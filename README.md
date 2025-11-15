# Wide World Importers Data Warehouse - Microsoft Fabric Tutorial

This project implements a complete data warehouse solution using Microsoft Fabric, based on the [official Microsoft tutorial](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction). It demonstrates core data warehousing concepts including data ingestion, table creation, stored procedures, cloning, and time travel queries.

## Project Overview

This project creates a data warehouse for Wide World Importers, a fictitious wholesale novelty goods importer and distributor. The warehouse contains sales data, customer data, and city dimension data, with analytical capabilities for sales reporting and customer analysis.

## Project Structure

```
.
├── README.md
├── Load Customer Data - pipeline/
│   ├── Load_Customer_Data-pp.json      # Data pipeline configuration
│   └── manifest.json                    # Pipeline manifest
└── SQL/
    ├── CreateTables.sql                 # Initial table definitions
    ├── Load_Data.sql                    # Data ingestion from Azure storage
    ├── Create Top10 Customer View       # View for top customers by sales
    ├── CreateAggregateProcedure.sql     # Stored procedure for sales aggregation
    ├── Run Aggregate Procedure.sql      # Execute aggregation procedure
    ├── CloneTables.sql                  # Clone tables in same schema
    ├── NewShema_and_Clone.sql          # Create new schema and clone tables
    ├── Time Travel                      # Time travel demo with data modification
    └── Time Travel Now.sql             # Query data at specific timestamp
```

## Getting Started

### Prerequisites

- Microsoft Fabric workspace with Data Warehouse enabled
- Access to the provided Azure storage account (read-only)

### Setup Instructions

Execute the SQL scripts in the following order:

1. **Create Tables** - Run [SQL/CreateTables.sql](SQL/CreateTables.sql)
   - Creates [`dimension_city`](SQL/CreateTables.sql) table with city and geographic information
   - Creates [`fact_sale`](SQL/CreateTables.sql) table with sales transaction data

2. **Load Data** - Run [SQL/Load_Data.sql](SQL/Load_Data.sql)
   - Previews sample data using `OPENROWSET` from Azure Blob Storage
   - Loads dimension and fact data using `COPY INTO` command
   - Source: `https://fabrictutorialdata.blob.core.windows.net/sampledata/WideWorldImportersDW/`

3. **Load Customer Data** - Use [Load Customer Data - pipeline/](Load%20Customer%20Data%20-%20pipeline/)
   - Data pipeline for loading customer dimension data
   - Configured via [Load_Customer_Data-pp.json](Load%20Customer%20Data%20-%20pipeline/Load_Customer_Data-pp.json)

4. **Create Views** - Run [SQL/Create Top10 Customer View](SQL/Create%20Top10%20Customer%20View)
   - Creates the [`Top10Customers`](SQL/Create%20Top10%20Customer%20View) view showing customers with highest total sales
   - Joins [`dimension_customer`](SQL/Create%20Top10%20Customer%20View) with [`fact_sale`](SQL/CreateTables.sql) tables

5. **Create Aggregation Logic** - Run [SQL/CreateAggregateProcedure.sql](SQL/CreateAggregateProcedure.sql)
   - Creates the [`populate_aggregate_sale_by_city`](SQL/CreateAggregateProcedure.sql) stored procedure
   - Aggregates sales data by date, city, state, and territory

6. **Execute Aggregation** - Run [SQL/Run Aggregate Procedure.sql](SQL/Run%20Aggregate%20Procedure.sql)
   - Executes the stored procedure to create and populate `aggregate_sale_by_date_city` table

## Key Features

### Data Pipeline

The project includes a data pipeline for customer data ingestion:

- **Load Customer Data Pipeline** - [Load Customer Data - pipeline/](Load%20Customer%20Data%20-%20pipeline/)
  - Automated data loading for customer dimension
  - Pipeline configuration in [Load_Customer_Data-pp.json](Load%20Customer%20Data%20-%20pipeline/Load_Customer_Data-pp.json)
  - Manifest file for pipeline metadata: [manifest.json](Load%20Customer%20Data%20-%20pipeline/manifest.json)

### Data Cloning

The project demonstrates two approaches to table cloning:

- **Same Schema Cloning** - [SQL/CloneTables.sql](SQL/CloneTables.sql) creates clones within the `dbo` schema
  - Creates `dimension_city1` as clone of [`dimension_city`](SQL/CreateTables.sql)
  - Creates `fact_sale1` as clone of [`fact_sale`](SQL/CreateTables.sql)

- **Cross-Schema Cloning** - [SQL/NewShema_and_Clone.sql](SQL/NewShema_and_Clone.sql) creates a new `dbo1` schema and clones tables there
  - Creates new `dbo1` schema
  - Creates `dbo1.fact_sale1` and `dbo1.dimension_city1` clones

### Time Travel

Microsoft Fabric supports querying historical data using time travel:

1. Run [SQL/Time Travel](SQL/Time%20Travel) to:
   - Update a sales record (SaleKey 22632918) for 'Tailspin Toys (Muir, MI)' to simulate data corruption
   - Set `TotalIncludingTax` to an inflated value (200,000,000)
   - Capture the current UTC timestamp using `SELECT CURRENT_TIMESTAMP`

2. Run [SQL/Time Travel Now.sql](SQL/Time%20Travel%20Now.sql) to:
   - Query the [`Top10Customers`](SQL/Create%20Top10%20Customer%20View) view at a specific point in time
   - Replace `'YOUR_TIMESTAMP'` with the timestamp captured in step 1

```sql
SELECT *
FROM [dbo].[Top10Customers]
OPTION (FOR TIMESTAMP AS OF 'YOUR_TIMESTAMP');
```

This allows you to see the data before the corruption occurred.

### Aggregation Stored Procedure

The [`populate_aggregate_sale_by_city`](SQL/CreateAggregateProcedure.sql) procedure:
- Drops existing [`aggregate_sale_by_date_city`](SQL/CreateAggregateProcedure.sql) table if it exists
- Creates new aggregate table structure
- Loads aggregated sales data with:
  - Date, city, state province, and sales territory dimensions
  - Sum of total excluding tax, tax amount, total including tax, and profit
  - Joins [`fact_sale`](SQL/CreateTables.sql) with [`dimension_city`](SQL/CreateTables.sql) on `CityKey`
  - Groups by invoice date and geographic attributes

## Database Schema

### Dimension Tables

- **dimension_city** - City dimension with:
  - Geographic hierarchy (city, state, country, continent, sales territory, region, subregion)
  - Location and population data
  - Valid from/to dates for slowly changing dimension (SCD) support

- **dimension_customer** - Customer dimension (loaded via pipeline)

### Fact Tables

- **fact_sale** - Sales transaction facts including:
  - Keys: City, Customer, Bill-To Customer, Stock Item, Salesperson
  - Dates: Invoice Date, Delivery Date
  - Measures: Quantity, Unit Price, Tax Rate, Total Excluding Tax, Tax Amount, Profit, Total Including Tax
  - Additional attributes: Description, Package, Dry/Chiller item counts
  - Time dimensions: Month, Year, Quarter

### Views

- **Top10Customers** - Top 10 customers ranked by total sales amount (including tax)
  - Joins [`dimension_customer`](SQL/Create%20Top10%20Customer%20View) with [`fact_sale`](SQL/CreateTables.sql)
  - Aggregates sales by customer key and customer name

### Aggregate Tables

- **aggregate_sale_by_date_city** - Pre-aggregated sales by date and geographic location
  - Created and populated by [`populate_aggregate_sale_by_city`](SQL/CreateAggregateProcedure.sql) stored procedure

## Learning Outcomes

This project demonstrates:

- ✅ Creating and managing tables in Microsoft Fabric Data Warehouse
- ✅ Loading data from Azure Blob Storage using `COPY INTO` and `OPENROWSET`
- ✅ Building data pipelines for automated data ingestion
- ✅ Creating views for analytical queries
- ✅ Building stored procedures for data transformation
- ✅ Using table cloning for data management (zero-copy cloning)
- ✅ Implementing time travel queries for historical analysis
- ✅ Schema management and organization

## Additional Resources

- [Microsoft Fabric Data Warehouse Documentation](https://learn.microsoft.com/en-us/fabric/data-warehouse/)
- [Tutorial: Introduction](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction)

## Notes

- The data is sourced from a public Azure storage account provided by Microsoft
- Time travel queries use UTC timestamps from `CURRENT_TIMESTAMP`
- Cloned tables share the same data storage initially (zero-copy cloning) for storage efficiency
- All SQL scripts are located in the [SQL/](SQL/) directory
- The customer data pipeline uses JSON configuration files in [Load Customer Data - pipeline/](Load%20Customer%20Data%20-%20pipeline/)