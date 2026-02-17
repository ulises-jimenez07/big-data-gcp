# End-to-End Dataflow Pipeline

In this tutorial, we will build a complete pipeline that reads data from a **BigQuery Public Dataset**, processes it using a `DoFn`, and writes the result to another BigQuery table.

## 1. The Scenario

We want to analyze the **USA Names** public dataset. Our pipeline will:
1.  Read the names from `bigquery-public-data.usa_names.usa_1910_current`.
2.  Filter for names that occurred more than 500 times in the state of **New York (NY)**.
3.  Calculate the total number of people with those names.
4.  Write the output to a new table in your project.

---

## 2. Complete Code Example

Copy this code into a cell in your Jupyter notebook or a `.py` file.

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

# Configuration
PROJECT_ID = 'your-project-id'  # REPLACE THIS
BUCKET_NAME = 'your-gcs-bucket' # REPLACE THIS
DATASET_ID = 'dsongcp'         # Dataset we created earlier

# 1. Define a DoFn for filtering
class FilterNYNames(beam.DoFn):
    def process(self, element):
        # We only want names from NY with count > 500
        if element['state'] == 'NY' and element['number'] > 500:
            yield {
                'name': element['name'],
                'count': element['number'],
                'year': element['year']
            }

def run_pipeline():
    # 2. Pipeline Options
    options = PipelineOptions(
        project=PROJECT_ID,
        region='us-central1',
        temp_location=f'gs://{BUCKET_NAME}/temp',
        staging_location=f'gs://{BUCKET_NAME}/staging',
        runner='DataflowRunner'  # Change to 'DirectRunner' for local testing
    )

    # 3. Build the Pipeline
    with beam.Pipeline(options=options) as p:
        (
            p 
            | 'Read from BigQuery' >> beam.io.ReadFromBigQuery(
                table='bigquery-public-data.usa_names.usa_1910_current'
            )
            | 'Filter NY Names' >> beam.ParDo(FilterNYNames())
            | 'Write to BigQuery' >> beam.io.WriteToBigQuery(
                f'{PROJECT_ID}:{DATASET_ID}.ny_popular_names',
                schema='name:STRING, count:INTEGER, year:INTEGER',
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
            )
        )

if __name__ == '__main__':
    run_pipeline()
```

---

## 3. Explaining the Pipeline

### A. `ReadFromBigQuery`
This step queries the public dataset. It returns a `PCollection` of Python dictionaries, where keys are column names and values are the row data.

### B. `beam.ParDo(FilterNYNames())`
This is where our customized logic resides. The `FilterNYNames` class is applied to every row. If the condition is met, it `yields` a new dictionary; otherwise, it yields nothing (effectively filtering out the row).

### C. `WriteToBigQuery`
This step takes the processed `PCollection` and writes it to a table in your private project. 
- `WRITE_TRUNCATE`: Overwrites the table if it exists.
- `CREATE_IF_NEEDED`: Automatically creates the table schema if it doesn't exist.

---

## 4. Running the Pipeline

1.  **DirectRunner**: Set `runner='DirectRunner'` to run the job locally in your notebook. This is fast and uses your notebook's resources.
2.  **DataflowRunner**: Set `runner='DataflowRunner'` and run the script. 
    - Go to the **Dataflow** page in the GCP Console.
    - You will see a new job starting.
    - Click on the job to see the interactive Graph UI.
    - Observe how Dataflow automatically provisions workers to handle the data.

---

## 5. Cleaning Up

Dataflow jobs (Batch) stop automatically once they finish. However, you should check your GCS bucket (`temp/` and `staging/` folders) and delete files if they are no longer needed to avoid storage costs.
