# BigQuery Integration: Notebooks and Visualization

This tutorial demonstrates how to use BigQuery directly from Python notebooks (Jupyter, Vertex AI Workbench) and visualize the results using popular libraries like Pandas and Seaborn.

> **Prerequisite**: Ensure you have completed [Tutorial 01: Ingestion](./01_bigquery_ingestion_tutorial.md) and have the `dsongcp` dataset ready.

## 1. The `%%bigquery` Magic

In Google Cloud notebooks, you can run BigQuery SQL cells using the `%%bigquery` magic command.

### Simple Query
```python
%%bigquery
SELECT
  COUNTIF(arr_delay >= 15)/COUNT(arr_delay) AS frac_delayed
FROM dsongcp.flights
```

### Loading into a DataFrame
To work with the data in Python, assign the result to a variable:

```python
%%bigquery df
SELECT 
  ARR_DELAY, 
  DEP_DELAY
FROM dsongcp.flights
WHERE DEP_DELAY >= 10
```

Now you can use standard Pandas methods:
```python
df.describe()
```

---

## 2. Visualization with Seaborn

Once you have your data in a DataFrame, you can create professional visualizations.

### Setup
```python
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

sns.set_style("whitegrid")
```

### Violin Plot: Visualizing Arrival Delays
```python
ax = sns.violinplot(data=df, x='ARR_DELAY', inner='box', orient='h')
ax.axes.set_xlim(-50, 300)
plt.title("Distribution of Arrival Delays (Departure Delay >= 10m)")
plt.show()
```

### Comparative Visualization
Let's see the distribution of arrival delays for flights that departed "On Time" (< 10m) vs "Delayed":

```python
# Create a boolean column
df['ontime'] = df['DEP_DELAY'] < 10

# Plot comparing the two groups
ax = sns.violinplot(data=df, x='ARR_DELAY', y='ontime',
                    inner='box', orient='h')
ax.set_xlim(-50, 200)
plt.title("Arrival Delay Comparison: On-Time vs Delayed Departures")
plt.show()
```

---

## 3. Best Practices for Notebooks
- **Filter Early**: Always use `WHERE` clauses in your SQL magic to limit the data transferred to the notebook.
- **Sampling**: If the dataset is huge, use `LIMIT` or random sampling to avoid crashing the notebook's memory.
- **Project ID**: In some environments, you may need to specify the project:
  ```python
  %%bigquery --project your-project-id
  ```
