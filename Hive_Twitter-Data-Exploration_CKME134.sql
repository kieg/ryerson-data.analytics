-- EXPLORING TWITTER DATA WITH HIVE


-- I am working with twitter data contained in the file "full_text.txt"
-- which has been uploaded to HDFS

-- First, we will create an empty table, then load the contents of full_text.txt from HDFS

create table full_text (line string);
load data inpath '/user/lab/full_text.txt' overwrite into table full_text;



-- 1. Find the hour of the day that generated the most number of tweets on March 6, 2010

select to_date(ts), hour(ts), count(*) as cnt
from twitter.full_text_ts
where to_date(ts) = ‘2010-03-06’
group by to_date(ts), hour(ts)
order by cnt desc
limit 3;

-- 2. Find the most mobile tweeter 
-- The user who tweeted from the most distinct locations. 

select id, count(*) as cnt
from(select distinct id, lat, lon
from twitter.full_text_ts) as mobileuser
group by id 
order by cnt desc
limit 3;

-- 3. Find the 3 most popular topics (hashtags #)

create table twitter.userwords as 
select word from 
(select explode(split(tweet, ‘[\s+ +\t+]’)) as word
from twitter.full_text_ts) w;

select hashtag, count(1) as count from
(select regexp_extract(lower(word), ‘[#](\\w+)’, 0) as hashtag from
twitter.userwords) wo
where hashtag != “”
group by hashtag
order by count desc
limit 3;

-- 4. Find the most frequently mentioned twitter handle @

select handle, count(1) as count from 
(select regexp_extract(lower(word),
‘(.*)@user_(\\S{8})([:| ])(.*)’,2) as handle
from twitter.userwords) wo
where handle != “”
group by handle
order by count desc
limit 3;


