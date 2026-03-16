CREATE database ftn_pro;
use ftn_pro;

create table commuters(
	commuter_id int primary key,
    commuter_name varchar(50),
    age int,
    gender varchar(10),
    city_zone varchar(50),
    card_type varchar(50)
);

Select * from commuters;

-- 
 
create table stations(
	station_id int primary key,
    station_name varchar(50),
    zone varchar(50),
    station_type varchar(50)
); 

create table vehicle(
	vehicle_id int primary key,
    vehicle_type varchar(50),
    capacity int,
    manufacture_year int
);

Select * from vehicle;

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    source_station INT,
    destination_station INT,
    distance_km INT,
    route_type VARCHAR(20),

    FOREIGN KEY (source_station) REFERENCES stations(station_id),
    FOREIGN KEY (destination_station) REFERENCES stations(station_id)
);

 create table routes_assignment(
	assignment_id int primary key,
    route_id int,
    vehicle_id int,
    
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
 );
 
 
CREATE TABLE trips(
	trip_id int primary key,
    commuter_id int,
    route_id int,
    trip_date date,
    start_time time,
    end_time time,
    fare int,
    
    FOREIGN KEY (commuter_id) REFERENCES commuters(commuter_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
); 

select * from trips;

CREATE TABLE maintenace(
	maintenance_id int primary key,
    vehicle_id int,
    maintenance_date date,
    cost decimal(10,2),
    issue_type varchar(50),
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
);

select * from maintenace;


-- 3.	Restrict route_type to Metro/Bus.   

alter table routes
ADD constraint chk_type
check(route_type IN('Metro','Bus'));

-- 4.	Ensure fare > 0.

ALTER TABLE trips
ADD constraint chk_fare
check(fare > 0);

-- 5.	Add index on trip_date.

CREATE INDEX idx_trip_date
ON trips(trip_date);

SHOW INDEX FROM trips;

-- 6.	Insert 20 new commuters.

select * from commuters;

insert into commuters values
		(6,"Smit",22,"M","South","Student Pass"),
        (7,"Akshay",26,"M","North","Pay Per Ride"),
        (8,"Krish",20,"M","South","Student Pass"),
        (9,"Anjali",20,"F","East","Pay Per Ride"),
        (10,"Jay",30,"M","West","Monthly Pass"),
        (11,"Deep",22,"M","South","Student Pass"),
        (12,"Pintoo",28,"M","Central","Pay Per Ride"),
        (13,"Harsh",25,"M","West","Pay Per Ride"),
        (14,"Manav",56,"M","South","Senior Citizen"),
        (15,"Karan",28,"M","Central","Pay Per Ride"),
        (16,"Yuvi",18,"M","Central","Student Pass"),
        (17,"Vaishali",30,"F","South","Pay Per Ride"),
        (18,"Dhaval",32,"M","North","Pay Per Ride"),
        (19,"Jaydeep",30,"M","East","Monthly Pass"),
        (20,"Vaibhav",27,"M","West","Pay Per Ride"),
        (21,"Ramila",56,"F","South","Senior Citizen"),
        (22,"Anmol",22,"M","South","Student Pass"),
        (23,"Mahi",28,"F","East","Monthly Pass"),
        (24,"Rahul",25,"M","South","Student Pass"),
        (25,"Mehul",26,"M","South","Monthly Pass");
        
Select * from commuters;

-- 7.	Update vehicle capacity by +10%.

SET SQL_SAFE_UPDATES = FALSE;

Select * from vehicle; 

update vehicle set capacity = capacity + (capacity * .1); 

-- 8.	Delete trips before 2023.

delete from trips where extract(YEAR FROM trip_date) < 2023; 

-- 9.	Change card_type of senior citizens.

Select * from commuters;
update commuters set card_type = "senior citizens" where age > 55; 

Select * from commuters;

-- 10.	Add new station "Kurla". 

Select * from stations;
insert into stations values(106,"Kurla","West","Bus"); 


-- 11.	List all metro stations. 

Select * from stations
where station_type = "Metro";

-- 12.	Show commuters using Monthly Pass

Select * from commuters
where card_type = "Monthly Pass";  

-- 13.	Find total trips.
Select count(*) as total_trips from trips;

-- 14.	Show distinct city zones.

Select distinct(city_zone) as cityzone from commuters;


-- 15.	Average fare.

Select ROUND(avg(fare),2) as average_fare from trips;
 
-- 16.	Total revenue per day.

Select trip_date,SUM(fare) as total_revenue from trips
group by trip_date; 

-- 17.	Revenue per route

Select * from trips; 
Select route_id,SUM(fare) as total_revenue_per_route from trips
group by route_id; 

-- AVG Trip Duration

Select  avg(timestampdiff(MINUTE,start_time,end_time)) as avg_trip_duration
from trips;

-- 19. Total Maintainace Cost 

Select * from maintenace;
Select SUM(cost) as total_cost from maintenace;

-- 20.	Most used route.

Select * from trips;

Select route_id,count(*) as trip_count
from trips
group by route_id
order by trip_count DESC
limit 1;

-- 21.	Show commuter with route info.

Select * from commuters;
select * from trips;

Select c.commuter_name,r.route_type
from commuters as c
JOIN trips as t
on c.commuter_id = t.commuter_id
join routes as r
on r.route_id = t.route_id;


-- 22.	Route with station names.

Select * from routes; 
Select * from stations;

SELECT 
    s.station_name AS source_station,
    s1.station_name AS destination_station
FROM routes AS r
JOIN stations AS s
    ON r.source_station = s.station_id
JOIN stations AS s1
    ON r.destination_station = s1.station_id;
    
    
-- 23.	Vehicle assigned to each route.

Select * from vehicle;
select * from routes;
Select * from routes_assignment;

SELECT r.route_id,r.route_type,v.vehicle_id,v.vehicle_type
FROM routes AS r
JOIN routes_assignment AS ra ON r.route_id = ra.route_id
JOIN vehicle AS v ON v.vehicle_id = ra.vehicle_id; 


-- 24.	Trips with vehicle type.

Select * from trips; 
Select * from routes_assignment;
Select * from vehicle;

Select t.trip_id , v.vehicle_type,t.fare
from trips as t
JOIN routes_assignment as ra 
ON ra.route_id = t.route_id
JOIN vehicle as v 
on v.vehicle_id  = ra.vehicle_id;


-- 25.	Vehicles never used.

select * from vehicle;
INSERT INTO vehicle (vehicle_id, vehicle_type, capacity, manufacture_year)
VALUES (404, 'EV Bus', 56, '2023');

SELECT v.vehicle_id,v.vehicle_type 
FROM vehicle AS v
LEFT JOIN routes_assignment AS ra ON v.vehicle_id = ra.vehicle_id
WHERE ra.vehicle_id IS NULL;

-- 26.	Routes with revenue above average.

SELECT route_id, SUM(fare) AS total_revenue
FROM trips
GROUP BY route_id
HAVING total_revenue > (
    SELECT AVG(route_revenue)
    FROM (
        SELECT SUM(fare) AS route_revenue
        FROM trips
        GROUP BY route_id
    ) AS temp
);

-- 27.	Commuters spending more than average.
SELECT commuter_id, SUM(fare) AS total_spent
FROM trips
GROUP BY commuter_id
HAVING SUM(fare) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(fare) AS total_spent
        FROM trips
        GROUP BY commuter_id
    ) AS temp
); 


-- 28.	Most expensive maintenance vehicle.

SELECT vehicle_id, SUM(cost) AS total_maintenance_cost
FROM maintenace
GROUP BY vehicle_id
ORDER BY total_maintenance_cost DESC
LIMIT 1;


-- 29.	Stations with highest traffic.

SELECT s.station_name, COUNT(t.trip_id) AS total_trips
FROM trips t
JOIN routes r ON t.route_id = r.route_id
JOIN stations s ON r.source_station = s.station_id
GROUP BY s.station_name
ORDER BY total_trips DESC
LIMIT 1; 

-- 30.	Routes longer than city average. 
SELECT route_id, distance_km
FROM routes
WHERE distance_km > (
    SELECT AVG(distance_km)
    FROM routes
); 

/*
	31.	Fare category:
•	< 30 → Cheap
•	30–50 → Normal
•	50 → Expensive

*/

Select trip_id , fare,
CASE 
	WHEN fare >= 50 then "Expensive"
    WHEN fare > 30 and fare < 50 then "Normal"
    else "Cheap"
END AS fare_category
from trips;


/*
32.	Trip duration:
•	< 30 min → Short
•	30–60 → Medium
•	60 → Long
*/

SELECT 
trip_id,
TIMESTAMPDIFF(MINUTE, start_time, end_time) AS duration_minutes,
CASE
    WHEN TIMESTAMPDIFF(MINUTE, start_time, end_time) < 30 THEN 'Short'
    WHEN TIMESTAMPDIFF(MINUTE, start_time, end_time) BETWEEN 30 AND 60 THEN 'Medium'
    ELSE 'Long'
END AS trip_duration_category
FROM trips;

-- 33.	vw_commuter_profile
-- (name, total_trips, total_spent)
 
 CREATE VIEW vw_commuter_profile AS
SELECT 
    c.commuter_name AS name,
    COUNT(t.trip_id) AS total_trips,
    SUM(t.fare) AS total_spent
FROM commuters c
LEFT JOIN trips t 
ON c.commuter_id = t.commuter_id
GROUP BY c.commuter_id, c.commuter_name;

Select * from vw_commuter_profile;

/*
	34.	vw_route_performance
	(route_id, total_trips, revenue)

*/

CREATE VIEW vw_route_performance AS
SELECT 
    route_id,
    COUNT(trip_id) AS total_trips,
    SUM(fare) AS revenue
FROM trips
GROUP BY route_id;



-- -- 35.	Rank routes by revenue.

Select route_id,sum(fare) as total_revenue,
	RANK()OVER(
		order by sum(fare) DESC
    ) as Rank_of_routes
    from trips
    group by route_id;
    

-- 36.	Top 5 commuters by spending.

SELECT 
    c.commuter_id,
    c.commuter_name,
    SUM(t.fare) AS total_spent
FROM commuters c
JOIN trips t 
ON c.commuter_id = t.commuter_id
GROUP BY c.commuter_id, c.commuter_name
ORDER BY total_spent DESC
LIMIT 5;


-- 37.	Maintenance cost ranking.

SELECT 
    vehicle_id,
    SUM(cost) AS total_maintenance_cost,
    RANK() OVER (ORDER BY SUM(cost) DESC) AS cost_rank
FROM maintenace
GROUP BY vehicle_id; 

-- 38.	Which zone generates max revenue?
SELECT * FROM trips;
SELECT * FROM commuters;

SELECT 
    c.city_zone,
    SUM(t.fare) AS total_revenue
FROM commuters c
JOIN trips t 
ON c.commuter_id = t.commuter_id
GROUP BY c.city_zone
ORDER BY total_revenue DESC
LIMIT 1;



-- 39.	Which vehicle type is most cost efficient?
SELECT * FROM vehicles;
SELECT * FROM trips;
SELECT * FROM routes_assignment;
SELECT * FROM maintenance;

SELECT 
    v.vehicle_type,
    SUM(t.fare) AS total_revenue,
    SUM(m.cost) AS total_maintenance_cost,
    (SUM(t.fare) - SUM(m.cost)) AS profit
FROM vehicle v
JOIN routes_assignment ra ON v.vehicle_id = ra.vehicle_id
JOIN trips t ON ra.route_id = t.route_id
JOIN maintenace m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_type
ORDER BY profit DESC
LIMIT 1; 

-- 40.	Which route needs more vehicles?
SELECT r.route_id, r.route_type, COUNT(t.trip_id) AS total_trips
FROM routes r
JOIN trips t 
ON r.route_id = t.route_id
GROUP BY r.route_id, r.route_type
ORDER BY total_trips DESC
LIMIT 1; 