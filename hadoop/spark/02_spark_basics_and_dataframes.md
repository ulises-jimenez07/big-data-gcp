# Spark Basics and DataFrames

Apache Spark is a distributed compute engine. In Python, we use the `pyspark` library to interact with it. The core abstraction is the **DataFrame**.

## 1. Initializing the Spark Session

Every Spark application starts with a `SparkSession`.

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count

# Initialize session
spark = SparkSession.builder \
    .appName("Spark Basics Tutorial") \
    .getOrCreate()
```

## 2. Reading Data

Spark can read from various sources: HDFS, GCS, Local FS (if accessible by all nodes), and Databases.

### From Local or HDFS
```python
# Assuming you uploaded a file to HDFS in the previous Hadoop module
df_hdfs = spark.read.text("/user/example1/mi_archivo.txt")
df_hdfs.show()
```

### From Google Cloud Storage (GCS)
Dataproc is natively integrated with GCS using the `gs://` protocol.

```python
# Use a verified public dataset (small CSV with US states)
# Alternatively, use data you exported in the Hive tutorial: gs://YOUR_BUCKET/chicago_crime/...
path = "gs://cloud-samples-data/bigquery/us-states/us-states.csv"

df = spark.read.csv(path, header=True, inferSchema=True)
df.show(5)
```

## 3. Basic DataFrame Operations

Think of a Spark DataFrame as a distributed table.

```python
# Sample data
data = [("Alice", 34, "New York"), ("Bob", 45, "London"), ("Cathy", 29, "New York")]
columns = ["Name", "Age", "City"]

df = spark.createDataFrame(data, columns)

# 1. Selection
df.select("Name", "City").show()

# 2. Filtering
df.filter(col("Age") > 30).show()

# 3. Aggregation (Group By)
df.groupBy("City").agg(avg("Age"), count("Name")).show()

# 4. Adding/Modifying Columns
df.withColumn("AgePlusTen", col("Age") + 10).show()
```

## 4. Lazy Evaluation

One of Spark's most important concepts is **Lazy Evaluation**. Spark doesn't execute transformations (like `filter` or `select`) immediately. Instead, it builds a logical plan. The execution only starts when an **Action** is called (like `show()`, `collect()`, `count()`, or `save()`).

## 5. Caching and Persistence

If you are going to use the same DataFrame multiple times (e.g., in an iterative ML algorithm), you should cache it in memory.

```python
df.cache() # Or .persist() for more control over storage level
df.count() # Action that triggers the actual load and caching
```

## 6. Closing the Session

It's a best practice to close the `SparkSession` once you are done with your analysis. This releases resources back to the cluster (YARN).

```python
spark.stop()
```
