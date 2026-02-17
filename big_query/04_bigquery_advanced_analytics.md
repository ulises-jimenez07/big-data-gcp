# BigQuery: Advanced Analytics & Window Functions

In this tutorial, we transition from basic SQL to **Advanced Analytics**, using BigQuery's public datasets to explore Window Functions, Geospatial Analysis, and complex data structures.

## 1. Creating Managed Views
A View is a virtual table defined by a SQL query. It allows you to abstract complex logic (like unit conversions or data cleaning) for other users.

```sql
-- Create a view to clean NYC Citibike data
CREATE OR REPLACE VIEW `your-project.your_dataset.citibike_analytics` AS
SELECT
  bikeid,
  tripduration / 60 AS duration_minutes,
  CAST(starttime AS DATETIME) AS start_time,
  start_station_name,
  end_station_name,
  usertype,
  IF(gender = 'male', 1, 0) AS is_male,
  EXTRACT(YEAR FROM starttime) - birth_year AS approximate_age
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration IS NOT NULL AND birth_year IS NOT NULL;
```

---

## 2. Window Functions (Analytical SQL)
Window functions allow you to perform calculations across a set of table rows that are somehow related to the current row.

### Ranking and Deduplication
Find the top 3 longest trips per station using `RANK()`:

```sql
SELECT
  start_station_name,
  tripduration,
  RANK() OVER(PARTITION BY start_station_id ORDER BY tripduration DESC) as trip_rank
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
QUALIFY trip_rank <= 3
LIMIT 10;
```

### Cumulative Sums (Running Totals)
Calculate the running total of trip durations per day:

```sql
SELECT
  DATE(starttime) as trip_date,
  SUM(tripduration) as daily_duration,
  SUM(SUM(tripduration)) OVER(ORDER BY DATE(starttime)) as cumulative_duration
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY trip_date
LIMIT 10;
```

---

## 3. Geospatial Analytics (GIS)
BigQuery has native support for geographic data types. You can calculate distances, areas, and intersections between points and polygons.

### Calculating Distance Between Stations
Using `ST_DISTANCE` and `ST_GEOGPOINT` to find the Euclidean distance of a trip:

```sql
SELECT
  bikeid,
  ST_DISTANCE(
    ST_GEOGPOINT(start_station_longitude, start_station_latitude),
    ST_GEOGPOINT(end_station_longitude, end_station_latitude)
  ) AS distance_meters
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE start_station_longitude IS NOT NULL AND end_station_longitude IS NOT NULL
LIMIT 10;
```

---

## 4. Advanced ML Performance Metrics
You can use SQL to evaluate the effectiveness of an "if-then" rule or a machine learning model by calculating a **Contingency Table**.

### Accuracy, Precision, and FPR
Let's see if a simple rule—*"If a taxi trip is longer than 5km, the tip will be > $5"*—is actually true.

```sql
WITH contingency_table AS (
  SELECT
    ST_DISTANCE(ST_GEOGPOINT(pickup_longitude, pickup_latitude), 
                ST_GEOGPOINT(dropoff_longitude, dropoff_latitude)) / 1000 AS dist_km,
    tips > 5 AS actual_high_tip,
    (ST_DISTANCE(ST_GEOGPOINT(pickup_longitude, pickup_latitude), 
                 ST_GEOGPOINT(dropoff_longitude, dropoff_latitude)) / 1000) > 5 AS predicted_high_tip
  FROM
    `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE pickup_longitude IS NOT NULL AND dropoff_longitude IS NOT NULL
  LIMIT 100000
),
metrics AS (
  SELECT
    COUNTIF(predicted_high_tip AND actual_high_tip) AS true_positives,
    COUNTIF(predicted_high_tip AND NOT actual_high_tip) AS false_positives,
    COUNTIF(NOT predicted_high_tip AND actual_high_tip) AS false_negatives,
    COUNTIF(NOT predicted_high_tip AND NOT actual_high_tip) AS true_negatives,
    COUNT(*) AS total
  FROM contingency_table
)
SELECT
  ROUND((true_positives + true_negatives) / total, 2) AS accuracy,
  ROUND(false_positives / (true_positives + false_positives), 2) AS false_discovery_rate,
  ROUND(false_negatives / (false_negatives + true_negatives), 2) AS false_omission_rate
FROM metrics;
```

---

## 5. Working with Arrays & Structs
BigQuery supports nested and repeated data, common in JSON logs and event data.

### Pivot Data with `UNNEST`
Turn a pipe-separated string (like StackOverflow tags) into individual rows for analysis:

```sql
SELECT
  tag,
  COUNT(*) as frequency
FROM
  `bigquery-public-data.stackoverflow.posts_questions`,
  UNNEST(SPLIT(tags, '|')) as tag
GROUP BY tag
ORDER BY frequency DESC
LIMIT 10;
```

### Complex Aggregations with `ARRAY_AGG` and `STRUCT`
Capture the "latest" trip info for each station in a single row:

```sql
SELECT
  start_station_name,
  ARRAY_AGG(
    STRUCT(tripduration, usertype, starttime)
    ORDER BY starttime DESC LIMIT 1
  )[OFFSET(0)] as latest_trip
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY start_station_name
LIMIT 10;
```
