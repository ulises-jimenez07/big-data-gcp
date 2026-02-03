# Handling Complex Data Structures (Arrays & JSON)

In modern Big Data, schemas are rarely flat. Spark excely at handling nested structures, arrays, and JSON objects. In this tutorial, we will explore the **GitHub Commits** dataset, which contains nested author information and arrays of trailers.

## 1. Reading Nested Data from BigQuery

We will pull a sample of GitHub commits.

```python
from pyspark.sql.functions import col, explode, size

spark.conf.set("temporaryGcsBucket", "[PROJECT_ID]-hadoop")

# Read GitHub commits (highly nested structure)
commits_df = spark.read.format("bigquery") \
    .option("table", "bigquery-public-data.github_repos.commits") \
    .load() \
    .select("commit", "author", "repo_name") \
    .limit(1000)

commits_df.printSchema()
```

Notice that `author` is a `struct` (like a dictionary) and `commit` contains a `message`.

## 2. Navigating Structs (Dot Notation)

To access fields inside a `struct`, use the dot operator.

```python
# Accessing nested fields
authors_df = commits_df.select(
    col("repo_name"),
    col("author.name").alias("author_name"),
    col("author.email").alias("email"),
    col("author.date").alias("commit_date")
)

authors_df.show(5)
```

## 3. Exploding Arrays

Sometimes a column contains a list (Array). To perform analysis on individual elements, we use `explode()`. This creates a new row for every element in the array.

Assume we want to analyze commit "trailers" (like `Signed-off-by`).

```python
# Select the 'trailers' array inside the 'commit' struct
trailers_df = commits_df.select("repo_name", "commit.trailer")

# Check how many trailers each commit has
trailers_count = trailers_df.withColumn("num_trailers", size(col("trailer")))
trailers_count.filter("num_trailers > 1").show(5)

# 'Explode' the array: One row per trailer
exploded_df = trailers_df.select("repo_name", explode("trailer").alias("single_trailer"))

# Now we can access fields inside the exploded struct
exploded_df.select("repo_name", "single_trailer.key", "single_trailer.value").show(10)
```

## 4. Aggregating on Complex Data

Now that we've flattened the data, we can perform standard aggregations.

```python
# Which 'keys' are most common in GitHub trailers?
top_trailers = exploded_df.groupBy("single_trailer.key") \
    .count() \
    .orderBy(col("count").desc())

top_trailers.show()
```

## 5. Summary of Functions

- **`col("parent.child")`**: Accesses a field inside a Struct.
- **`explode(col("array_column"))`**: Flattens an array into multiple rows.
- **`size(col("array_column"))`**: Returns the number of elements in an array.
- **`to_json()` / `from_json()`**: Useful for converting between strings and complex structures.

This "flattening" process is essential before feeding data into Machine Learning models or saving it to flat Hive tables.
