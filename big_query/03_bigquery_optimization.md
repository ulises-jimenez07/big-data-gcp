To optimize query performance and reduce costs, BigQuery uses **Partitioning** and **Clustering**. These features allow BigQuery to only scan the data relevant to your query.

## 0. Create the Destination Dataset

Before creating partitioned or clustered tables, you must have a destination dataset.

```bash
bq mk --location=US partition_ds
```

## 1. Partitioning

A **Partitioned Table** is a special table that is divided into segments, called partitions.

### Why Partition?
- **Cost**: You are only charged for the data scanned in the specific partitions you query.
- **Performance**: Queries are faster because they skip irrelevant data.

### Creating a Partitioned Table (CLI)
You can create a partitioned table using the result of a query. Let's partition the Chicago Crime dataset by **Month**:

```bash
bq query \
 --use_legacy_sql=false \
 --destination_table partition_ds.crime_partitioned \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 'SELECT * FROM `bigquery-public-data.chicago_crime.crime`'
```

---

## 2. Clustering

**Clustering** further organizes data within each partition based on the values in one or more columns.

### When to Cluster?
- Use clustering for columns that you frequently use in filters (`WHERE`) or aggregations (`GROUP BY`).
- Clustering is most effective when used *with* partitioning.

### Creating a Partitioned and Clustered Table
```bash
bq query \
 --use_legacy_sql=false \
 --destination_table partition_ds.crime_optimized \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 --clustering_fields primary_type \
 'SELECT * FROM `bigquery-public-data.chicago_crime.crime`'
```

---

## 3. Querying Partitioned Tables

To enjoy the benefits of partitioning, you MUST include the partitioning field in your `WHERE` clause.

```sql
-- This query only scans the partition for Feb 2006
SELECT 
  * 
FROM `partition_ds.crime_optimized` 
WHERE TIMESTAMP_TRUNC(date, MONTH) = TIMESTAMP("2026-02-01")
  AND primary_type = 'INTIMIDATION';
```

---

## 4. Monitoring Partitions

You can query the table's metadata to see how many partitions exist and how much data they hold.

```sql
SELECT 
  *
FROM `partition_ds.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'crime_optimized';
```

---

## Key Differences
| Feature | Partitioning | Clustering |
| :--- | :--- | :--- |
| **Organization** | Physical segments (Date/Integer) | Sorted order within partitions |
| **Limits** | Max 4,000 partitions per table | Up to 4 columns |
| **Cost Estimator** | Provides cost estimate before run | No estimate (charged after run) |
| **Best For** | Time-series, large date ranges | High-cardinality columns, specific filters |
