# BigQuery: Public Datasets and SQL Essentials

One of BigQuery's most powerful features is the access to **Public Datasets**, but you will primarily use it to analyze your own data in datasets like `dsongcp`.

> **Prerequisite**: Ensure you have created the `dsongcp` dataset and loaded `flights_raw` in [Tutorial 01: Ingestion](./01_bigquery_ingestion_tutorial.md).

---

## 1. Querying Your Own Data (`dsongcp`)

Now that you've ingested data, let's run a query on your `dsongcp` dataset to see the raw flight information:

```sql
SELECT 
  Reporting_Airline, 
  Origin, 
  Dest, 
  DepDelay 
FROM 
  `dsongcp.flights_raw`
WHERE DepDelay > 0
LIMIT 10;
```

---

## 2. Querying Public Datasets

Google hosts a variety of public datasets (e.g., NYC Taxi, GitHub, Census). You reference them using the project ID `bigquery-public-data`.

### Example: NYC CitiBike Trips
Try running this query to find trip durations in minutes:

```sql
SELECT
  tripduration/60 as duration_trip_minutes
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration IS NOT NULL
LIMIT 200;
```

### Basic Aggregations
Count the total number of trips and see the distribution by gender:

```sql
-- Total count of trips
SELECT COUNT(*) FROM `bigquery-public-data.new_york_citibike.citibike_trips`;

-- Trips by gender
SELECT 
  gender, 
  COUNT(*) as total_trips
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY gender;
```

---

## 3. SQL Syntax Tricks

### The `EXCEPT` Clause
Instead of listing every column, you can select all *except* a few.

```sql
SELECT
  * EXCEPT(stoptime, end_station_id)
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration IS NOT NULL
LIMIT 200;
```

### Common Table Expressions (CTEs)
Use the `WITH` clause to make your queries more readable. This example filters for male riders using a CTE:

```sql
WITH all_data AS (
  SELECT
    * EXCEPT(stoptime, end_station_id)
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE tripduration IS NOT NULL
  LIMIT 200
)
SELECT * FROM all_data WHERE gender = 'male';
```

---

## 4. String and Date Functions

### Date and Time Extraction
Extract parts of a date (Year, Month, Day) using `EXTRACT`. Let's use the San Francisco Bikeshare dataset:

```sql
SELECT 
  installation_date,
  EXTRACT(YEAR FROM installation_date) as year
FROM `bigquery-public-data.san_francisco.bikeshare_stations`
LIMIT 10;
```

### String Manipulation
Using `REPLACE` and `SPLIT` to clean and tokenize station names:

```sql
-- Replace ' at ' with a space
SELECT REPLACE(name, ' at ', ' ')
FROM `bigquery-public-data.san_francisco.bikeshare_stations`
LIMIT 5;

-- Split the name into an array of words
SELECT SPLIT(REPLACE(name, ' at ', ' '), ' ')
FROM `bigquery-public-data.san_francisco.bikeshare_stations`
LIMIT 5;
```

---

## 5. Partitioning and Clustering

To optimize costs and performance on large tables, you should use partitioning (dividing data by a column like `date`) and clustering (sorting data within partitions).

### Create a Partitioned Table
This command creates a new table partitioned by month using the Chicago Crime public dataset:

```bash
bq query \
 --use_legacy_sql=false \
 --destination_table partition_ds.crime_partition \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 'SELECT * FROM `bigquery-public-data.chicago_crime.crime`'
```

### Querying Partitioned Data
When you query a partitioned table with a filter on the partitioning column, BigQuery only reads the relevant partitions (saving money!):

```sql
SELECT * FROM `partition_ds.crime_partition` 
WHERE date = '2006-02-14 04:15:00 UTC';

-- Comparing with the original public dataset
SELECT * FROM `bigquery-public-data.chicago_crime.crime` 
WHERE date = '2006-02-14 04:15:00 UTC'
AND primary_type = 'INTIMIDATION';
```

### Inspecting Partitions
You can query the `INFORMATION_SCHEMA` to see metadata about your partitions:

```sql
SELECT *
FROM `partition_ds.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'crime_partition';
```

### Create a Clustered and Partitioned Table
Clustering further sorts data within partitions for even faster filtering on specific columns:

```bash
bq query \
 --use_legacy_sql=false \
 --clustering_fields primary_type \
 --destination_table partition_ds.crime_partition_cluster \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 'SELECT * FROM `bigquery-public-data.chicago_crime.crime`'
```
