# BigQuery: Getting Started and Data Ingestion

BigQuery is a fully managed, serverless data warehouse that enables scalable analysis over petabytes of data. This tutorial covers how to set up your environment, create a dataset, and ingest data.

## 1. Environment Setup

To follow the examples in these tutorials, we will use data from the "Data Science on GCP" book. Clone the repository to get access to the ingestion scripts and sample data structure information.

```bash
# Clone the repository
git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd data-science-on-gcp/02_ingest/
```

---

## 2. Creating a Dataset

In BigQuery, data is organized into **Datasets**, which contain **Tables** and **Views**. You MUST create this dataset first, as it will be used in all subsequent tutorials.

### Create via GCP Console
1.  Open the **BigQuery** page in the Google Cloud Console.
2.  In the **Explorer** pane, click on the three dots (Actions) next to your project ID.
3.  Select **Create dataset**.
4.  **Dataset ID**: `dsongcp` (Data Science on GCP).
5.  **Location**: Choose a region (e.g., `US` or `us-central1`).
6.  Click **Create Dataset**.

### Create via `bq` CLI
Alternatively, run this in your terminal:

```bash
bq mk dsongcp
```

---

## 2. Loading Data from Local Files

You can load CSV, JSON, Parquet, or Avro files directly into BigQuery.

### Command Line (`bq load`)
To load a local CSV file and let BigQuery automatically detect the schema:

```bash
bq load --autodetect --source_format=CSV \
   dsongcp.flights_auto \
   ./201501.csv
```

*   `--autodetect`: BigQuery infers the column names and data types.
*   `dsongcp.flights_auto`: The destination table (dataset.table).

---

## 3. Loading Data from Google Cloud Storage (GCS)

For large datasets, it is best practice to store them in GCS first.

### Step 1: Upload to GCS
```bash
gsutil cp 201501.csv gs://my-bucket-name/flights/raw/
```

### Step 2: Load into BigQuery
```bash
./bqload.sh my-bucket-name 2015 
```

---

## 4. Basic Data Exploration

Once loaded, you can run a simple query to verify the data:

```sql
SELECT 
    * 
FROM 
    dsongcp.flights_raw 
LIMIT 5;
```

### Formatting Dates
Sometimes data is loaded as strings. You can use SQL to format them:

```sql
SELECT 
    FORMAT("%s-%02d-%02d",
        Year,
        CAST(Month AS INT64),
        CAST(DayofMonth AS INT64)) AS resurrect,
    FlightDate,
    CAST(EXTRACT(YEAR FROM FlightDate) AS INT64) AS ex_year,
    CAST(EXTRACT(MONTH FROM FlightDate) AS INT64) AS ex_month,
    CAST(EXTRACT(DAY FROM FlightDate) AS INT64) AS ex_day,
FROM dsongcp.flights_raw
LIMIT 5;
```

## 5. Creating Views

A View is a virtual table defined by a SQL query. It doesn't store data itself but provides a simplified interface to complex queries.

```sql
CREATE OR REPLACE VIEW dsongcp.flights AS

SELECT
  FlightDate AS FL_DATE,
  Reporting_Airline AS UNIQUE_CARRIER,
  OriginAirportSeqID AS ORIGIN_AIRPORT_SEQ_ID,
  Origin AS ORIGIN,
  DestAirportSeqID AS DEST_AIRPORT_SEQ_ID,
  Dest AS DEST,
  CRSDepTime AS CRS_DEP_TIME,
  DepTime AS DEP_TIME,
  CAST(DepDelay AS FLOAT64) AS DEP_DELAY,
  CAST(TaxiOut AS FLOAT64) AS TAXI_OUT,
  WheelsOff AS WHEELS_OFF,
  WheelsOn AS WHEELS_ON,
  CAST(TaxiIn AS FLOAT64) AS TAXI_IN,
  CRSArrTime AS CRS_ARR_TIME,
  ArrTime AS ARR_TIME,
  CAST(ArrDelay AS FLOAT64) AS ARR_DELAY,
  IF(Cancelled = '1.00', True, False) AS CANCELLED,
  IF(Diverted = '1.00', True, False) AS DIVERTED,
  DISTANCE
FROM dsongcp.flights_raw;
```