# Dataflow: Development, Notebooks, and Execution

This tutorial covers how to set up your development environment in Google Cloud, iterate on your pipeline logic locally, and finally deploy a scalable job to Dataflow.

---

## 1. Setting Up the Development Environment

Google Cloud offers **Vertex AI Workbench** (managed JupyterLab) as the preferred environment for interactive Apache Beam development.

### Step 1: Enable APIs
Ensure the following APIs are enabled in your GCP project:
1.  **Dataflow API**
2.  **Compute Engine API**
3.  **Notebooks API** (Vertex AI)

### Step 2: Create a Notebook Instance
1.  In the GCP Console, go to **Vertex AI** > **Workbench**.
2.  Click **User-Managed Notebooks** > **+ NEW NOTEBOOK**.
3.  Choose the **Apache Beam** instance type (or Python 3).
4.  Configure the instance (e.g., `us-central1`, `e2-standard-4`) and click **CREATE**.
5.  Once running, click **OPEN JUPYTERLAB**.

---

## 2. Interactive Local Development

Before running a massive job on Dataflow, you should test your logic locally using the **DirectRunner** or **InteractiveRunner**. This allows you to catch bugs quickly without waiting for cloud resources to provision.

### Example 1: Filtering and Transforming Names
In your notebook, run the following code to process a small sample of public data:

```python
import apache_beam as beam
from apache_beam.runners.interactive.interactive_runner import InteractiveRunner
import apache_beam.runners.interactive.interactive_beam as ib

# 1. Initialize the Pipeline with InteractiveRunner
p = beam.Pipeline(InteractiveRunner())

# 2. Read a small subset of public data (USA Names)
raw_data = (
    p 
    | 'Read Sample' >> beam.io.ReadFromBigQuery(
        query='SELECT name, number, state FROM `bigquery-public-data.usa_names.usa_1910_current` LIMIT 100',
        use_standard_sql=True
    )
)

# 3. Apply ParDo logic
class CleanData(beam.DoFn):
    def process(self, element):
        yield {
            'name': element['name'].upper(),
            'count': element['number'],
            'state': element['state']
        }

processed_data = (
    raw_data 
    | 'Clean and Upper' >> beam.ParDo(CleanData())
    | 'Filter NY' >> beam.Filter(lambda x: x['state'] == 'NY')
)

# 4. Visualize results immediately in the notebook
ib.show(processed_data)
```

### Example 2: Aggregating Crime Types Locally
This example shows how to perform a local aggregation using the `Count` transform on a sample of crime data.

```python
# Create a new pipeline for a new experiment
p2 = beam.Pipeline(InteractiveRunner())

crime_summary = (
    p2
    | 'Read Crimes' >> beam.io.ReadFromBigQuery(
        query='SELECT primary_type FROM `bigquery-public-data.austin_crime.crime` LIMIT 500',
        use_standard_sql=True
    )
    | 'Extract Type' >> beam.Map(lambda row: row['primary_type'])
    | 'Count Per Type' >> beam.combiners.Count.PerElement()
)

# Display the aggregated counts
ib.show(crime_summary)
```

---

## 3. Creating a Full End-to-End Dataflow Pipeline

Once your logic is verified, you can scale it up to process millions of rows using the **DataflowRunner**.

### Example 1: Analyzing Popular Names
We will process the entire **USA Names** dataset, filter for popular names in New York, and write the results to a BigQuery table.

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

# --- CONFIGURATION ---
PROJECT_ID = 'your-project-id'
BUCKET_NAME = 'your-gcs-bucket'
OUTPUT_TABLE = f'{PROJECT_ID}:dsongcp.ny_popular_names'
# ---------------------

class FilterNYNames(beam.DoFn):
    def process(self, element):
        if element['state'] == 'NY' and element['number'] > 500:
            yield {
                'name': element['name'],
                'count': element['number'],
                'year': element['year']
            }

def run_names_pipeline():
    options = PipelineOptions(
        project=PROJECT_ID,
        region='us-central1',
        temp_location=f'gs://{BUCKET_NAME}/temp',
        staging_location=f'gs://{BUCKET_NAME}/staging',
        runner='DataflowRunner',
        job_name='ny-names-analysis'
    )

    with beam.Pipeline(options=options) as p:
        (
            p 
            | 'Read from Public BQ' >> beam.io.ReadFromBigQuery(
                table='bigquery-public-data.usa_names.usa_1910_current'
            )
            | 'Process Names' >> beam.ParDo(FilterNYNames())
            | 'Write to Private BQ' >> beam.io.WriteToBigQuery(
                OUTPUT_TABLE,
                schema='name:STRING, count:INTEGER, year:INTEGER',
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
            )
        )

if __name__ == '__main__':
    run_names_pipeline()
```

### Example 2: Analyzing Chicago Taxi Trip Fares
In this example, we calculate the average fare for Chicago taxi trips, grouped by payment type, and save the results as text files in GCS.

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

# --- CONFIGURATION ---
PROJECT_ID = 'your-project-id'
BUCKET_NAME = 'your-gcs-bucket'
OUTPUT_PATH = f'gs://{BUCKET_NAME}/dataflow/taxi_fares'
# ---------------------

def run_taxi_pipeline():
    options = PipelineOptions(
        project=PROJECT_ID,
        region='us-central1',
        temp_location=f'gs://{BUCKET_NAME}/temp',
        staging_location=f'gs://{BUCKET_NAME}/staging',
        runner='DataflowRunner',
        job_name='chicago-taxi-analysis'
    )

    with beam.Pipeline(options=options) as p:
        (
            p
            | 'Read Taxi Data' >> beam.io.ReadFromBigQuery(
                query='SELECT payment_type, fare FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips` WHERE fare > 0 LIMIT 100000',
                use_standard_sql=True
            )
            | 'Pair Payment with Fare' >> beam.Map(lambda x: (x['payment_type'], x['fare']))
            | 'Calculate Avg Per Type' >> beam.CombinePerKey(beam.combiners.MeanCombineFn())
            | 'Format Results' >> beam.Map(lambda x: f"Payment: {x[0]}, Avg Fare: ${x[1]:.2f}")
            | 'Write to GCS' >> beam.io.WriteToText(OUTPUT_PATH)
        )

if __name__ == '__main__':
    run_taxi_pipeline()
```

---

## 4. Monitoring and Management

### Monitoring the Job
1.  Go to the **Dataflow** page in the GCP Console.
2.  Click on your job (`ny-names-analysis`).
3.  **Graph View**: Watch the data flow through each transformation step in real-time.
4.  **Autoscaling**: Observe how Dataflow adds worker VMs as the workload increases and removes them when finished.
5.  **Logs**: Check the "Worker Logs" if you encounter errors during execution.

### Post-Run Cleanup
- **GCS Storage**: The `temp` and `staging` folders in your bucket may contain temporary files. Delete them if they are no longer needed.
- **Worker VMs**: Dataflow automatically shuts down workers once the batch job is finished, so you won't be charged for idle compute.

---

## Summary of the Workflow
1.  **Setup**: Use Vertex AI Workbench for a pre-configured Beam environment.
2.  **Iterate**: Use `DirectRunner` or `InteractiveRunner` with small data samples.
3.  **Scale**: Use `DataflowRunner` to process massive datasets on Google Cloud infrastructure.
