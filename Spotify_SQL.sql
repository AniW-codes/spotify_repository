
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

--EDA--
select * from spotify
where (duration_min) = 0

select min(duration_min) from spotify

DELETE from spotify
 WHERE
	(DURATION_MIN) = 0

Select COUNT(*)
from spotify

select distinct(channel)
from spotify

select * from spotify
where title = '0'

select min(views) from spotify


----
--Data analysis (easy)
----


--Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify
where stream > 1000000000;

--List all albums along with their respective artists.

select  distinct(album), artist
from spotify;


--Get the total number of comments for tracks where licensed = TRUE.

select SUM(comments) 
from spotify
	where licensed = 'true';

--Find all tracks that belong to the album type single.

select * 
from spotify
	where album_type = 'single';
	
--Count the total number of tracks by each artist.
select artist, COUNT(*)
from spotify
	GROUP BY artist
	ORDER BY COUNT(*) DESC;

----
--Data analysis (medium)
----

--Calculate the average danceability of tracks in each album.

select album, avg(danceability) as Average_D
from spotify
	GROUP BY album
	ORDER BY Average_D DESC;


--Find the top 5 tracks with the highest energy values.
select track, max(energy) as MAX_Avg	
from spotify
	GROUP BY track
	ORDER BY MAX_Avg DESC
	LIMIT 5

--For each album, calculate the total views of all associated tracks.

select album, track, SUM(views) as sum_views
from spotify
	GROUP BY album, track
	ORDER BY sum_views DESC

--Retrieve the track names that have been streamed on Spotify more than YouTube.


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

----
--Data analysis (advanced)
----

--Find the top 3 most-viewed tracks for each artist using window functions.

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



--Write a query to find tracks where liveness score is above the average score

select track, liveness
from spotify
	where liveness > (select avg(liveness) from spotify)

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

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


--Find tracks where the energy-to-liveness ratio is greater than 1.2.

select  * from
(select	track, 
		energy, 
		liveness, 
		(energy/liveness) as ratio
from spotify)
where ratio > 1.2
order by ratio desc

--Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select *  from spotify

select track, 
		most_played_on,
		views,
		likes,
		SUM(likes) Over(Order by views desc) as cumu_likes
from spotify

