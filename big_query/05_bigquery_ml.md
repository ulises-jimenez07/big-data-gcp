# BigQuery ML: Machine Learning with SQL

BigQuery ML (BQML) allows you to create and execute machine learning models in BigQuery using standard SQL queries. No Python or specialized ML frameworks are required for many common tasks.

> **Prerequisite**: Ensure you have created the `dsongcp.flights` view defined in [Tutorial 04: Advanced Analytics](./04_bigquery_advanced_analytics.md).

## 1. Data Splitting

Before training, you should split your data into Training and Evaluation sets. A robust way to do this in SQL is using `FARM_FINGERPRINT`.

```sql
CREATE OR REPLACE TABLE dsongcp.trainday AS
SELECT
  FL_DATE,
  IF(ABS(MOD(FARM_FINGERPRINT(CAST(FL_DATE AS STRING)), 100)) < 70,
     'True', 'False') AS is_train_day
FROM (
  SELECT DISTINCT(FL_DATE) AS FL_DATE FROM dsongcp.flights
)
ORDER BY FL_DATE;
```
*   This assigns roughly 70% of days to training and 30% to evaluation based on the hash of the date.

---

## 2. Training a Model

To train a model, use the `CREATE MODEL` statement. We will predict if a flight will be "Late" or "On Time" based on its departure delay, taxi time, and distance.

```sql
CREATE OR REPLACE MODEL dsongcp.arr_delay_model
OPTIONS(
  model_type='logistic_reg', 
  input_label_cols=['ontime']
) AS
SELECT
  IF(arr_delay < 15, 'ontime', 'late') AS ontime,
  dep_delay,
  taxi_out,
  distance
FROM dsongcp.flights f
JOIN dsongcp.trainday t ON f.FL_DATE = t.FL_DATE
WHERE t.is_train_day = 'True'
  AND f.CANCELLED = False 
  AND f.DIVERTED = False;
```

---

## 3. Evaluating the Model

Once trained, check how well your model performs using `ML.EVALUATE`.

```sql
SELECT 
  * 
FROM ML.EVALUATE(MODEL dsongcp.arr_delay_model, (
  SELECT
    IF(arr_delay < 15, 'ontime', 'late') AS ontime,
    dep_delay,
    taxi_out,
    distance
  FROM dsongcp.flights f
  JOIN dsongcp.trainday t ON f.FL_DATE = t.FL_DATE
  WHERE t.is_train_day = 'False' -- Use evaluation days
));
```

---

## 4. Making Predictions

Use `ML.PREDICT` to get predictions for new data.

```sql
SELECT 
  * 
FROM ML.PREDICT(MODEL dsongcp.arr_delay_model, (
  SELECT 
    12.0 AS dep_delay, 
    14.0 AS taxi_out, 
    1231 AS distance
));
```

---

## 5. Inspeccionando los Pesos (Weights)

To understand which features are most important according to the model:

```sql
SELECT * FROM ML.WEIGHTS(MODEL dsongcp.arr_delay_model);
```
