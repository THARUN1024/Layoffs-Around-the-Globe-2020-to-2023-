SELECT *
FROM layoffs;


SELECT *
FROM layoffs_staging;


SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date` ) AS  row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised_millions ) AS  row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;



SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


-- CREATING NEW TABLE 


CREATE TABLE layoffs_staging2 (
company text,
location text,
 industry text,
 total_laid_off int DEFAULT NULL,
 percentage_laid_off text,
 `date` text,
 stage text,
 country text,
 funds_raised_millions int DEFAULT NULL,
 row_num INT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

-- INSERTING DATA INTO  TABLE--> layoffs_stagging2
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS  row_num
FROM layoffs_staging;


--  CHECKING IF THERE IS ANY DUPLICATE

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- DELETING DUPLICATE 

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

--  VIEWING THE TABLE

SELECT *
FROM layoffs_staging2;


-- STANDARDIZING  THE DATA--
SELECT company, TRIM(company)
FROM layoffs_stagging2;


UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
set country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Editing date type to date column--

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y'); -- a way to convert date type into date column by string--

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;   -- NOW it is converted into date 

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON T1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;




UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2  t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Checking the values which are null in both total_laid_off and percentage_laid_off 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


-- Deleting the values which are null in both total_laid_off and percentage_laid_off 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;
-- Deleting row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;


-- this data cleaning project contains 
-- 1. Deleting duplicates
-- 2. Deleting null and empty values
-- 3. Deleting rows and columns 
-- 4. standardizing the data

-- NOW OUR DATA CLEANING IS COMPLETED 

-- EXPLORATORY DATA ANALYSIS

SELECT country, SUM(total_laid_off) AS total_off, COUNT(total_laid_off)
FROM layoffs_staging2
GROUP BY country
;

SELECT  COUNT(country)
FROM layoffs_staging2
WHERE country = 'United States'
AND total_laid_off IS NULL
;

SELECT  COUNT(country)
FROM layoffs_staging2
WHERE country = 'United States'
;


-- SELECT  `date`, SUM(total_laid_off) AS total_off, COUNT(total_laid_off)
SELECT  YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 2 DESC
;

SELECT *
FROM layoffs_staging2;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry        -- it is nescessarry to put group by when we use aggregate function eg SUM, MAX, ETC
ORDER BY 2 DESC
;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

SELECT  stage, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE stage = 'Post-IPO'
GROUP BY company 
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ;


WITH Rolling_total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 
)
SELECT `MONTH`, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
), company_year_rank AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
