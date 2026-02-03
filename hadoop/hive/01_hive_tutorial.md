# Apache Hive on GCP Dataproc: A Comprehensive Tutorial

This guide covers how to use Apache Hive on a Google Cloud Dataproc cluster, from setting up public data to advanced table configurations like partitioning and bucketing.

## 1. Prerequisites

*   A running **Dataproc Cluster** (refer to the [Hadoop Tutorial](../hadoop/01_dataproc_hdfs_tutorial.md) for setup instructions).
*   A Google Cloud Storage (GCS) bucket.
*   The `bq` and `gcloud` CLI tools initialized.

---

## 2. Preparing Public Data

In this tutorial, we will use the **Chicago Crime** dataset from BigQuery Public Data.

### Step 2.1: Extract Data from BigQuery to GCS

First, we export the public dataset to your GCS bucket in CSV format.

```bash
# Set your variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-hadoop"

# (Optional) Create the bucket if you didn't do it in the MapReduce tutorial
gsutil mb -l us-central1 gs://$BUCKET_NAME

# Extract BigQuery public data to GCS (using * for sharding large data)
bq extract --destination_format=CSV \
    bigquery-public-data:chicago_crime.crime \
    gs://$BUCKET_NAME/chicago_crime/crime_data_*.csv
```

### Step 2.2: Move Data to HDFS (Optional but Recommended)

While Hive can query GCS directly, moving data to HDFS is a common practice for performance and learning purposes.

```bash
# Connect to your Dataproc Master node via SSH
gcloud compute ssh [CLUSTER_NAME]-m --region=[REGION]

# Create an HDFS directory
hdfs dfs -mkdir -p /user/hive/warehouse/chicago_crime_raw

# Copy from GCS to HDFS
hadoop distcp gs://$BUCKET_NAME/chicago_crime/crime_data_*.csv /user/hive/warehouse/chicago_crime_raw/
```

---

## 3. Hive Tables: Managed vs. External

### External Tables
An **External Table** points to data stored outside of Hive's default warehouse (like GCS or a specific HDFS path). If you drop the table, the **data remains**.

### Managed Tables
A **Managed Table** (or Internal Table) is managed entirely by Hive. If you drop the table, the **data is also deleted**.

---

## 4. Hands-on Hive Commands

Launch the Hive CLI by typing `hive` or use `beeline` on your master node.

### Create an External Table
This table will map to the CSV we just uploaded. Note the `skip.header.line.count` property to ignore the CSV header.

```sql
CREATE EXTERNAL TABLE crime_staging (
    unique_key STRING,
    case_number STRING,
    crime_date STRING,
    block STRING,
    iucr STRING,
    primary_type STRING,
    description STRING,
    location_description STRING,
    arrest BOOLEAN,
    domestic BOOLEAN,
    beat INT,
    district INT,
    ward INT,
    community_area INT,
    fbi_code STRING,
    x_coordinate FLOAT,
    y_coordinate FLOAT,
    year INT,
    updated_on STRING,
    latitude FLOAT,
    longitude FLOAT,
    location STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/chicago_crime_raw'
TBLPROPERTIES ("skip.header.line.count"="1");
```

### Basic Querying
```sql
-- Count total records
SELECT count(*) FROM crime_staging;

-- View top 10 rows
SELECT * FROM crime_staging LIMIT 10;

-- Filter by crime type
SELECT primary_type, description FROM crime_staging WHERE arrest = true LIMIT 5;
```

---

## 5. Advanced Tables: Partitioning and Bucketing

### Partitioned Tables
Partitioning physically divides the data into subdirectories based on a column (e.g., `year`). This significantly speeds up queries that filter by that column.

```sql
-- Create a partitioned table
CREATE TABLE crime_partitioned (
    unique_key STRING,
    case_number STRING,
    crime_date STRING,
    primary_type STRING,
    description STRING,
    arrest BOOLEAN
)
PARTITIONED BY (year INT)
STORED AS ORC; -- ORC is optimized for Hive performance
```

#### Inserting Data into Partitions
To enable dynamic partitioning and prevent "too many partitions" errors, you must set these Hive properties:
```sql
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

-- Increase limits for many partitions
SET hive.exec.max.dynamic.partitions=1000;
SET hive.exec.max.dynamic.partitions.pernode=1000;

-- Insert data from staging
INSERT INTO TABLE crime_partitioned PARTITION(year)
SELECT unique_key, case_number, crime_date, primary_type, description, arrest, year 
FROM crime_staging;
```

### Bucketed (Clustered) Tables
Bucketing organizes data into a fixed number of "buckets" based on a hash of a specific column. This is useful for joins and sampling.

```sql
CREATE TABLE crime_bucketed (
    unique_key STRING,
    primary_type STRING,
    description STRING
)
CLUSTERED BY (unique_key) INTO 10 BUCKETS
STORED AS ORC;

-- Set bucketing property
SET hive.enforce.bucketing = true;

-- Insert data
INSERT INTO TABLE crime_bucketed 
SELECT unique_key, primary_type, description FROM crime_staging;
```

---

### Data Type Conversion (Optional)
If your source CSV has dates in a specific format (e.g., `MM/dd/yyyy`), you can convert them to proper Hive Timestamps during insertion:

```sql
INSERT INTO TABLE crime_partitioned PARTITION(year)
SELECT 
    unique_key, 
    case_number, 
    from_unixtime(unix_timestamp(crime_date, "MM/dd/yyyy hh:mm:ss")) as crime_date,
    primary_type, 
    description, 
    arrest, 
    year 
FROM crime_staging;
```

---

## 6. Summary of Key Hive Concepts

| Command / Concept | Description |
| :--- | :--- |
| `EXTERNAL` | Data lives outside Hive; dropping the table won't delete data. |
| `PARTITIONED BY` | Splits data into folders; optimizes `WHERE` clause performance. |
| `CLUSTERED BY` | Hashes data into buckets; improves join and sampling efficiency. |
| `STORED AS ORC` | A columnar storage format that is much faster than `TEXTFILE`. |
| `LOAD DATA LOCAL` | Move data from the Linux local disk into a Hive table. |

---

## 7. Troubleshooting & Performance

1.  **Dynamic Partitions**: If your insert fails, ensure `hive.exec.dynamic.partition.mode` is set to `nonstrict`.
2.  **Schema Mismatches**: CSV data must exactly match the column order and types defined in the `CREATE TABLE` statement.
3.  **Data Formats**: For production, always prefer **ORC** or **Parquet** over `TEXTFILE` for massive performance gains.

---

## 8. Practice Queries (HQL)

Use these queries to practice and explore the Chicago Crime dataset in Hive.

### 1. Most Common Crimes
Identify the top 10 most frequent types of crime in Chicago.
```sql
SELECT primary_type, COUNT(*) as crime_count
FROM crime_staging
GROUP BY primary_type
ORDER BY crime_count DESC
LIMIT 10;
```

### 2. Arrest Rate Analysis
Compare how many crimes resulted in an arrest vs. those that did not.
```sql
SELECT arrest, COUNT(*) as total
FROM crime_staging
GROUP BY arrest;
```

### 3. Crimes by Year (Using Partitioned Table)
Query the partitioned table to see the evolution of crime over time. Hive will only scan the relevant partition folders if you filter by `year`.
```sql
SELECT year, COUNT(*) as yearly_total
FROM crime_partitioned
GROUP BY year
ORDER BY year ASC;
```

### 4. High-Crime Locations
Find the top 5 blocks with the highest number of reported crimes.
```sql
SELECT block, COUNT(*) as crime_count
FROM crime_staging
GROUP BY block
ORDER BY crime_count DESC
LIMIT 5;
```

### 5. Filtering with Specific Conditions
Find all "DECEPTIVE PRACTICE" crimes that occurred in "STREET" locations.
```sql
SELECT unique_key, crime_date, description
FROM crime_staging
WHERE primary_type = 'DECEPTIVE PRACTICE' 
  AND location_description = 'STREET'
LIMIT 20;
```

### 6. Complex Aggregation
Find crime types that have more than 50,000 reported cases.
```sql
SELECT primary_type, COUNT(*) as total
FROM crime_staging
GROUP BY primary_type
HAVING total > 50000
ORDER BY total DESC;
```
