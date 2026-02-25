# Dataflow Challenge: Solution

Below is one way to solve the Austin Crime Analysis challenge.

## Challenge Solution Code

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

PROJECT_ID = 'your-project-id'
BUCKET_NAME = 'your-gcs-bucket'

def run():
    options = PipelineOptions(
        project=PROJECT_ID,
        region='us-central1',
        temp_location=f'gs://{BUCKET_NAME}/temp',
        runner='DirectRunner' # Start with DirectRunner
    )

    with beam.Pipeline(options=options) as p:
        # 1. & 2. Read and Filter via SQL Query for efficiency
        query = """
            SELECT primary_type 
            FROM `bigquery-public-data.austin_crime.crime` 
            WHERE year = 2015 
            AND UPPER(primary_type) LIKE '%THEFT%'
        """

        (
            p 
            | 'Read from BigQuery' >> beam.io.ReadFromBigQuery(query=query, use_standard_sql=True)
            # 3. Extract type (ReadFromBigQuery returns dicts)
            | 'Extract Type' >> beam.Map(lambda row: row['primary_type'])
            # 4. Count occurrences
            | 'Count Per Type' >> beam.combiners.Count.PerElement()
            # 5. Format for text output: (Type, Count) -> "Type: Count"
            | 'Format String' >> beam.Map(lambda x: f"{x[0]}: {x[1]}")
            # 6. Write to GCS
            | 'Write to GCS' >> beam.io.WriteToText(f'gs://{BUCKET_NAME}/dataflow/output/counts')
        )

if __name__ == '__main__':
    run()
```

---

## Explanation of the Solution

1.  **Filtering with SQL**: While you can filter inside a `DoFn`, using a SQL query in `ReadFromBigQuery` is often better because BigQuery performs the filtering first, and Beam only has to process the relevant rows. This saves network bandwidth and processing time.
2.  **`beam.Map`**: We used a simple lambda to extract the `primary_type` string from the row dictionary.
3.  **`Count.PerElement()`**: This is a built-in transform that takes a `PCollection` of elements and returns a `PCollection` of tuples: `(Element, Count)`.
4.  **Final Formatting**: `WriteToText` expects a collection of strings. We used one last `Map` to turn our data tuples into readable lines.
5.  **Output Files**: Note that Dataflow/Beam often produces multiple output files (shards) like `counts-00000-of-00003`. This is normal for parallel processing!

---

## Best Practices shown here:
- **Minimize Data Move**: Filtering in the source (BigQuery) is faster.
- **Portability**: The logic remains the same whether running locally or on 100 Dataflow workers.
- **Modularity**: Each step is clearly labeled with a unique name (e.g., `'Extract Type'`), which shows up in the Dataflow monitoring UI.
