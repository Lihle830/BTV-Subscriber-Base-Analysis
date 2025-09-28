-----------------Data Analysis
-----------------two tables mixed, U-user table & V-viewer_record table
SELECT 
u.USERID,

IFNULL(u.Gender, 'Unknown') AS GenderStatus,
IFNULL(u.Province, 'Unknown') AS ProvinceStatus,
IFNULL(u.Race, 'Unknown') AS RaceStatus,

CASE
WHEN u.Race = 'W' THEN 'White'
WHEN u.Race = 'B' THEN 'Black'
WHEN u.Race = 'I' THEN 'Indian'
WHEN u.Race = 'C' THEN 'Coloured'
ELSE 'None'
END AS RaceStatus,
    
u.AGE,
CASE
WHEN u.AGE BETWEEN 0 AND 12 THEN 'Kids'
WHEN u.AGE BETWEEN 13 AND 21 THEN 'Teens'
WHEN u.AGE BETWEEN 22 AND 35 THEN 'Youth'
WHEN u.AGE BETWEEN 36 AND 65 THEN 'Adult'
ELSE 'Senior'
END AS AgeGroup,
    
TO_DATE(v.RECORDDATE2, 'YYYY/MM/DD HH24:MI') AS Record_date,
DAYNAME(TO_DATE(v.RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS day_name,
MONTHNAME(TO_DATE(v.RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS month_name,
TO_TIME(v.Recorddate2, 'YYYY/MM/DD HH24:MI') AS Viewer_time,

CASE
WHEN TO_TIME(v.Recorddate2,'YYYY/MM/DD HH24:MI') BETWEEN TIME '00:00:00' AND TIME '11:59:59' THEN 'Morning'
WHEN TO_TIME(v.Recorddate2,'YYYY/MM/DD HH24:MI') BETWEEN TIME '12:00:00' AND TIME '14:59:59' THEN 'Afternoon'
WHEN TO_TIME(v.Recorddate2,'YYYY/MM/DD HH24:MI') BETWEEN TIME '15:00:00' AND TIME '17:59:59' THEN 'Late Afternoon'
WHEN TO_TIME(v.Recorddate2,'YYYY/MM/DD HH24:MI') BETWEEN TIME '18:00:00' AND TIME '19:59:59' THEN 'Evening'
ELSE 'Night'
END AS time_buckets,
  
v.CHANNEL2

FROM BRIGHTTV_PROJECT.CHANNELS.USERS u
INNER JOIN BRIGHTTV_PROJECT.CHANNELS.VIEWER_RECORD v
ON u.USERID = v.USERID

GROUP BY all;

--------------------------------------------------------


