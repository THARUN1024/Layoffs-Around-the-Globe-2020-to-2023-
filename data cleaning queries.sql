-- Retrieve all rows and columns from the 'layoffs' table to inspect the data
SELECT * 
FROM layoffs;

-- Retrieve all rows and columns from the 'layoffs_staging' table for data analysis
SELECT * 
FROM layoffs_staging;

-- Identify potential duplicate rows based on several key columns using ROW_NUMBER() 
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS duplicate_row_number
FROM layoffs_staging;

-- Use a CTE to identify duplicates based on multiple columns (e.g., company, location, industry, etc.)
WITH duplicates AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_row_number
    FROM layoffs_staging
)
-- Retrieve rows where the duplicate row number is greater than 1, indicating duplicate entries
SELECT *
FROM duplicates
WHERE duplicate_row_number > 1;

-- Create a new table ('layoffs_staging_v2') with the same structure as 'layoffs_staging'
-- and an additional column for tracking row numbers of duplicate entries
CREATE TABLE layoffs_staging_v2 (
  company text,
  location text,
  industry text,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off text,
  `date` text,
  stage text,
  country text,
  funds_raised_millions INT DEFAULT NULL,
  duplicate_row_number INT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Verify the structure of the newly created table
SELECT * FROM layoffs_staging_v2;

-- Insert data from 'layoffs_staging' into 'layoffs_staging_v2', adding a row number to track duplicates
INSERT INTO layoffs_staging_v2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_row_number
FROM layoffs_staging;

-- Delete rows from 'layoffs_staging_v2' where the duplicate row number is greater than 1, effectively removing duplicates
DELETE
FROM layoffs_staging_v2
WHERE duplicate_row_number > 1;

-- Verify that duplicates have been removed and the data is clean
SELECT *
FROM layoffs_staging_v2;

-- Standardize company names by trimming extra spaces
UPDATE layoffs_staging_v2
SET company = TRIM(company);

-- Fix industry names starting with 'Crypto' by updating them to 'Crypto'
UPDATE layoffs_staging_v2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country names by trimming trailing periods (e.g., 'United States.' → 'United States')
UPDATE layoffs_staging_v2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert 'date' column to proper DATE format
UPDATE layoffs_staging_v2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter the column type to ensure it is in DATE format
ALTER TABLE layoffs_staging_v2
MODIFY COLUMN `date` DATE;

-- Update industry to NULL where it is empty (i.e., industry is an empty string)
UPDATE layoffs_staging_v2
SET industry = NULL
WHERE industry = '';

-- Fill NULL values in the 'industry' column by joining with the same table and matching on 'company'
UPDATE layoffs_staging_v2 AS t1
JOIN layoffs_staging_v2 AS t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove rows where both total_laid_off and percentage_laid_off are NULL
DELETE
FROM layoffs_staging_v2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the 'duplicate_row_number' column as it is no longer needed
ALTER TABLE layoffs_staging_v2
DROP COLUMN duplicate_row_number;

-- Group by country and calculate total layoffs and count of rows
SELECT country, SUM(total_laid_off) AS total_off, COUNT(total_laid_off)
FROM layoffs_staging_v2
GROUP BY country;

-- Count how many records have NULL in total_laid_off for the United States
SELECT COUNT(country)
FROM layoffs_staging_v2
WHERE country = 'United States'
AND total_laid_off IS NULL;

-- Group by year and sum layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_staging_v2
GROUP BY YEAR(`date`)
ORDER BY total_off DESC;

-- Total layoffs by company, ordered by the number of layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_v2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Total layoffs by industry, ordered by the number of layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_v2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Total layoffs by country, ordered by the number of layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_v2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Total layoffs by stage, ordered by the number of layoffs
SELECT stage, SUM(total_laid_off) AS total_off
FROM layoffs_staging_v2
GROUP BY stage
ORDER BY total_off DESC;

-- Total layoffs for companies in the 'Post-IPO' stage, ordered by the number of layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_v2
WHERE stage = 'Post-IPO'
GROUP BY company
ORDER BY total_laid_off DESC;

-- Summing layoffs by month (extracting month and year from date)
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging_v2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`;

-- Rolling total of layoffs by month
WITH rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging_v2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
    ORDER BY `month`
)
SELECT `month`, SUM(total_off) OVER (ORDER BY `month`) AS rolling_total
FROM rolling_total;

-- Layoffs analysis by year for each company
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_v2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- Ranking companies by layoffs per year and fetching top 5
WITH company_year AS (
    SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging_v2
    GROUP BY company, YEAR(`date`)
), company_year_rank AS (
    SELECT *,
    DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE year IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

