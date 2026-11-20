USE semiconductor_course;

CREATE TABLE IF NOT EXISTS semiconductor_course.production_quarterly (
    region VARCHAR(40) NOT NULL,
    industry VARCHAR(40) NOT NULL,
    quarter_start DATE NOT NULL,
    production_index DECIMAL(16, 10) NOT NULL,
    month_count TINYINT UNSIGNED NOT NULL,
    is_provisional TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (region, industry, quarter_start)
) DEFAULT CHARSET=utf8mb4;

SELECT
    region,
    industry,
    DATE_SUB(month_start, INTERVAL MOD(MONTH(month_start) - 1, 3) MONTH) AS quarter_start,
    AVG(production_index) AS production_index,
    COUNT(*) AS month_count,
    MAX(is_provisional) AS is_provisional
FROM semiconductor_course.production_monthly
GROUP BY region, industry, quarter_start
HAVING COUNT(*) = 3
ORDER BY region, industry, quarter_start;

SELECT COUNT(*) AS row_count
FROM semiconductor_course.production_quarterly;

SELECT
    p.quarter_start,
    b.bsi AS actual_bsi,
    ROUND(p.production_index, 2) AS production_index,
    ROUND(
        (p.production_index / NULLIF(prev.production_index, 0) - 1) * 100,
        2
    ) AS production_qoq_pct
FROM production_quarterly AS p
JOIN bsi_quarterly AS b
    ON b.industry = p.industry
    AND b.quarter_start = p.quarter_start
    AND b.bsi_type = '현황'
LEFT JOIN production_quarterly AS prev
    ON prev.region = p.region
    AND prev.industry = p.industry
    AND prev.quarter_start = DATE_SUB(p.quarter_start, INTERVAL 3 MONTH)
WHERE p.region = '전국'
    AND p.industry = '반도체'
ORDER BY p.quarter_start;
