/*1.)
Query: Summary statistics for daily social media use across all users
Purpose: Quick overview of the usage in the dataset and to understand typical usage patterns
Output: total user count, avg minutes spent, min minutes, max minutes, standard deviation
*/
SELECT 
    COUNT(*) AS total_users,							
    AVG(Daily_Use) AS avg_minutes,
    MIN(Daily_Use) AS min_minutes,
    MAX(Daily_Use) AS max_minutes,
    STDDEV(Daily_Use) AS stddev_minutes
FROM soc_med_emotion; 

/*2.)
Query: To change daily minute usage from original dataset as too long. Was initially: `Daily_Usage_Time (minutes)`
Result: Changed column to `Daily_Use` and set type to INT
*/
ALTER TABLE soc_med_emotion
CHANGE `Daily_Usage_Time (minutes)` `Daily_Use` INT;

/*3.)
Query: 2x CTE to calculate avg_use per platform and the count of records by platform
Output: Each platform's average use and record count
*/
WITH avg_use_platform AS (
	SELECT 
		Platform, 
		AVG(Daily_use) AS avg_use
	FROM soc_med_emotion
	GROUP BY Platform
),
platform_count AS (
	SELECT 
		Platform, 
		COUNT(*) AS cnt
	FROM soc_med_emotion 
	GROUP BY Platform
)
SELECT 
	ap.Platform, 
    ap.avg_use, 
    pc.cnt
FROM avg_use_platform AS ap
INNER JOIN platform_count AS pc
	ON ap.Platform = pc.Platform
ORDER BY ap.avg_use DESC;

/*4.)
Query: Display platform, overall average time spent across the 7 platforms, average usage per platform, % difference usage of platform compared to overall_avg time spent
Output: Overall avg (minutes), platform avg (minutes) and % difference from overall avg (formatted)
*/
SELECT Platform,
	(SELECT ROUND(AVG(daily_use),0) FROM soc_med_emotion) AS overall_avg,
	ROUND(AVG(daily_use),0) AS platform_avg,
	-- converted ratio to percentage by -1 on ratio * 100 eg. (1.59 - 1)*100 = 59.9% (concat % to display)
    CONCAT(ROUND((AVG(daily_use)/(SELECT AVG(daily_use) FROM soc_med_emotion)-1)*100,1),'%') AS overall_avg_diff 
FROM soc_med_emotion
GROUP BY Platform
ORDER BY (AVG(daily_use)/(SELECT AVG(daily_use) FROM soc_med_emotion) - 1) DESC; 

/*5.)
Query: Binned 3x age group, calculation of % of the platform used out of record count for each age group
Output: The total count and the distribution of platform for each age group (Percentages are within each age group)
(Dataset ages are 21-35 only)
*/ 
SELECT
	CASE 
		WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
		END AS age_group, 
        COUNT(*) AS total_users,
	CONCAT(ROUND(COUNT(CASE WHEN platform = 'Instagram' THEN 1 END)/COUNT(*)*100, 0),'%') AS instagram_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Facebook' THEN 1 END)/COUNT(*)*100, 0),'%') AS facebook_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Snapchat' THEN 1 END)/COUNT(*)*100, 0),'%') AS snapchat_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Whatsapp' THEN 1 END)/COUNT(*)*100, 0),'%') AS whatsapp_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Twitter' THEN 1 END)/COUNT(*)*100, 0),'%') AS twitter_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'LinkedIn' THEN 1 END)/COUNT(*)*100, 0),'%') AS linkedIn_pct,
	CONCAT(ROUND(COUNT(CASE WHEN platform = 'Telegram' THEN 1 END)/COUNT(*)*100, 0),'%') AS telegram_pct
FROM soc_med_emotion
GROUP BY age_group;