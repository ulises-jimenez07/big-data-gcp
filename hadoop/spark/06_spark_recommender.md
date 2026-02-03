# Recommendation Systems with Spark ALS

One of Spark MLlib's most powerful algorithms is **ALS (Alternating Least Squares)**, used for **Collaborative Filtering**. This is the technology behind "Recommended for you" sections in Netflix or Amazon.

In this tutorial, we will build a system to recommend **Stack Overflow Tags** to users based on their activity.

## 1. Understanding Collaborative Filtering

Collaborative filtering works by building a user-item matrix. If User A and User B both like Item X, and User A likes Item Y, the system recommends Item Y to User B.

**Note**: ALS requires numerical IDs for both users and items.

## 2. Preparing the Data (Stack Overflow)

We will use the `posts_questions` dataset. We'll treat a user's score on a specific tag as their "rating" for that topic.

```python
from pyspark.ml.recommendation import ALS
from pyspark.ml.feature import StringIndexer
from pyspark.ml import Pipeline
from pyspark.sql.functions import col

spark.conf.set("temporaryGcsBucket", "[PROJECT_ID]-hadoop")

# Load activity data
# We'll take a sample of questions, their owners, and the tags
raw_df = spark.read.format("bigquery") \
    .option("table", "bigquery-public-data.stackoverflow.posts_questions") \
    .load() \
    .select("owner_user_id", "tags", "score") \
    .filter("owner_user_id IS NOT NULL AND tags IS NOT NULL") \
    .limit(50000)

# Since 'tags' is a string like '<java><spring>', let's just take the first tag for simplicity
# and convert strings to numeric IDs for ALS
raw_df = raw_df.withColumn("main_tag", col("tags").substr(2, 5)) # Simplified

user_indexer = StringIndexer(inputCol="owner_user_id", outputCol="user_id_num")
tag_indexer = StringIndexer(inputCol="main_tag", outputCol="tag_id_num")

pipeline = Pipeline(stages=[user_indexer, tag_indexer])
processed_df = pipeline.fit(raw_df).transform(raw_df)

processed_df.select("owner_user_id", "user_id_num", "main_tag", "tag_id_num", "score").show(5)
```

## 3. Training the ALS Model

```python
# Split data
train, test = processed_df.randomSplit([0.8, 0.2])

# Build ALS model
# coldStartStrategy="drop" ensures we don't get NaN predictions for new users in the test set
als = ALS(maxIter=5, regParam=0.01, userCol="user_id_num", itemCol="tag_id_num", ratingCol="score", coldStartStrategy="drop")
model = als.fit(train)

# Evaluate
predictions = model.transform(test)
predictions.show(5)
```

## 4. Making Recommendations

The most exciting part: generating the top 3 recommended tags for every user in our dataset.

```python
# Generate top 3 tag recommendations for each user
user_recs = model.recommendForAllUsers(3)

# The output is nested (an array of structs). We can use our 'explode' skills!
from pyspark.sql.functions import explode

flat_recs = user_recs.select("user_id_num", explode("recommendations").alias("rec")) \
    .select("user_id_num", "rec.tag_id_num", "rec.rating")

flat_recs.show(10)
```

## 5. Why ALS?

- **Scalability**: ALS is designed for massive datasets with millions of users and items.
- **Sparsity**: It works even if most users have only interacted with a tiny fraction of total items.
- **Latent Factors**: The algorithm discovers hidden "features" (e.g., if a user likes "Java", they likely like "JVM" and "Spring") without you explicitly defining them.
