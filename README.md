# Wide World Importers Data Warehouse - Microsoft Fabric Tutorial

This project implements a complete data warehouse solution using Microsoft Fabric, based on the [official Microsoft tutorial](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction). It demonstrates core data warehousing concepts including data ingestion, table creation, stored procedures, cloning, and time travel queries.

## Project Overview

This project creates a data warehouse for Wide World Importers, a fictitious wholesale novelty goods importer and distributor. The warehouse contains sales data and city dimension data, with analytical capabilities for sales reporting and customer analysis.

## Project Structure

```
.
├── CreateTables.sql                    # Initial table definitions
├── Load_Data.sql                       # Data ingestion from Azure storage
├── Create Top10 Customer View          # View for top customers by sales
├── CreateAggregateProcedure.sql        # Stored procedure for sales aggregation
├── Run Aggregate Procedure.sql         # Execute aggregation procedure
├── CloneTables.sql                     # Clone tables in same schema
├── NewShema_and_Clone.sql             # Create new schema and clone tables
├── Time Travel                         # Time travel demo with data modification
└── Time Travel Now.sql                # Query data at specific timestamp
```

## Getting Started

### Prerequisites

- Microsoft Fabric workspace with Data Warehouse enabled
- Access to the provided Azure storage account (read-only)

### Setup Instructions

Execute the SQL scripts in the following order:

1. **Create Tables** - Run [CreateTables.sql](CreateTables.sql)
   - Creates `dimension_city` table with city and geographic information
   - Creates `fact_sale` table with sales transaction data

2. **Load Data** - Run [Load_Data.sql](Load_Data.sql)
   - Loads dimension and fact data from Azure Blob Storage using `OPENROWSET` and `COPY INTO`
   - Source: `https://fabrictutorialdata.blob.core.windows.net/sampledata/WideWorldImportersDW/`

3. **Create Views** - Run [Create Top10 Customer View](Create%20Top10%20Customer%20View)
   - Creates the [`Top10Customers`](Create%20Top10%20Customer%20View) view showing customers with highest total sales

4. **Create Aggregation Logic** - Run [CreateAggregateProcedure.sql](CreateAggregateProcedure.sql)
   - Creates the [`populate_aggregate_sale_by_city`](CreateAggregateProcedure.sql) stored procedure
   - Aggregates sales data by date, city, state, and territory

5. **Execute Aggregation** - Run [Run Aggregate Procedure.sql](Run%20Aggregate%20Procedure.sql)
   - Executes the stored procedure to create and populate `aggregate_sale_by_date_city` table

## Key Features

### Data Cloning

The project demonstrates two approaches to table cloning:

- **Same Schema Cloning** - [CloneTables.sql](CloneTables.sql) creates clones within the `dbo` schema
- **Cross-Schema Cloning** - [NewShema_and_Clone.sql](NewShema_and_Clone.sql) creates a new `dbo1` schema and clones tables there

### Time Travel

Microsoft Fabric supports querying historical data using time travel:

1. Run [Time Travel](Time%20Travel) to:
   - Update a sales record to simulate data corruption
   - Capture the current timestamp

2. Run [Time Travel Now.sql](Time%20Travel%20Now.sql) to:
   - Query the [`Top10Customers`](Create%20Top10%20Customer%20View) view at a specific point in time
   - Replace `'YOUR_TIMESTAMP'` with the timestamp from step 1

```sql
SELECT *
FROM [dbo].[Top10Customers]
OPTION (FOR TIMESTAMP AS OF '2024-01-15 10:30:00');
```

### Aggregation Stored Procedure

The [`populate_aggregate_sale_by_city`](CreateAggregateProcedure.sql) procedure creates an aggregate table with:
- Sales totals by date, city, state, and territory
- Includes tax amounts, profit, and total including tax
- Uses `JOIN` between [`fact_sale`](CreateTables.sql) and [`dimension_city`](CreateTables.sql) tables

## Database Schema

### Dimension Tables

- **dimension_city** - City dimension with geographic hierarchy (city, state, country, continent, sales territory)

### Fact Tables

- **fact_sale** - Sales transaction facts including customer, product, dates, quantities, and financial measures

### Views

- **Top10Customers** - Top 10 customers ranked by total sales amount

### Aggregate Tables

- **aggregate_sale_by_date_city** - Pre-aggregated sales by date and geographic location

## Learning Outcomes

This project demonstrates:

- ✅ Creating and managing tables in Microsoft Fabric Data Warehouse
- ✅ Loading data from Azure Blob Storage using `COPY INTO`
- ✅ Creating views for analytical queries
- ✅ Building stored procedures for data transformation
- ✅ Using table cloning for data management
- ✅ Implementing time travel queries for historical analysis
- ✅ Schema management and organization

## Additional Resources

- [Microsoft Fabric Data Warehouse Documentation](https://learn.microsoft.com/en-us/fabric/data-warehouse/)
- [Tutorial: Introduction](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction)

## Notes

- The data is sourced from a public Azure storage account provided by Microsoft
- Time travel queries use UTC timestamps
- Cloned tables share the same data storage initially (zero-copy cloning)