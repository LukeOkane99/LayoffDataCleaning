-- Data Cleaning --

SELECT *
FROM layoffs
;

-- Steps for Project --

-- 1. Remove Duplicates (if any are present) --
-- 2. Standardize the Data --
-- 3. Null Values or Blank Values --
-- 4. Remove any unecessary Columns --


-- Create layoffs_staging table, with the same columns as the layoffs table
CREATE TABLE layoffs_staging
LIKE layoffs
;

SELECT *
FROM layoffs_staging
;

-- Copy data from the layoffs table into layoffs_staging table
INSERT layoffs_staging
SELECT *
FROM layoffs
;

SELECT *
FROM layoffs_staging
;



-- 1. Remove Duplicates (if any are present) --

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
;

WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'
;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
;


-- Populate layoffs_staging2 table with all columns from layoffs_staging and the new row_num column
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
;

-- Remove the duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

-- No duplicates present anymore
SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;


-- 2. Standardize the Data --

-- Trim company name to remove any unecessary whitespace
SELECT company, TRIM(company)
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;


-- Merge the different Crypto industry entries into 1 distinct industry 
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;


-- Get rid of 'United States.' and ensure it is 'United States'
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
;


-- Ensure that Dates are formatted properly
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y') as formatted_date
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y')
;

SELECT `date`
FROM layoffs_staging2
;

-- Change Date type of Date Column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE
;


-- 3. Null Values or Blank Values --
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;

SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
;


-- 4. Remove any unecessary Columns / Rows --
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;