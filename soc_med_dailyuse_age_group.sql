-- 1.)
-- Query: Summary statistics for daily social media use across all users
-- Purpose: Quick overview of the usage in the dataset and to understand typical usage patterns
-- Insight: Understand typical usage, variability, and extremes
SELECT 
    COUNT(*) AS total_users,							
    AVG(Daily_Use) AS avg_minutes,
    MIN(Daily_Use) AS min_minutes,
    MAX(Daily_Use) AS max_minutes,
    STDDEV(Daily_Use) AS stddev_hours
FROM soc_med_emotion; 

-- 2.)
-- Query: To change daily minute usage from original dataset as too long. Was initially: `Daily_Usage_Time (minutes)`
-- Purpose: Changed column to `Daily_Use` for readability
ALTER TABLE soc_med_emotion
CHANGE `Daily_Usage_Time (minutes)` `Daily_Use` INT;

-- 3.)
-- Query: 2x CTE to calculate avg_use per platform and the count of records by platform
-- Purpose: Comparison avg_use by platform and count of records by platform. 
-- Insight: Instagram is the platform with the highest avg usage in the dataset, as it has the most users and the highest avg time spent among all platforms
WITH avg_use_platform as 
(
SELECT Platform, AVG(Daily_use) as avg_use
FROM soc_med_emotion
GROUP BY Platform
order by avg_use DESC),
count AS
(SELECT Platform, COUNT(*) AS cnt
FROM soc_med_emotion 
GROUP BY Platform)
SELECT a.Platform, avg_use, cnt
FROM avg_use_platform as a
	INNER JOIN count as c
ON a.Platform = c.Platform;

-- 4.)
-- Query: Display platform, overall average time spent across the 7 platforms, average usage per platform, % difference usage of platform compared to overall_avg time spent
-- Purpose: Identify which platforms have above/below average engagement
-- Insight: Helps quantify how each platform differs from the overall dataset usage
SELECT Platform,
	(SELECT ROUND(AVG(daily_use),0) FROM soc_med_emotion) AS overall_avg,
	ROUND(AVG(daily_use),0) AS platform_avg,
-- converted ratio to percentage by -1 on ratio * 100 eg. (1.59 - 1)*100 = 59.9% (concat % to display)
	CONCAT(ROUND((AVG(daily_use)/(SELECT ROUND(AVG(daily_use),0) FROM soc_med_emotion)-1)*100,1),'%') AS overall_avg_diff
FROM soc_med_emotion
GROUP BY Platform
ORDER BY overall_avg_diff DESC;

-- 5.)
-- Query: Binned 3x age group, calculation of % of the platform used out of total count of each age group
-- Purpose: Which social media are popular amongst age groups 21-25 (306), 26-30(388), 31-35(230)
-- Insight: Shows distribution of platform preference across age ranges
SELECT
	CASE 
		WHEN Age BETWEEN 21 AND 25 THEN '21-25'
        WHEN Age BETWEEN 26 AND 30 THEN '26-30'
        WHEN Age BETWEEN 31 AND 35 THEN '31-35'
		END AS age_group, COUNT(*) AS total_users,
	CONCAT(ROUND(COUNT(CASE WHEN platform = 'Instagram' THEN 1 END)/COUNT(*)*100, 0),'%') AS instagram_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Facebook' THEN 1 END)/COUNT(*)*100, 0),'%') AS facebook_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Snapchat' THEN 1 END)/COUNT(*)*100, 0),'%') AS snapchat_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Whatsapp' THEN 1 END)/COUNT(*)*100, 0),'%') AS whatsapp_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'Twitter' THEN 1 END)/COUNT(*)*100, 0),'%') AS twitter_pct,
    CONCAT(ROUND(COUNT(CASE WHEN platform = 'LinkedIn' THEN 1 END)/COUNT(*)*100, 0),'%') AS linkedIn_pct,
	CONCAT(ROUND(COUNT(CASE WHEN platform = 'Telegram' THEN 1 END)/COUNT(*)*100, 0),'%') AS telegram_pct
FROM soc_med_emotion
GROUP BY age_group;















