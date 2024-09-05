-- Movie recommendation data as SQL project 1
-- ** Gathering data ** Create tables and IMPORT data into them

-- create table movie and import the data from corresponding csv file
drop table if exists Movie;
Create TABLE Movie(
		movieId  int primary key,
		title	  varchar(500),
		genres	  varchar(300)
);
select * from movie limit 10;

-- create table ratings and import the data from corresponding csv file
drop table if exists ratings;
create table ratings(
		userId  int,
		movieId int,
		rating   float,
		timestamp int
);

-- create table ratings and import the data from corresponding csv file
drop table if exists tags;
create table tags(
		userId    int,
		movieId	  int,
		tag       varchar(120),
		timestamp int
);

-- data Cleaning
-- drop the column timestamp from ratings and Check data.
alter table ratings drop timestamp; 
select *  from ratings limit 10;

-- drop the column timestamp from ratings and Check data.
alter table tags drop timestamp;
select * from tags limit 10;

-- Executing Queries 
/* 	1. WSQ to find the total number of users from ratings.csv
    2. WSQ to find which movie received maximum number of user ratings.
	3. Show all the tags submitted by the users for the movie "Matrix,The (1999)"
	4. What is the average user rating for movie named "Terminator 2:Judgement Day(1991)"
	5. How does the data distribution of user rating for "Fight Club (1999)"
	6. which movie is most popular based on average user ratings
	7. Top 5 popular movies based on number of user ratings
	8. which sci Fi movie is '3rd most popular' based on number of user ratings
*/
-- 1. WSQ to find the total number of users from ratings.csv
select count(distinct userId) as total_users from ratings;


select *  from ratings limit 10;
-- 2. WSQ to find which movie received maximum number of user ratings.
Select title from Movie
		where movieId = (select movieId from 
						(select movieId,count(rating) as Total_ratings
						 from ratings 
						 group by movieId
			  			 order by total_ratings desc limit 1)
						);

select * from tags limit 10;
select * from Movie limit 10;

-- 3. Show all the tags submitted by the users for the movie "Matrix,The (1999)"
SELECT tag as tags from tags 
	where movieid=(select movieId from Movie where title = 'Matrix, The (1999)');

-- 4.What is the average user rating for movie named "Terminator 2:Judgement Day(1991)"
select avg(rating) as average
		from ratings 
		where movieId = (select movieId from Movie where title = 'Terminator 2: Judgment Day (1991)')
		group by movieId;

-- 5.How does the data distribution of user rating for "Fight Club (1999)"
-- mean
Select avg(rating) as mean
	from ratings
	where movieId = (select movieId from Movie where title = 'Fight Club (1999)')
	group by movieid;

-- median
-- Identify median from executing below query and observe the total number of rows.
-- total rows	EVEN:	if total number of Rows are EVEN then divide data into two halfs with help of last row index.
--        					median = (value in last row of 1st half + value in first row of 2nd half)/2
-- total rows   ODD:	if total number of Rows are ODD then divide data into two halfs with help of last row index.
--        					median  = (value in next row after 1st half)
/*
---------------------------------------------------------------------------------------------------------
Select rating 
	from ratings
	where movieId = (select movieId from Movie where title = 'Fight Club (1999)')order by rating asc;
-------------------------------------------------------------------------------------------------------------
Total rows 218 , half= 109 , 109+1 is offset because of even number of rows */
select rating from(Select rating
	from ratings
	where movieId = (select movieId from Movie where title = 'Fight Club (1999)')order by rating asc)limit 1 offset 110;
-- in this  median  110th row value =4.5

-- mode
Select rating,count(rating) as  mode_of_data
	from ratings
	where movieId = (select movieId from Movie where title = 'Fight Club (1999)')
	group by distinct rating
	order by mode_of_data desc 
	limit 1;
-- The answer is mean = 4.27, median = 4.5, mode = 5, -vely skewed i.e, right skewed 

/* 
"Note: perform these mandatory operations"
	1. Group user ratings based on movieid and apply aggregation operations like count and mean on ratings
	2. Apply inner join on dataframe created from movies.csv and the grouped data df from step 1.
	3. Filter only those movies which have more than 50 user ratings
*/

/* 1.Group user ratings based on movieid and apply aggregation operations like count and mean on ratings
	3. Filter only those movies which have more than 50 user ratings    */
select movieid,avg_rating,no_of_R from(select movieId,avg(rating) as avg_rating,count(rating) as no_of_R
	from ratings group by movieId 
	order by no_of_R desc) where no_of_r >50;
-- creating table and inserting above data into it.
--------------------------------------------------------------------------------------------
create table grouped_data(
		movieid		 int primary key,
		avg_rating   float,
		no_of_r		 int
);

INSERT INTO grouped_data(movieid, avg_rating,no_of_r)
select movieid,avg_rating,no_of_R from(select movieId,avg(rating) as avg_rating,count(rating) as no_of_R
	from ratings group by movieId 
	order by no_of_R desc) where no_of_r >50;
	
select * from grouped_data;
-------------------------------------------------------------------------------------------------------
-- 2.Apply inner join on dataframe created from movies.csv and the grouped data df from step 1.
select grouped_data.movieid,
	   Movie.title,
	   grouped_data.avg_rating,
	   grouped_data.no_of_r,Movie.genres from grouped_data inner join Movie on grouped_data.movieid = Movie.movieId;
	   
-- Let's save this into a table for futher operations
drop table if exists joint_data;
create table joint_data(
		movieid int primary key,
		title   varchar(500),
		avg_rating float,
		no_of_r   int,
		genres   varchar(300)
);

insert into joint_data(movieid,
		title,
		avg_rating,
		no_of_r,genres)
select grouped_data.movieid,
	   Movie.title,
	   grouped_data.avg_rating,
	   grouped_data.no_of_r,
	   Movie.genres from grouped_data inner join Movie on grouped_data.movieid = Movie.movieId;
--test the results	   
select * from joint_data limit 100;
-------------------------------------------------------------------------------------------------------
-- 6.which movie is most popular based on average user ratings
select title from joint_data order by avg_rating desc limit 1;

-- 7.Top 5 popular movies based on number of user ratings
select title from joint_data order by No_of_r desc limit 5;

-- 8.which sci Fi movie is '3rd most popular' based on number of user ratings
select title 
		from (select * from joint_data 
					where genres LIKE '%Sci-Fi%')order by no_of_r desc limit 1 offset 2;


	