# BigQuery: Public Datasets and SQL Essentials

One of BigQuery's most powerful features is the access to **Public Datasets**, but you will primarily use it to analyze your own data in datasets like `dsongcp`.

> **Prerequisite**: Ensure you have created the `dsongcp` dataset and loaded `flights_raw` in [Tutorial 01: Ingestion](./01_bigquery_ingestion_tutorial.md).

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
  tripduration / 60 as duration_trip_minutes
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration IS NOT NULL
LIMIT 10;
```

---

## 3. SQL Syntax Tricks

### The `EXCEPT` Clause
Instead of listing every column, you can select all *except* a few. Let's try this on your flights data:

```sql
SELECT
  * EXCEPT(Year, Quarter, Month)
FROM
  `dsongcp.flights_raw`
LIMIT 10;
```

### Common Table Expressions (CTEs)
Use the `WITH` clause to make your queries more readable. Here we combine your flights data with a filter:

```sql
WITH delayed_flights AS (
  SELECT
    Origin, Dest, DepDelay
  FROM
    `dsongcp.flights_raw`
  WHERE DepDelay > 15
)
SELECT 
  Origin, 
  COUNT(*) as num_delayed 
FROM delayed_flights 
GROUP BY Origin 
ORDER BY num_delayed DESC;
```

---

## 4. String and Date Functions

### Date and Time Extraction
Extract parts of a date (Year, Month, Day) from your `flights_raw` table using `EXTRACT`:

```sql
SELECT 
  FlightDate,
  EXTRACT(YEAR FROM FlightDate) as flight_year,
  EXTRACT(MONTH FROM FlightDate) as flight_month
FROM `dsongcp.flights_raw`
LIMIT 5;
```

### String Manipulation (Public Data Example)
Using `REPLACE` and `SPLIT` on the San Francisco Bikeshare dataset:

```sql
-- Replace 'at' with a space
SELECT REPLACE(name, ' at ', ' ')
FROM `bigquery-public-data.san_francisco.bikeshare_stations`
LIMIT 5;
```

