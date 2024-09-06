# Movie_dataset_sql_beginner_project
## Project Overview

![Screenshot 2024-09-05 163425](https://github.com/user-attachments/assets/329f4da5-07fd-4a51-8de1-dfb9abdd5df6)


**Project Title**: Movie recommendation tool 
	**Level**: Beginner  
**Database**: `Movies.csv`,`ratings.csv`,`tags.csv`
	**Tool used**: Postgre_SQL

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a Movie recommendation database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a Movie recommendation database**: Create and populate a Movie recommendation database with the provided data in csv files.
2. **Data Cleaning**: Identify and remove any records with missing or null values,unnecessary columns.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `movie`,`ratings`,`tags`.
- **Table Creation**: A tables named `movie`,`ratings`,`tags` are created to store the data from csv files. The table structure includes columns as follows
- Table `movie` : movieId, title, genres
- Table `ratings` : userId, movieId, rating, timestamp
- Table `tags` :    userId, movieId, tag, timestamp
```sql
CREATE DATABASE movie_recommendation;

drop table if exists Movie;
Create TABLE Movie(
		movieId  int primary key,
		title	  varchar(500),
		genres	  varchar(300)
);
select * from movie limit 10;

drop table if exists ratings;
create table ratings(
		userId  int,
		movieId int,
		rating   float,
		timestamp int
);

drop table if exists tags;
create table tags(
		userId    int,
		movieId	  int,
		tag       varchar(120),
		timestamp int
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **User Count**: Find out how many unique users are in the dataset.
- **MovieId Count**: Identify all unique product Movieid in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Delete unnecessary columns** :Check whether all columns are necessary, we have timestamp column not needed as of now, for this project delete it. 

```sql
--Data cleaning
-- drop the column timestamp from ratings and Check data.
alter table ratings drop timestamp; 
select *  from ratings limit 10;

-- drop the column timestamp from tags and Check data.
alter table tags drop timestamp;
select * from tags limit 10;
```
### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:
 	1. WSQ to find the total number of users from ratings.csv?
  2. WSQ to find which movie received maximum number of user ratings?
	3. Show all the tags submitted by the users for the movie "Matrix,The (1999)"?
	4. What is the average user rating for movie named "Terminator 2:Judgement Day(1991)"?
	5. How does the data distribution of user rating for "Fight Club (1999)"?
	6. which movie is most popular based on average user ratings?
	7. Top 5 popular movies based on number of user ratings?
	8. which sci Fi movie is '3rd most popular' based on number of user ratings?

1. **Write a SQL queryto find the total number of users from ratings.csv**:
```sql
select count(distinct userId) as total_users from ratings;
```

2. **Write a SQL query to find which movie received maximum number of user ratings.**:
```sql
Select title from Movie
		where movieId = (select movieId from 
						(select movieId,count(rating) as Total_ratings
						 from ratings 
						 group by movieId
			  			 order by total_ratings desc limit 1)
						);
```

3. **Write a SQL query to  Show all the tags submitted by the users for the movie "Matrix,The (1999)".**:
```sql
SELECT tag as tags from tags 
	where movieid=(select movieId from Movie where title = 'Matrix, The (1999)');
```

4. **Write a SQL query to find, what is the average user rating for movie named "Terminator 2:Judgement Day(1991)".**:
```sql
select avg(rating) as average
		from ratings 
		where movieId = (select movieId from Movie where title = 'Terminator 2: Judgment Day (1991)')
		group by movieId;
```

5. **Write a SQL query to find How does the data distribution of user rating for "Fight Club (1999)".**:
```sql
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
```
**Note: perform these mandatory operations"
	1. Group user ratings based on movieid and apply aggregation operations like count and mean on ratings
	2. Apply inner join on dataframe created from movies.csv and the grouped data df from step 1.
	3. Filter only those movies which have more than 50 user ratings**

-- Create two more tables grouped_data which results from step 1, joint_data which results from innner join.
```sql
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
```
6. **Write a SQL query to find which movie is most popular based on average user ratings.**:
```sql
select title from joint_data order by avg_rating desc limit 1;
```

7. **Write a SQL query to find Top 5 popular movies based on number of user ratings**:
```sql
select title from joint_data order by No_of_r desc limit 5;
```

8. **Write a SQL query to find  which 'Sci-Fi' movie is '3rd most popular' based on number of user ratings**:
```sql
select title 
		from (select * from joint_data 
					where genres LIKE '%Sci-Fi%')order by no_of_r desc limit 1 offset 2;
```

## Findings

- **User Demographics**: The dataset includes 610 users from various age groups, watched different genre movies.
- **Popular Movies**: There are 9742 movies in the dataset,among them the 436 Movies received 50+ user ratings. 
- **Ratings**: We have good number of repeated repeated customers,So we have to display new and Good rated movies to keep engaging our users.
- **Customer Insights**: Every user likes specific genres in movies and the tags were given by users to movies are helpful to us improve movie search engine.

## Reports

- **Grouped data**: A detailed report summarizing avg rating, number of ratings recieved by each movie.
- **Joint_data**: The movieid, movie title, genre, avg_rating, number of ratings >50 which gives some good movies to recommend for users
- **User tags**: The tags given for a movie will be displayed by entering movie_name or movie_Id

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding viewership patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `movie_data` folder to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `Movie recommendation.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Erukonda Saikiran

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on GitHub and Linkedin

- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/erukonda-saikiran-4379911a3)

Thank you for your visit, and I look forward to connecting with you!
