# Integrating Spark with Hive and BigQuery

In a real-world GCP environment, Spark often acts as the "bridge" between different storage layers. This tutorial covers how to read from BigQuery, process data in Spark, and manage it via Hive metadata or write it back to BigQuery.

## 1. Enabling Hive Support in Spark

To interact with Hive, you must enable Hive support when creating your `SparkSession`.

```python
from pyspark.sql import SparkSession

# Initialize Spark with Hive support
spark = SparkSession.builder \
    .appName("Spark External Integration") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .enableHiveSupport() \
    .getOrCreate()
```

## 2. Reading from BigQuery (The GCS Bridge)

The Spark-BigQuery connector requires a temporary GCS bucket to move data.

```python
# 1. Configure the mandatory temporary bucket
spark.conf.set("temporaryGcsBucket", "your-temp-bucket")

# 2. Read from a BigQuery Public Dataset
# Path format: project.dataset.table
bq_df = spark.read.format("bigquery") \
    .option("table", "bigquery-public-data.chicago_taxi_trips.taxi_trips") \
    .load() \
    .select("trip_seconds", "trip_miles", "fare", "tips", "tolls", "extras", "trip_total") \
    .filter("trip_total > 0 AND trip_seconds > 0 AND trip_miles > 0")

bq_df.show(5)
```

## 3. Managing Data with Apache Hive

Once you have a DataFrame, you can save it as a permanent Hive table. This allows other tools (like the Hive CLI or Presto) to see the data without knowing the underlying file paths.

```python
# Save as a permanent Hive table
bq_df.write.mode("overwrite").saveAsTable("hive_taxi_data")

# Verify you can query it via Spark SQL
spark.sql("SELECT count(*) FROM hive_taxi_data").show()
```

## 4. Writing Results back to BigQuery

After processing (e.g., after an aggregation or ML prediction), you might want to write the results back to BigQuery for a dashboard.

```python
# Simple aggregation example
summary_stats = bq_df.groupBy("trip_seconds").avg("fare")

# Write back to BigQuery (Replace with your project and dataset)
summary_stats.write.format("bigquery") \
    .option("table", "your-project-id.your_dataset.taxi_summary") \
    .mode("overwrite") \
    .save()
```

## 5. Why use this Hybrid Architecture?

- **Hive**: Provides a stable schema and metadata layer. If you drop the table, you only drop the "pointer" (if external) or the data (if managed), but the metadata keeps things organized.
- **BigQuery**: Best for massive-scale analytics and BI tools (Looker, Data Studio).
- **Spark**: The muscle that connects them, allowing for complex logic (Python/Scala) that SQL alone can't handle efficiently.

## 6. Verification in the CLI

You can check your progress outside of the notebook:

```bash
# Check Hive
hive -e "SHOW TABLES;"

# Check BigQuery results
bq ls your_dataset
```
