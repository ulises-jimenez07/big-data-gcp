# BigQuery: Visualization with Looker Studio

This tutorial covers how to connect BigQuery to **Looker Studio** (formerly Data Studio) to create interactive dashboards and visualize the flight data we've processed.

> **Prerequisite**: Ensure you have created the `dsongcp.flights` view defined in [Tutorial 04: Advanced Analytics](./04_bigquery_advanced_analytics.md).

## 1. Connecting BigQuery to Looker Studio

1.  Go to [lookerstudio.google.com](https://lookerstudio.google.com).
2.  Click **Create** > **Report**.
3.  Select **BigQuery** as the connector.
4.  Choose your **Project**, the **Dataset** (`dsongcp`), and the **View** (`flights`).
5.  Click **Add**.

---

## 2. Creating Calculated Fields

We can create new dimensions directly in Looker Studio without changing our SQL code.

### Step 1: Create the "Status" Field
1.  Click on **Add a field** in the bottom right (Data pane).
2.  **Field Name**: `flight_status`
3.  **Formula**:
    ```sql
    CASE 
      WHEN ARR_DELAY < 15 THEN "ON TIME"
      ELSE "LATE"
    END
    ```
4.  Click **Save**.

---

## 3. Designing the Dashboard

Follow these steps to create the visuals suggested in the *Data Science on GCP* book:

### A. Scatter Plot: Dependency Analysis
This helps visualize the correlation between departure delays and arrival delays.
- **Chart Type**: Scatter Chart.
- **Dimension**: `FL_DATE` (or `UNIQUE_CARRIER`).
- **X-axis**: `DEP_DELAY`.
- **Y-axis**: `ARR_DELAY`.
- **Tooltip**: `ORIGIN` or `DEST`.
*Why? You'll see a clear linear trend, confirming that departure delay is the biggest predictor of arrival delay.*

### B. Pie Chart: Flight Status
- **Chart Type**: Pie Chart.
- **Dimension**: `flight_status` (the calculated field we just created).
- **Metric**: Record Count.

### C. Bar Chart: Delays by Airline
- **Chart Type**: Column Chart.
- **Dimension**: `UNIQUE_CARRIER`.
- **Metric**: `ARR_DELAY` (Set aggregation to **Average**).
- **Sort**: `ARR_DELAY` Descending.

---

## 4. Professional Polish
- **Date Range Control**: Add a "Date Range" widget so users can filter by specific months or days.
- **Filter Link**: Add a "Drop-down list" for `ORIGIN` so you can see the performance of specific airports.
- **Theme**: Switch to "Edge" or "Constellation" theme for a modern, premium look.
