# BigQuery Challenge: Chicago Taxi Analysis

Now it's time to put your BigQuery skills to the test. In this challenge, you will analyze the **Chicago Taxi Trips** public dataset to find patterns in ridership and tip behavior.

## 1. Preparation
We will work with the `bigquery-public-data.chicago_taxi_trips.taxi_trips` table.

### Task 1: Optimization
Create a new table in your `dsongcp` dataset called `chicago_taxi_optimized`.
- **Partition** by the `trip_start_timestamp` (by MONTH).
- **Cluster** by `payment_type` and `company`.

---

## 2. SQL Analysis

### Task 2: Payment Trends
Calculate the average trip total and average tip amount for each `payment_type`.
- Filter for trips that happened in **2022**.
- Only include payment types with more than **1,000 trips**.
- Order by the highest average tip.

### Task 3: Peak Hours
Find the top 5 busiest hours of the day (0-23) for taxi pickups in Chicago.
- Use the `EXTRACT` function on `trip_start_timestamp`.
- Group and order accordingly.

---

## 3. Data Quality

### Task 4: Missing Data
Identify which columns have the most NULL values in the dataset. Write a query that computes the count of nulls for `fare`, `trip_miles`, and `tolls` in a single row.

---

## 4. Machine Learning (Bonus)

### Task 5: Tip Predictor
Create a Logistic Regression model in BigQuery that predicts if a passenger will leave a **"High Tip"** (more than 20% of the fare).
- **Features to use**: `trip_miles`, `trip_seconds`, `payment_type`, and the hour of the day.
- **Label**: `is_high_tip` (True/False).
- Use `FARM_FINGERPRINT` to set aside 20% of the data for evaluation.

---

## Submission
Save your queries in a `.sql` file. Once finished, compare your solutions with the `08_bigquery_challenge_answers.md` file!
