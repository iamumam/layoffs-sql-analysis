SELECT * FROM world_layoffs.layoffs;

CREATE TABLE world_layoffs.layoffs_staging (LIKE world_layoffs.layoffs INCLUDING ALL);

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;

SELECT * FROM world_layoffs.layoffs_staging;


-- CEK DUPLIKAT 
SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions)
AS rn
FROM world_layoffs.layoffs_staging
) n
WHERE rn > 1;


-- BUAT TABLE BARU 
CREATE TABLE world_layoffs.layoffs_staging2 AS
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions) 
AS duplicat_data
FROM world_layoffs.layoffs_staging;

-- DELETE DUPLICAT 
DELETE FROM world_layoffs.layoffs_staging2 
WHERE duplicat_data = 2;

-- STANDARISASI DATA
SELECT DISTINCT industry FROM world_layoffs.layoffs_staging2 ORDER BY industry;

-- UBAH NILAI KOSONG MENJADI NULL
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- UPDATE NILAI INDUSTRY YANG NULL MENGIKUTI COMPANY YANG SAMA
UPDATE world_layoffs.layoffs_staging2 t1
SET industry = t2.industry
FROM world_layoffs.layoffs_staging2 t2
WHERE t1.company = t2.company
	AND t1.industry IS NULL
	AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_staging2 
WHERE industry IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2
WHERE company = 'Bally''s Interactive'

UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Cyrpto')

SELECT DISTINCT country FROM world_layoffs.layoffs_staging2 ORDER BY country;

UPDATE world_layoffs.layoffs_staging2
SET country = 'United States'
WHERE country = 'United States.'

SELECT date 
FROM world_layoffs.layoffs_staging2

SELECT * FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM world_layoffs.layoffs_staging2 
WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;

SELECT * FROM world_layoffs.layoffs_staging2;

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN duplicat_data; 

