# Spotify Advanced SQL Project and Query Optimization
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.


---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
select * from spotify
where stream > 1000000000;
```
   
2. List all albums along with their respective artists.
```sql

select  distinct(album), artist
from spotify;
```

3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql

select SUM(comments) 
from spotify
	where licensed = 'true';

```
4. Find all tracks that belong to the album type `single`.
```sql

select * 
from spotify
	where album_type = 'single';


```
5. Count the total number of tracks by each artist.
```sql

select artist, COUNT(*)
from spotify
	GROUP BY artist
	ORDER BY COUNT(*) DESC;


```

### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
select album, avg(danceability) as Average_D
from spotify
	GROUP BY album
	ORDER BY Average_D DESC;



```


2. Find the top 5 tracks with the highest energy values.
```sql
select track, max(energy) as MAX_Avg	
from spotify
	GROUP BY track
	ORDER BY MAX_Avg DESC
	LIMIT 5



```


3. For each album, calculate the total views of all associated tracks.
```sql

select album, track, SUM(views) as sum_views
from spotify
	GROUP BY album, track
	ORDER BY sum_views DESC


```


4. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql


select * from
(select track, 
		--most_played_on, 
		COALESCE(SUM(CASE 
		WHEN most_played_on = 'Spotify' then stream
		END),0) as stream_spfy,
		COALESCE(SUM(CASE 
		WHEN most_played_on = 'Youtube' then stream
		END),0) as stream_yt
from spotify
GROUP BY track
) as sub_query1
where stream_spfy > stream_yt
	and stream_yt != 0

```

### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql

select * from
	(select 
		artist, 
		track, 
		SUM(views) as total_views,
		DENSE_RANK() Over(Partition by artist Order by SUM(views) DESC) as RNK
	from spotify
	GROUP BY 1,2
	ORDER BY 1,3 DESC)
where RNK = 1 or RNK = 2 or RNK = 3

-----OR----
WITH CTE_ranking_artist as
(select 
		artist, 
		track, 
		SUM(views) as total_views,
		DENSE_RANK() Over(Partition by artist Order by SUM(views) DESC) as RNK
	from spotify
	GROUP BY 1,2
	ORDER BY 1,3 DESC)

Select * from CTE_ranking_artist
where RNK <=3


```

2. Write a query to find tracks where the liveness score is above the average.
```sql

select track, liveness
from spotify
	where liveness > (select avg(liveness) from spotify)


```

3. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
```sql
With CTE_Energy as(
	select album, 
			MAX(energy) as en_max,
			MIN(energy) as en_min
	from spotify
	group by 1
)

select *, (en_max - en_min) as Energy_Difference
from CTE_Energy
order by 4 desc

```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.

```sql

select  * from
(select	track, 
		energy, 
		liveness, 
		(energy/liveness) as ratio
from spotify)
where ratio > 1.2
order by ratio desc


```

5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

```sql

select track, 
		most_played_on,
		views,
		likes,
		SUM(likes) Over(Order by views desc) as cumu_likes
from spotify


```

Here’s an updated section for **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task performed. 
---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)

---

## Next Steps
- **Visualize the Data**: Use a data visualization tool like **Tableau** or **Power BI** to create dashboards based on the query results.
- **Expand Dataset**: Add more rows to the dataset for broader analysis and scalability testing.
- **Advanced Querying**: Dive deeper into query optimization and explore the performance of SQL queries on larger datasets.

---

## Contributing
If you would like to contribute to this project, feel free to fork the repository, submit pull requests, or raise issues.

---

## License
This project is licensed under the MIT License.
