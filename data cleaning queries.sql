-- Retrieve all rows and columns from the 'layoffs' table
SELECT * 
FROM layoffs;

-- Fetch all rows from the 'layoffs_staging' table
SELECT * 
FROM layoffs_staging;

-- Identify duplicates based on specific columns in 'layoffs_staging'
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS duplicate_row_number
FROM layoffs_staging;

-- Detect duplicates in 'layoffs_staging' by checking multiple columns
WITH duplicates AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_row_number
    FROM layoffs_staging
)
SELECT *
FROM duplicates
WHERE duplicate_row_number > 1;


-- Create a new table with a similar structure to 'layoffs_staging', but rename it to 'layoffs_cleaned'
CREATE TABLE layoffs_cleaned (
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

-- Check the newly created table 'layoffs_cleaned'
SELECT *
FROM layoffs_cleaned;

-- Insert data into the new table 'layoffs_cleaned' with row numbers to identify duplicates
INSERT INTO layoffs_cleaned
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_row_number
FROM layoffs_staging;

-- Check for duplicate rows in 'layoffs_cleaned'
SELECT *
FROM layoffs_cleaned
WHERE duplicate_row_number > 1;

-- Remove duplicate rows from 'layoffs_cleaned'
DELETE
FROM layoffs_cleaned
WHERE duplicate_row_number > 1;

-- View the cleaned table after removing duplicates
SELECT *
FROM layoffs_cleaned;

-- Standardize company names by trimming extra spaces
SELECT company, TRIM(company) AS company_trimmed
FROM layoffs_cleaned;

-- Update company names to remove any extra spaces
UPDATE layoffs_cleaned
SET company = TRIM(company);

-- Update industry names that start with 'Crypto' to 'Crypto'
UPDATE layoffs_cleaned
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country names by removing trailing periods (e.g., "United States.")
UPDATE layoffs_cleaned
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Change date format to proper date format
UPDATE layoffs_cleaned
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the 'date' column to have the correct DATE type
ALTER TABLE layoffs_cleaned
MODIFY COLUMN `date` DATE;

-- Set empty industry values to NULL
UPDATE layoffs_cleaned
SET industry = NULL
WHERE industry = '';

-- Fill in missing industry values based on matching company data
UPDATE layoffs_cleaned AS t1
JOIN layoffs_cleaned AS t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Delete rows where both total_laid_off and percentage_laid_off are NULL
DELETE
FROM layoffs_cleaned
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the 'duplicate_row_number' column from the table after cleaning
ALTER TABLE layoffs_cleaned
DROP COLUMN duplicate_row_number;

-- Perform Exploratory Data Analysis (EDA) to summarize the data

-- Total layoffs and count by country
SELECT country, SUM(total_laid_off) AS total_off, COUNT(total_laid_off)
FROM layoffs_cleaned
GROUP BY country;

-- Count the number of rows with NULL total_laid_off for 'United States'
SELECT COUNT(country)
FROM layoffs_cleaned
WHERE country = 'United States'
AND total_laid_off IS NULL;

-- Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by stage (e.g., Pre-IPO, Post-IPO)
SELECT stage, SUM(total_laid_off) AS total_off
FROM layoffs_cleaned
GROUP BY stage
ORDER BY 2 DESC;

-- Total layoffs in 'Post-IPO' stage by company
SELECT company, SUM(total_laid_off)
FROM layoffs_cleaned
WHERE stage = 'Post-IPO'
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs by month (year-month)
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_cleaned
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

-- Rolling total of layoffs by month
WITH rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
    FROM layoffs_cleaned
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
    ORDER BY 1
)
SELECT `month`, SUM(total_off) OVER (ORDER BY `month`) AS rolling_total
FROM rolling_total;

-- Yearly layoffs by company, ordered by total layoffs
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Top 5 companies with the most layoffs per year
WITH company_year AS (
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_cleaned
    GROUP BY company, YEAR(`date`)
), company_year_rank AS (
    SELECT *,
    DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY total_laid_off DESC) AS rank
    FROM company_year
    WHERE YEAR IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE rank <= 5;
 
