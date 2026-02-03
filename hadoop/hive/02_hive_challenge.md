# Hive Practice Challenge: Austin Bike Share Analysis

In this challenge, you will use Apache Hive to analyze urban mobility patterns using the **Austin Bike Share** public dataset.

## 1. Setup and Data Extraction

Extract the `bikeshare_trips` dataset from BigQuery to your GCS bucket.

```bash
# Variables
BUCKET_NAME="your-unique-bucket-name"

# Extract data
bq extract --destination_format=CSV \
    bigquery-public-data:austin_bikeshare.bikeshare_trips \
    gs://$BUCKET_NAME/austin_bikeshare/trips.csv
```

## 2. Your Mission

Complete the following tasks using Hive:

### Task 1: Staging Table
Create an **External Table** named `trips_staging` that points to the CSV file in GCS. Be mindful of the schema (trip_id, subscriber_type, bike_id, start_time, duration_minutes, etc.).

### Task 2: Partitioned Table
Create a **Managed Table** named `trips_by_type`, partitioned by `subscriber_type`. Use the **ORC** format for optimization.
*Hint: You'll need to set dynamic partition properties.*

### Task 3: Analytical Queries
Write HQL queries to answer the following:
1.  **Popular Stations**: What are the top 5 `start_station_name` with the highest number of trips?
2.  **Usage Patterns**: Calculate the average `duration_minutes` for each `subscriber_type`.
3.  **Peak Years**: How many trips were taken per year? (Extract the year from the `start_time` string/timestamp).
4.  **Long Rides**: Find all trips with a duration greater than 2 hours (120 minutes) for 'Walk Up' subscribers.

## 3. Bonus Challenge
Create a **Bucketed Table** clustered by `bike_id` into 8 buckets. Compare the execution time of a query filtered by `bike_id` between the staging table and the bucketed table.
