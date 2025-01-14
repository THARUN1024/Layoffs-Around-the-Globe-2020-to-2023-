# Layoffs Around the World

This project demonstrates how to use MySQL to clean data using advanced MySQL concepts such as Window Functions, CTEs, Changing Data Types, and more.

## Global Layoffs EDA Project

### Introduction

The layoffs dataset offers detailed information on layoffs that have occurred in a number of companies in various locations. It contains the names of the companies, their locations, the number of laid-off employees, and the dates of the layoffs. 

The primary purpose of analyzing this dataset is to:
- Identify trends and evaluate the impact on different regions and industries.
- Understand the overall number of layoffs by nation and area.
- Pinpoint the organizations with the most layoffs.
- Observe how layoffs have changed over time.

### Problem Statement

This project aims to perform an exploratory data analysis (EDA) of layoffs in various locations, industries, and stages of the organization. 

**Goals:**
- Spot trends and analyze how layoffs have changed over time.
- Highlight the main causes of layoffs.
- Shed light on:
  - The most impacted industries and locations.
  - The timing of layoffs.
  - Characteristics of businesses experiencing high layoff rates.

## Data Overview

The layoffs dataset contains information about layoffs across various companies and locations. Each record in the dataset includes the following columns:

- **Company:** The name of the company where layoffs occurred.
- **Location:** The geographical location of the company.
- **Industry:** The industry to which the company belongs.
- **Total Laid Off:** The number of employees laid off from the company.
- **Percentage Laid Off:** The percentage of the company's workforce that was laid off.
- **Date:** The date on which the layoffs were reported.
- **Stage:** The funding or operational stage of the company at the time of layoffs.
- **Country:** The country where the layoffs occurred (e.g., Australia, United States).
- **Funds Raised (Millions):** The total amount of funds raised by the company in millions.

## Data Cleaning

Several cleaning steps were performed to prepare the layoffs dataset for exploratory data analysis:

1. **Resolving Missing Values:**
   - Missing values in the `percentage_laid_off` column were addressed.

2. **Date Transformation:**
   - The `date` column was transformed into the correct date format.

3. **Standardizing Entries:**
   - Inaccurate or unclear entries in columns such as `location`, `industry`, `stage`, and `country` were standardized.

4. **Removing Duplicates:**
   - Duplicates in the dataset were identified and eliminated.

5. **Ensuring Numerical Consistency:**
   - Numerical data, including `total_laid_off` and `funds_raised_millions`, were inspected for consistency and adjusted as needed.
