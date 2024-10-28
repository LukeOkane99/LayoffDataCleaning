-- Exploratory Data Analysis Project for Layoff Data --


-- Looking at the percentage to see how big the layoffs where
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2
;

-- Determine which companies had 1 (100%) of their company laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

-- Determine how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- Determine the total amount laid off for each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

-- Determine the date range for the layoff data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;

-- Determine the total laid off by each industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;

-- Determine the total laid off by each country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- Determine the total laid off for each year (2020 - 2023)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

-- Determine the total laid off for each stage of a companie's lifecycle
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
;

-- Determining the total layoffs for each month
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
;

-- Using a CTE to get a rolling total for layoffs per month
WITH Rolling_Total AS
(
	SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `month`
	ORDER BY 1 ASC
)
SELECT `month`, total_off , SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total
;


-- Determining the total laid off for each company per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

-- Using a CTE to rank the top 5 companies in terms of layoffs in descending order, for each year
WITH Company_Year (company, years, total_laid_off) AS 
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS	
(
	SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
	FROM Company_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

