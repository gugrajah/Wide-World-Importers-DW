-- Create a clone of the dbo.dimension_city table
CREATE TABLE [dbo].[dimension_city1] AS CLONE OF [dbo].[dimension_city];

-- Create a clone table of the fact_sale table
CREATE TABLE [dbo].[fact_sale1] AS CLONE OF [dbo].[fact_sale];