DROP TABLE IF EXISTS orders;

CREATE TABLE orders(
 id_order CHAR(36) PRIMARY KEY,
 id_user VARCHAR(15),
 status VARCHAR(15),
 date_created TIMESTAMPTZ,
 amount NUMERIC(6, 2),
 id_region SMALLINT
);

COPY orders
FROM '/tmp/task_1.csv'
WITH (FORMAT CSV, HEADER);

SELECT 
	id_user, 
	total_spend,
	round(total_spend / mean_region_spend * 100,2) || '%' AS perc_of_region_mean
FROM (
	SELECT
		id_user,
		SUM(amount) AS total_spend,
		AVG(SUM(amount)) OVER (PARTITION BY id_region) AS mean_region_spend
	FROM
		orders
	WHERE status = 'success'
	GROUP BY
		id_user, id_region
) AS users_regions
WHERE
	total_spend > mean_region_spend
ORDER BY 
	round(total_spend / mean_region_spend * 100,0) DESC;