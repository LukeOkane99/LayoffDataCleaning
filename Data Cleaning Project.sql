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

DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;
