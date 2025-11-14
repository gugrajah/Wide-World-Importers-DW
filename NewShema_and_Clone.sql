-- Create a new schema within the warehouse named dbo1
CREATE SCHEMA dbo1;
GO

-- Create a clone of dbo.fact_sale table in the dbo1. schema
CREATE TABLE [dbo1].[fact_sale1] AS CLONE OF [dbo].[fact_sale];

-- Create a clone of dbo.dimension_city table in the dbo1 schema
CREATE TABLE [dbo1].[dimension_city1] AS CLONE OF [dbo].[dimension_city];