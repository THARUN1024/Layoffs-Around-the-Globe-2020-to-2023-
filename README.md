# Global Layoff Data Cleanup and Analysis (2020-2023)

This project is designed to clean and analyze global layoff data from 2020 to 2023. The main objective is to ensure the data is accurate, standardized, and well-structured to facilitate insightful analysis. By cleaning up the data and performing exploratory data analysis (EDA), we aim to uncover meaningful trends and patterns related to layoffs worldwide, which can be valuable for business, research, and policy planning.

## Overview

The dataset contains information about layoffs in various companies across different industries and countries. The data includes fields such as:
- **Company name**
- **Location**
- **Industry**
- **Number of layoffs**
- **Percentage of layoffs**
- **Date of layoff**
- **Stage of the company (e.g., Pre-IPO, Post-IPO)**
- **Country**
- **Funds raised by the company **

However, this data is often messy. It can have duplicates, missing values, inconsistent formatting, and errors. The goal of this project is to clean this data and then use it for analysis, to understand which industries and countries are most affected by layoffs.

## Project Goals
1. **Data Cleaning**: 
   - Removing duplicate records
   - Fixing inconsistent or incorrect data (e.g., company names, country names)
   - Handling missing or null values in critical fields (e.g., number of layoffs)
   - Standardizing date formats for consistency
2. **Data Standardization**:
   - Ensuring consistency in text fields like company names, locations, and industries.
   - Normalizing percentages and numeric values.
3. **Exploratory Data Analysis (EDA)**:
   - Identifying trends, patterns, and insights regarding layoffs by year, country, industry, and company stage.
   - Calculating global statistics like total layoffs per country or industry.

## Key Features of the Project

1. **Duplicate Removal**: 
   - The data often has duplicate entries, which can distort analysis. We use SQL’s `ROW_NUMBER()` function to identify and remove duplicates.

2. **Standardizing Text Data**: 
   - Company names and other text fields can have variations like extra spaces or inconsistent capitalization. We clean and standardize these fields to ensure consistency.
   
3. **Handling Missing Data**:
   - Missing values in critical fields such as layoffs count and percentage can lead to misleading conclusions. We handle missing data through strategies like filling or deleting rows with missing values.
   
4. **Date Formatting**:
   - The date format may vary across entries (e.g., MM/DD/YYYY or DD/MM/YYYY). We standardize the dates into a uniform format (e.g., YYYY-MM-DD).

5. **Exploratory Data Analysis (EDA)**:
   - We perform various analyses to understand which countries, industries, and companies were most impacted by layoffs. This includes summing the total layoffs by country, industry, and company, and analyzing how layoffs changed year by year.

6. **Creating Cleaned Tables**:
   - We create a new table (`layoffs_staging_v2`) with cleaned data, ready for analysis.

7. **Rolling Totals**:
   - To see trends over time, we create rolling totals of layoffs by month, providing a sense of how layoffs have evolved.

## Steps Involved in Data Cleaning and Analysis

### 1. **Removing Duplicates**:
   - Duplicate records can make data analysis unreliable. Using the SQL `ROW_NUMBER()` function, we identify and remove rows where duplicates exist based on several key attributes like company name, industry, total layoffs, percentage of layoffs, and date.

### 2. **Standardizing Data**:
   - **Company Names**: We remove extra spaces and ensure consistent naming by trimming spaces and adjusting case where necessary.
   - **Industry Names**: We standardize industry names to ensure consistency (e.g., "Crypto" companies are categorized uniformly).
   - **Country Names**: We clean country names, removing any trailing punctuation or unnecessary characters (e.g., "United States." becomes "United States").
   - **Date Format**: We convert the date column to a proper `DATE` format, which is crucial for any time-based analysis.
   
### 3. **Handling Missing Data**:
   - **Missing Layoff Data**: If there is no data on the number or percentage of layoffs, we remove those records, as they don’t add value to the analysis.
   - **Filling Missing Industry**: For companies that have missing industry information, we attempt to fill the missing values by looking at other entries for the same company.

### 4. **Data Analysis (Exploratory Data Analysis)**:
   - We group data by country, industry, company, and stage to analyze the total layoffs and trends over time.
   - We calculate the sum of layoffs for each country, industry, company, and year.
   - We also explore how layoffs changed over time (e.g., yearly or monthly trends).
   - We find the top 5 companies with the most layoffs each year.

### 5. **Creating Final Cleaned Table**:
   - After cleaning the data and handling missing values, we create a final cleaned table (`layoffs_staging_v2`), which is free from duplicates, missing data, and inconsistencies. This table is now ready for deeper analysis or visualization.

## Files in This Repository

- **`data_cleaning_queries.sql`**: SQL queries used for cleaning and transforming the data.
- **`data_analysis_queries.sql`**: SQL queries for performing exploratory data analysis and generating insights.
- **`README.md`**: This file explaining the project, its objectives, and usage.

## Technologies Used

- **SQL**: Structured Query Language used for data manipulation and analysis.
- **MySQL**: The relational database management system used for storing and managing the data.
