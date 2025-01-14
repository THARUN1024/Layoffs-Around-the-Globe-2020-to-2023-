# layoffs_around_the_world
This project demonstrates how to use MySQL clean data using different advanced MySQL Concepts such as Window Functions, CTEs, Changing Data Types and more.

Global Layoffs EDA Project
Introduction
The layoffs dataset offers detailed information on layoffs that have occurred in a number of companies in various locations. It contains the names of the companies, their locations, the number of laid-off employees, and the dates of the layoffs. The primary purpose of analyzing this dataset is to identify trends and evaluate the impact on different regions and industries. This analysis makes it easier to grasp the overall number of layoffs by nation and area, pinpoint the organizations that have had the most layoffs, and see how layoffs have changed over time.

Problem Statement
This project aims to perform an exploratory data analysis (EDA) of layoffs in various locations, industries, and stages of the organization. The goals are to spot trends, show how layoffs have changed over time, and draw attention to the main causes of layoffs. This study will shed light on the most impacted industries and locations, the timing of layoffs, and the traits of the businesses that are being laid off at the greatest rate.


Data Overview
The layoffs dataset contains information about layoffs across various companies and locations. Each record in the dataset includes the following columns:

Company: The name of the company where layoffs occurred
Location: The geographical location of the company
Industry: The industry to which the company belongs
Total Laid Off: The number of employees laid off from the company.
Percentage Laid Off: The percentage of the company's workforce that was laid off.
Date: The date on which the layoffs were reported
Stage: The funding or operational stage of the company at the time of layoffs
Country: The country where the layoffs occurred (e.g., Australia, United States).
Funds Raised (Millions): The total amount of funds raised by the company in millions

Data Cleaning
There were many cleaning stages that were taken in order to get the layoffs dataset ready for exploratory data analysis:

Missing values in the percentage_laid_off column were resolved.
The date column was transformed into the correct date format.
Inaccurate or unclear entries in columns such as location, industry, stage, and country were standardized.
Duplicates in the dataset were identified and eliminated.
Numerical data, including total_laid_off and funds_raised_millions, were inspected for consistency and adjusted as needed.
