
/*

Mahyar Sabouniaghdam
Bixi Project Deliverable 1
2022-11-18
mahyar_sabooni@yahoo.com

*/


-- ------------------------------------------------------  QUESTION 1  --------------------------------------------------------------

-- 1.1

SELECT COUNT(YEAR(start_date)) AS number_of_2016_trips
FROM bixi.trips
WHERE YEAR(start_date) = 2016;

-- 1.2

SELECT COUNT(YEAR(start_date)) AS number_of_2017_trips
FROM bixi.trips
WHERE YEAR(start_date) = 2017;

-- 1.3

SELECT MONTH(start_date) AS months_of_2016, COUNT(*) AS number_of_trips
FROM (
		SELECT *, YEAR(start_date) 
		FROM bixi.trips
		WHERE YEAR(start_date) = 2016 ) AS 2016_trips
GROUP BY months_of_2016;

-- 1.4

SELECT MONTH(start_date) AS months_of_2017, COUNT(*) AS number_of_trips
FROM (
		SELECT *, YEAR(start_date) 
		FROM bixi.trips
		WHERE YEAR(start_date) = 2017 ) AS 2017_trips
GROUP BY months_of_2017;

-- 1.5

SELECT year(start_date) AS year_, MONTH(start_date) AS month_, MAX(DAY(start_date)) AS number_of_active_days, CAST(( COUNT(*) / MAX(DAY(start_date))) AS DECIMAL(12,2)) AS average_number_of_trips_per_day
FROM (
		SELECT *, YEAR(start_date) 
		FROM bixi.trips
		WHERE YEAR(start_date) = 2016 )
        AS 2016_trips
GROUP BY month_
UNION
SELECT year(start_date) AS year_, MONTH(start_date) AS month_, MAX(DAY(start_date)) AS number_of_active_days, CAST(( COUNT(*) / MAX(DAY(start_date))) AS DECIMAL(12,2)) AS average_number_of_trips_per_day
FROM (
		SELECT *, YEAR(start_date) 
		FROM bixi.trips
		WHERE YEAR(start_date) = 2017 )
        AS 2017_trips
GROUP BY month_;

-- In this question, on the 11th month of the year (November), for both 2016 and 2017, 15 days are considered in the dataset.
-- To make average calculation more accurate, I decided to consider 15 days for the count of days on November.
-- I reach to the number of days on each month by writing MAX query to make the number of days dynamic. 

-- 1.6

CREATE TABLE IF NOT EXISTS working_table1
	( id INT AUTO_INCREMENT, PRIMARY KEY(id), number_of_active_days TINYINT, average_number_of_trips_per_day DECIMAL(12,2)) AS
SELECT *
FROM (
		SELECT year(start_date) AS year_, MONTH(start_date) AS month_, MAX(DAY(start_date)) AS number_of_active_days, CAST(( COUNT(*) / MAX(DAY(start_date))) AS DECIMAL(12,2)) AS average_number_of_trips_per_day
		FROM (
				SELECT *, YEAR(start_date) 
				FROM bixi.trips
				WHERE YEAR(start_date) = 2016 )
												AS 2016_trips
		GROUP BY month_
		UNION
		SELECT year(start_date) AS year_, MONTH(start_date) AS month_, MAX(DAY(start_date)) AS number_of_active_days, CAST(( COUNT(*) / MAX(DAY(start_date))) AS DECIMAL(12,2)) AS average_number_of_trips_per_day
		FROM (
				SELECT *, YEAR(start_date) 
				FROM bixi.trips
				WHERE YEAR(start_date) = 2017 )
												AS 2017_trips
		GROUP BY month_)   AS year_month_trip_table;


-- ------------------------------------------------------  QUESTION 2  --------------------------------------------------------------

-- 2.1

SELECT YEAR(start_date), is_member, COUNT(*) AS total_number_of_trips
FROM (
		SELECT *, YEAR(start_date) 
		FROM bixi.trips
		WHERE YEAR(start_date) = 2017 )
										AS 2017_trips
GROUP BY is_member;

-- 2.2

WITH t1 AS
(
	SELECT MONTH(start_date) AS months_of_2017, COUNT(*) AS number_of_trips_for_members
	FROM (
		   SELECT *, YEAR(start_date) 
		   FROM bixi.trips
		   WHERE YEAR(start_date) = 2017 AND is_member = 1 )
															 AS 2017_trips
	GROUP BY months_of_2017 )
SELECT *, CONCAT( ( number_of_trips_for_members * 100 / (SELECT SUM(number_of_trips_for_members) FROM t1)), ' ', '%' ) AS percentage_of_trips_for_members
FROM t1    
GROUP BY months_of_2017;

-- ------------------------------------------------------  QUESTION 3  --------------------------------------------------------------

-- 3.1   on JULY (7th month) demand for Bixi bikes are at its peak with 17.38 %  

WITH t1 AS
(
	SELECT MONTH(start_date) AS months_of_2017, COUNT(*) AS number_of_trips_for_members
	FROM (
		    SELECT *, YEAR(start_date) 
		    FROM bixi.trips
		    WHERE YEAR(start_date) = 2017 AND is_member = 1 )
																AS 2017_trips
	GROUP BY months_of_2017
    ORDER BY COUNT(*) DESC )
SELECT *, CONCAT( ( number_of_trips_for_members * 100 / (SELECT SUM(number_of_trips_for_members) FROM t1)), ' ', '%' ) AS percentage_of_trips_for_members
FROM t1    
GROUP BY months_of_2017;

-- 3.2

-- I am going to offer my promotion to non-members on the 4th and 5th months of the year. 
-- Since we have our peak at rhe month 7, it is a good opportunity to encourage people to use Bixi bikes on 4th and 5th months of the year when the weather is going to get warm.
-- (Knowing that because of the cold weather, they did not have the opportunity to ride a bike for couple of months)
-- And after that try to convert them to members before the peak season on months 7 and 8.
-- The promotion can be three partial discounts in one week (for example 20%, 15% and 10%) for their first three rides in one week,
-- And after that winning a free ride if they become a member. 
-- This type of promotion would increase the total number of users at the beginning of the season when the demand is low.
-- In this way people are encouraged to try Bixi bikes and after that with one free ride they are more likely to become a member before seasonal peak.  

-- ------------------------------------------------------  QUESTION 4  --------------------------------------------------------------

-- 4.1

SELECT trips.start_station_code, stations.name, COUNT(*) AS number_of_trips_started_form_the_station
FROM bixi.trips
JOIN bixi.stations
ON trips.start_station_code = stations.code
GROUP BY start_station_code
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 4.2

SELECT start_station_code, stations.name, number_of_trips_started_form_the_station
FROM (
		SELECT start_station_code, COUNT(*) AS number_of_trips_started_form_the_station
		FROM trips
		GROUP BY start_station_code
		ORDER BY COUNT(*) DESC
		LIMIT 5) AS top_5_starting_stations
JOIN stations
ON top_5_starting_stations.start_station_code = stations.code;

-- Q1 has 20 sec runtime but Q2 has 9 sec. We saw that by using a subquery the runtime became even less than half.
-- The reason is because we are joining fewer records when using subquery. We are somehow downsizing the table
-- and decreasing the number of records in the first place before performing the JOIN statement.
-- So, fewer records will take part in the JOIN statement leading to decreasing the runtime.

-- ------------------------------------------------------  QUESTION 5  --------------------------------------------------------------

-- 5.1

-- start_station

SELECT start_station_code, COUNT(*) AS number_of_starting_trips_from_Mackay , CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "time_of_day"
FROM trips
WHERE start_station_code = 6100
GROUP BY time_of_day
ORDER BY number_of_starting_trips_from_Mackay DESC;

-- end station

SELECT end_station_code, COUNT(*) AS number_of_ending_trips_from_Mackay , CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "time_of_day"
FROM trips
WHERE end_station_code = 6100
GROUP BY time_of_day
ORDER BY number_of_ending_trips_from_Mackay DESC;

-- 5.2

-- By exploring the google map, we can see that Mackay / de Maisonneuve station is one of the busiest places and streets in Montreal.
-- The Montreal Museum of Fine Arts, Concordia University, Hall Building Auditorium and many popular buildings and offices are located here.
-- In the dataset we can see that the number of starting trips in the mornings are relatively low comparing to ending trips. 
-- I expect that because people are traveling all over the city to Mackay, so low starting trips and high ending trips is reasonable in Mackay.
-- In the evenings and at nights the number of starting trips from here are more than ending trips. The reason is obvious.
-- Because people are going back to their places and homes from Mackay station.
-- In the afternoons the number of starting trips and ending trips are the same because people maybe go for lunch or commute near that neighborhood for meetings and then return back to their works.

-- In total, the number of both starting and ending trips in evenings and afternoons are higher than mornings and nights.
-- I think it is maybe because of the weather conditions. evenings and afternoons have warmer weather than nights and early mornings,
-- especially in a city like Montreal with cold weather.
-- Another reason is that evenings and afternoons are rush hours and people commute more, especially in a busy place like Mackay.

-- ------------------------------------------------------  QUESTION 6  --------------------------------------------------------------

-- 6.1

SELECT start_station_code, COUNT(*) AS number_of_starting_trips
FROM trips
GROUP BY start_station_code;

-- 6.2

SELECT start_station_code AS station_code, COUNT(*) AS number_of_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code;

-- 6.3

SELECT total_round_trips.station_code, number_of_starting_trips, number_of_round_trips, (number_of_round_trips / number_of_starting_trips ) AS fraction_of_round_trips_to_total_starting_trips
FROM (
	       SELECT start_station_code, COUNT(*) AS number_of_starting_trips
		   FROM trips
		   GROUP BY start_station_code ) 		AS total_trips
JOIN (
		   SELECT start_station_code AS station_code, COUNT(*) AS number_of_round_trips
		   FROM trips
		   WHERE start_station_code = end_station_code
		   GROUP BY start_station_code ) 		AS total_round_trips
ON total_trips.start_station_code = total_round_trips.station_code;

-- 6.4

SELECT total_round_trips.station_code, number_of_starting_trips, number_of_round_trips, (number_of_round_trips / number_of_starting_trips ) AS fraction_of_round_trips_to_total_starting_trips
FROM (
		   SELECT start_station_code, COUNT(*) AS number_of_starting_trips
		   FROM trips
		   GROUP BY start_station_code ) 		AS total_trips
JOIN (
		   SELECT start_station_code AS station_code, COUNT(*) AS number_of_round_trips
		   FROM trips
		   WHERE start_station_code = end_station_code
		   GROUP BY start_station_code ) 		AS total_round_trips
ON total_trips.start_station_code = total_round_trips.station_code
WHERE number_of_starting_trips >= 500 AND (number_of_round_trips / number_of_starting_trips ) >= 0.1;

-- 6.5

-- As it can be seen below, Question 6.5 query, stations Métro Jean-Drapeau, Métro Angrignon, Berlioz, LaSalle and Basile-Routhier are
-- top 5 stations with highest fraction of round trips to starting trips. This means that in these stations the number of people 
-- who had round trips compared to starting trips were relatively high. By examining these stations we will find out that they are all
-- Train stations. Now it is reasonable because it can be understood that people get out of the station,  
-- ride Bixi bikes to their destination (their workplace for example), ride back from the destination to the train station,
-- and then go back to their homes by the train again. It is rational that people are using trains for long distances and Bixi bikes for shorter distances.

-- So, main Metro stations have the highest number of round trips because so many people are using Bixi bikes for round trips starting
-- from train stations for short distances and then they get back to train stations to use trains for traveling long distances.

SELECT fraction_table.* , stations.name
FROM (
	  SELECT total_round_trips.station_code, number_of_starting_trips, number_of_round_trips, (number_of_round_trips / number_of_starting_trips ) AS fraction_of_round_trips_to_total_starting_trips
	  FROM (
			SELECT start_station_code, COUNT(*) AS number_of_starting_trips
			FROM trips
			GROUP BY start_station_code ) 		AS total_trips
	  JOIN (
			SELECT start_station_code AS station_code, COUNT(*) AS number_of_round_trips
			FROM trips
			WHERE start_station_code = end_station_code
			GROUP BY start_station_code ) 		AS total_round_trips
	   ON total_trips.start_station_code = total_round_trips.station_code
	   WHERE number_of_starting_trips >= 500 AND (number_of_round_trips / number_of_starting_trips ) >= 0.1
																											 ) AS fraction_table
JOIN stations
ON fraction_table.station_code = stations.code
ORDER BY fraction_of_round_trips_to_total_starting_trips DESC;


