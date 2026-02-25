# BigQuery Deep Dive: Essential Advanced Functions

In the BigQuery tutorials, we encountered powerful functions like `RANK()`, `UNNEST()`, `QUALIFY`, and `ARRAY_AGG`. While the tutorials show how to use them, this document provides a deeper dive into **how they work**, their syntax, and common use cases.

---

## 1. The `RANK()` Function (Window Functions)

`RANK()` is a **Window Function** (also known as an Analytical Function). Unlike standard aggregate functions (`SUM`, `COUNT`) that collapse rows into a single result, window functions perform calculations across a set of rows while still returning each individual row.

### The Syntax
```sql
RANK() OVER(
  [PARTITION BY column_name] 
  ORDER BY column_name [ASC|DESC]
)
```

### Breakdown of Components:
1.  **`OVER()`**: This is the mandatory clause that defines the "window" of rows the function will operate on.
2.  **`PARTITION BY`** (Optional): This divides the data into logical groups (like buckets). The rank will reset for each new partition.
    - *Example*: `PARTITION BY station_id` means ranking trips *within each station*.
3.  **`ORDER BY`**: This determines the criteria for the rank.
    - *Example*: `ORDER BY tripduration DESC` ranks the longest trips as #1.

### Example from Tutorial 04:
```sql
SELECT
  start_station_name,
  tripduration,
  RANK() OVER(PARTITION BY start_station_id ORDER BY tripduration DESC) as trip_rank
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
QUALIFY trip_rank <= 3
```

### How it behaves with ties:
If two rows have the same value (e.g., two trips last exactly 1000 seconds), `RANK()` will give them the **same rank** but will **skip** the next rank.
- Row A: 1000s -> Rank 1
- Row B: 1000s -> Rank 1
- Row C: 950s  -> **Rank 3** (Rank 2 is skipped)

> **Pro Tip**: If you don't want to skip numbers, use `DENSE_RANK()`. If you want a unique number for every row even with ties, use `ROW_NUMBER()`.

---

## 2. The `UNNEST()` Function (Handling Arrays)

BigQuery is designed to handle **nested and repeated data** (like JSON). `UNNEST()` is the tool used to take an **Array** (a list of items in a single cell) and turn it into **multiple rows**.

### Why use it?
Standard SQL expects one value per cell. But in BigQuery, a cell can contain `['apple', 'banana', 'cherry']`. You cannot easily filter or count these items while they are inside the array. `UNNEST()` "flattens" them.

### The Syntax
```sql
SELECT item 
FROM UNNEST(['apple', 'banana', 'cherry']) AS item
```

### How it works in a Query (Implicit Join):
When you use `UNNEST()` in a `FROM` clause alongside a table, BigQuery performs an **Implicit Cross Join** between the row and the items in the array.

### Example from Tutorial 04:
Turning a string of tags into individual rows:
```sql
SELECT
  tag,
  COUNT(*) as frequency
FROM
  `bigquery-public-data.stackoverflow.posts_questions`,
  UNNEST(SPLIT(tags, '|')) as tag
GROUP BY tag
```

**Step-by-step logic:**
1.  **`SPLIT(tags, '|')`**: Takes a string like `"java|sql|bigquery"` and turns it into an array `['java', 'sql', 'bigquery']`.
2.  **`UNNEST(...)`**: Takes that array and creates 3 virtual rows.
3.  **The Join**: If the original row had an ID of `101`, BigQuery effectively creates:
    - Row 1: ID 101, tag 'java'
    - Row 2: ID 101, tag 'sql'
    - Row 3: ID 101, tag 'bigquery'
4.  **Aggregation**: Now that they are individual rows, `GROUP BY tag` works perfectly.

### Common Use Cases:
- **Flattening JSON logs**: Processing event parameters.
- **Filtering Arrays**: Finding rows where *any* element in an array matches a condition.
- **Exploding Tags**: Analyzing counts of categories or keywords.

---

## 3. The `QUALIFY` Clause (Filtering Window Functions)

`QUALIFY` is a specialized clause in BigQuery that filters the results of window functions. 

### Why use it?
In standard SQL, clauses are executed in this order: `FROM` -> `WHERE` -> `GROUP BY` -> `HAVING` -> `WINDOW FUNCTIONS` -> `SELECT`.
Because window functions are calculated **after** the `WHERE` clause, you usually cannot filter by a rank in a simple `WHERE`. You would normally need a CTE:

**The "Old" way (Standard SQL):**
```sql
WITH ranked_trips AS (
  SELECT *, RANK() OVER(...) as rnk FROM trips
)
SELECT * FROM ranked_trips WHERE rnk = 1
```

**The BigQuery way:**
```sql
SELECT *, RANK() OVER(...) as rnk 
FROM trips 
QUALIFY rnk = 1
```
`QUALIFY` eliminates the need for extra subqueries or CTEs when filtering by analytical results.

---

## 4. `COUNTIF()` (Conditional Aggregation)

`COUNTIF(expression)` is a clean way to perform conditional counting. It is equivalent to `COUNT(*) WHERE expression IS TRUE`.

### Example:
```sql
SELECT 
  COUNTIF(tips > 10) as big_tips,
  COUNTIF(trip_miles < 1) as short_trips
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
```

It is much more readable than the standard SQL alternative: `SUM(CASE WHEN tips > 10 THEN 1 ELSE 0 END)`.

---

## 5. `ARRAY_AGG()` and `STRUCT` (Grouping into Nested Data)

While `UNNEST()` takes arrays apart, `ARRAY_AGG()` puts them back together. `STRUCT` allows you to group multiple columns into a single object.

### The Concept:
Imagine you want to see a list of every trip a bike took, but you want it all inside a single row for that `bike_id`.

```sql
SELECT
  bike_id,
  ARRAY_AGG(
    STRUCT(tripduration, start_station_name)
    ORDER BY starttime DESC LIMIT 5
  ) as recent_trips
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY bike_id
```

- **`STRUCT(...)`**: Combines `tripduration` and `station_name` into a single "object" or "record".
- **`ARRAY_AGG(...)`**: Collects those structs into a list (ARRAY).
- **`ORDER BY ... LIMIT ...`**: You can even sort and truncate the list *inside* the aggregation!

---

---

## 6. Cumulative Aggregations (Running Totals)

Window functions aren't just for ranking; they are also used for **Running Totals**.

```sql
SUM(daily_duration) OVER(ORDER BY trip_date) as cumulative_duration
```

By default, when you use `ORDER BY` inside a `SUM()` window function, BigQuery treats the window as "everything from the beginning of time up to the current row". This is how you calculate growth or daily totals.

---

## 7. Geospatial Functions (`ST_`)

BigQuery recognizes geographic data natively. 
- **`ST_GEOGPOINT(lon, lat)`**: Converts coordinates into a `GEOGRAPHY` type.
- **`ST_DISTANCE(point1, point2)`**: Calculates the shortest distance (in meters) between two points on the Earth's surface.

---

## 8. Common Utility Functions

### `FARM_FINGERPRINT()` (Deterministic Sampling)
In the challenge answers, we used this to split data into 80% training and 20% testing:
```sql
WHERE ABS(MOD(FARM_FINGERPRINT(unique_key), 10)) < 8
```
`FARM_FINGERPRINT` converts a string/ID into a large integer. Because it is **deterministic** (the same ID always gives the same number), it is the industry-standard way to randomly sample data without accidentally including the same row in both training and test sets.

### `EXTRACT()`
Quickly pulls components out of a `DATE`, `DATETIME`, or `TIMESTAMP`.
```sql
EXTRACT(HOUR FROM starttime)
EXTRACT(DAYOFWEEK FROM starttime) -- 1 (Sunday) to 7 (Saturday)
```

---

## Summary Comparison

| Feature | `RANK()` | `UNNEST()` | `QUALIFY` | `ARRAY_AGG()` | `FARM_FINGERPRINT()` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Purpose** | Ordering data. | Arrays -> Rows. | Filtering Ranks. | Rows -> Arrays. | Stable Sampling. |
| **Input** | Column/Expr. | `ARRAY`. | Boolean. | Column/Struct. | String/Integer/Any. |
| **Output** | Integer. | Rows. | Filtered Rows. | `ARRAY`. | Hash (INT64). |

By mastering these functions, you unlock the ability to perform complex analytical rankings, handle modern semi-structured data, and write much cleaner, more efficient SQL.
