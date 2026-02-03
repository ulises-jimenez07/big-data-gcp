# Machine Learning with Spark MLlib

Spark MLlib is the component for machine learning. It uses a **Pipeline** approach similar to Scikit-Learn but distributed across the cluster.

In this tutorial, we will build a model to predict the **Total Trip Cost** of a Chicago Taxi based on trip features, using the data we stored in Hive in the previous step.

## 1. Preparing Data for Machine Learning

Spark models require a single column of type `Vector` containing all features. We use `VectorAssembler` for this.

```python
from pyspark.ml.feature import VectorAssembler
from pyspark.sql.functions import col

# 1. Load data from the Hive table we created previously
df = spark.table("hive_taxi_data")

# 2. Basic cleanup (Ensure we don't have nulls for the model)
df = df.na.drop()

# 3. Assemble features into a vector
# We want to predict 'trip_total' using miles, seconds, and fare components
feature_cols = ["trip_seconds", "trip_miles", "fare", "tips", "extras"]
assembler = VectorAssembler(inputCols=feature_cols, outputCol="features")

# Show how the vector looks
vector_df = assembler.transform(df)
vector_df.select("features", "trip_total").show(5, truncate=False)
```

## 2. Using Pipelines for a Full Workflow

Pipelines allows you to chain multiple stages together. This is cleaner and less error-prone.

```python
from pyspark.ml.regression import LinearRegression
from pyspark.ml import Pipeline

# 1. Split Data into Training (70%) and Testing (30%)
train_data, test_data = df.randomSplit([0.7, 0.3], seed=42)

# 2. Define stages
assembler = VectorAssembler(inputCols=feature_cols, outputCol="features")
lr = LinearRegression(featuresCol="features", labelCol="trip_total")

# 3. Create and Train the Pipeline
pipeline = Pipeline(stages=[assembler, lr])
model = pipeline.fit(train_data)

# 4. Make Predictions on the Test Set
predictions = model.transform(test_data)
predictions.select("features", "trip_total", "prediction").show(5)
```

## 3. Model Evaluation

To know if our model is any good, we evaluate it using standard metrics like **RMSE** (Root Mean Squared Error).

```python
from pyspark.ml.evaluation import RegressionEvaluator

evaluator = RegressionEvaluator(labelCol="trip_total", predictionCol="prediction", metricName="rmse")
rmse = evaluator.evaluate(predictions)

print(f"Root Mean Squared Error (RMSE): {rmse:.4f}")

# You can also access the R2 summary from the model
summary = model.stages[-1].summary
print(f"R2 (Coefficient of Determination): {summary.r2:.4f}")
```

## 4. Why Pipelines?

Pipelines ensure that the exact same transformations are applied to both the training data and the test/future data. If you added a `StringIndexer` or a `StandardScaler` to your training workflow, the Pipeline would handle that automatically for your predictions as well, preventing data leakage.
