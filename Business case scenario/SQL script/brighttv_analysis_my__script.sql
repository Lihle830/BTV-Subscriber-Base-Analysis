-----------------------------------EDA: Understanding my data set
-------------------------------Combining two tables first before coding

---------workspace.audience.users_profile (table1)
---------workspace.audience.viewer_records (table2)

------------------------------------------This code will show all my columns
SELECT * 
FROM workspace.audience.users_profile
LIMIT 5;

------------------------------------------Counting rows and unique users
SELECT 
COUNT(*) as total,
COUNT(DISTINCT UserID) as unique
FROM workspace.audience.users_profile;

---------------------------------------------Duplicates checking
SELECT UserID, COUNT(*) as occurrences
FROM workspace.audience.users_profile
GROUP BY UserID
HAVING COUNT(*) > 1;

----------------------------------------------Checking gender data
SELECT DISTINCT gender
FROM workspace.audience.users_profile;

SELECT DISTINCT
  CASE
  WHEN gender = 'None' THEN 'unknown'
  WHEN gender = 'Null' THEN 'unknown'
  ELSE gender
  END as gender
  FROM workspace.audience.users_profile;

--------------------------------------------Checking race data
SELECT DISTINCT race
FROM workspace.audience.users_profile;

SELECT DISTINCT
  CASE
    WHEN race = 'None' THEN 'undefined'
    WHEN race = 'Null' THEN 'undefined'
    WHEN race = 'other' THEN 'undefined'
    ELSE race
    END as race
    FROM workspace.audience.users_profile;

---------------------------------------Checking province data
SELECT DISTINCT province
FROM workspace.audience.users_profile;

SELECT DISTINCT
  CASE
    WHEN province = 'None' THEN 'unknown'
    WHEN province = 'Null' THEN 'unknown'
    ELSE province
    END as province
    FROM workspace.audience.users_profile;

---------------------------------------Checking age data
SELECT age
FROM workspace.audience.users_profile
WHERE age IS NULL;

SELECT MIN(age) as min_age,
       MAX(age) as max_age
FROM workspace.audience.users_profile;

-----------------------------Checking viewer details for marketing
SELECT `Social Media Handle`
FROM workspace.audience.users_profile
WHERE `Social Media Handle` IS NULL;

SELECT Email
FROM workspace.audience.users_profile
WHERE Email IS NULL;

------------Viewership table.(table 2)
----------------------------------------This code will show all my columns
SELECT * 
FROM workspace.audience.viewer_records
LIMIT 5;

-------------------------------------------Counting rows
SELECT COUNT(*)
FROM workspace.audience.viewer_records;

------------------------------------------Checking unique users
SELECT COUNT(DISTINCT UserID) as unique
FROM workspace.audience.viewer_records;

-----------------Checking duplicates
SELECT UserID, COUNT(*) AS Occurrences
FROM workspace.audience.viewer_records
GROUP BY UserID
HAVING COUNT(*) > 1;

------------------------------------------Converting date from string to timestamp
SELECT
To_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm') AS RecordDate2_ts
FROM workspace.audience.viewer_records;
--------------------------------------------CHECKING NULL
SELECT Channel2 
FROM workspace.audience.viewer_records
WHERE Channel2 IS NULL;
---------------------------------------------------------------------------------------------------

--------------Combining the tables 

-- Create cleaned_users_profile temp view

CREATE OR REPLACE TEMP VIEW cleaned_users_profile AS
SELECT
  UserID as userid,
  Age as age,
  CASE
    WHEN age BETWEEN 0 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 21 THEN 'Teens'
    WHEN age BETWEEN 22 AND 35 THEN 'Youth'
    WHEN age BETWEEN 36 AND 65 THEN 'Adult'
    WHEN age > 65 THEN 'Senior'
    ELSE 'Unknown'
    END AS agegroup,
    CASE
    WHEN Gender = 'None' OR Gender = 'Null' THEN 'unknown'
    ELSE Gender
  END as gender,
  CASE
    WHEN Race = 'None' OR Race = 'Null' OR Race = 'other' THEN 'undefined'
    ELSE Race
  END as race,
  CASE
    WHEN Province = 'None' OR Province = 'Null' THEN 'unknown'
    ELSE Province
  END as province
FROM workspace.audience.users_profile;

-- Create cleaned_viewer_records temp view
CREATE OR REPLACE TEMP VIEW cleaned_viewer_records AS 
SELECT
  UserID as userid,
  Channel2 as channel2,
  `Duration 2` as duration_2,
  to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm') AS RecordDate2_ts,
  CASE 
    WHEN hour(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm')) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN hour(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm')) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN hour(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm')) BETWEEN 17 AND 20 THEN 'Evening'
    ELSE 'Night'
    END AS time_bucket,
    CASE 
    WHEN dayofweek(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm')) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'    
    END AS daytype,
  date_format(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm'), 'yyyy-MM-dd') AS watchdate,
  date_format(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm'), 'HH:mm') AS watchtime,
  date_format(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm'), 'MMMM') AS month,
  date_format(to_timestamp(RecordDate2, 'dd/MM/yyyy HH:mm'), 'EEEE') AS day_name
FROM workspace.audience.viewer_records;

-- Create final_aggregated_view temp view
CREATE OR REPLACE TEMP VIEW final_aggregated_view AS
SELECT
  A.province,
  A.race,
  A.gender,
  A.agegroup,
  B.channel2,
  B.daytype,
  B.time_bucket,
  B.month,
  B.day_name,
  B.watchdate,
  B.watchtime,
COUNT(DISTINCT A.userid) AS TotalUsers
FROM cleaned_users_profile A
INNER JOIN cleaned_viewer_records B
ON A.userid = B.userid
GROUP BY
  A.province,
  A.race,
  A.gender,
  A.agegroup,
  B.channel2,
  B.daytype,
  B.time_bucket,
  B.month,
  B.day_name,
  B.watchdate,
  B.watchtime;
  -- Query the final view
SELECT * FROM final_aggregated_view;
