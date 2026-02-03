# BigQuery: Views and Advanced Analytics

This tutorial covers the creation of **Views** for data abstraction and using advanced SQL to calculate performance metrics directly within BigQuery.

> **Prerequisite**: Ensure you have completed [Tutorial 01: Ingestion](./01_bigquery_ingestion_tutorial.md) and created the `dsongcp` dataset and `flights_raw` table.

## 1. Creating Views

A View is a virtual table defined by a SQL query. It doesn't store data itself but provides a simplified interface to complex queries.

```sql
CREATE OR REPLACE VIEW dsongcp.flights AS
SELECT
  FlightDate AS FL_DATE,
  Reporting_Airline AS UNIQUE_CARRIER,
  CAST(DepDelay AS FLOAT64) AS DEP_DELAY,
  CAST(ArrDelay AS FLOAT64) AS ARR_DELAY,
  DISTANCE
FROM dsongcp.flights_raw;
```

---

## 2. Joins and Structs

BigQuery supports complex data types like `STRUCT` and `ARRAY`.

### Example: Average Delays with Location
Using `ARRAY_AGG` and `STRUCT` to keep the latest delay info for each airport:

```sql
SELECT 
    AIRPORT,
    CONCAT(LATITUDE, ',', LONGITUDE) AS LOCATION,
    ARRAY_AGG(
        STRUCT(AVG_ARR_DELAY, AVG_DEP_DELAY, NUM_FLIGHTS, END_TIME)
        ORDER BY END_TIME DESC LIMIT 1) AS latest_info
FROM ds_flights.airport_delays
GROUP BY AIRPORT, LONGITUDE, LATITUDE;
```

---

## 3. Calculating Metrics in SQL

You can calculate machine learning metrics like **Accuracy**, **False Positive Rate (FPR)**, and **False Negative Rate (FNR)** without leaving SQL.

### Step 1: Using `UNNEST` to Test Thresholds
This query simulates testing different "delay thresholds" (5, 10, 15, etc.) to see which one predicts arrival delays best.

```sql
SELECT 
    THRESH,
    COUNTIF(dep_delay < THRESH AND arr_delay < 15) AS true_positives,
    COUNTIF(dep_delay < THRESH AND arr_delay >= 15) AS false_positives,
    COUNTIF(dep_delay >= THRESH AND arr_delay < 15) AS false_negatives,
    COUNTIF(dep_delay >= THRESH AND arr_delay >= 15) AS true_negatives,
    COUNT(*) AS total
FROM dsongcp.flights, UNNEST([5, 10, 15, 20]) AS THRESH
WHERE arr_delay IS NOT NULL AND dep_delay IS NOT NULL
GROUP BY THRESH;
```

### Step 2: Final Accuracy Calculation
Wrap the logic in a CTE to compute the final percentages:

```sql
WITH contingency_table AS (
  -- (Query from above goes here)
)
SELECT
   THRESH,
   ROUND((true_positives + true_negatives)/total, 2) AS accuracy,
   ROUND(false_positives/(true_positives + false_positives), 2) AS fpr,
   ROUND(false_negatives/(false_negatives + true_negatives), 2) AS fnr
FROM contingency_table 
ORDER BY accuracy DESC;
```

---

## 4. Case Logic
Use `CASE` to create labels for your data:

```sql
SELECT
  ARR_DELAY,
  CASE 
    WHEN ARR_DELAY < 15 THEN "ON TIME"
    ELSE "LATE"
  END AS status
FROM dsongcp.flights
LIMIT 5;
```
