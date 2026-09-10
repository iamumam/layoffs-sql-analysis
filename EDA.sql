SELECT * FROM world_layoffs.layoffs_staging2;

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;

SELECT * FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = '1' AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;

SELECT company, total_laid_off 
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY 2 DESC
LIMIT 5;

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;


SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2 
GROUP BY location
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;

SELECT RIGHT(date,4), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY RIGHT(date,4)
ORDER BY 1 ASC;

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

WITH Company_Year AS 
(
  SELECT company, RIGHT(date, 4) AS years, SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY company, RIGHT(date, 4)
  HAVING SUM(total_laid_off) IS NOT NULL
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
-- WHERE total_laid_off IS NOT NULL
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY dates
ORDER BY dates ASC; 

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
