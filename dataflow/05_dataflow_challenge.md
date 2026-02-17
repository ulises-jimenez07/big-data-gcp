# Dataflow Challenge: Austin Crime Analysis

Now that you have learned the basics of Apache Beam and Dataflow, it's time to put your skills to the test.

## The Goal

We will use the **Austin Crime** public dataset to find the standard "Crime Rate" for different types of theft in a specific year.

### The Dataset
`bigquery-public-data.austin_crime.crime`

---

## 1. The Requirements

Create a Dataflow Pipeline that performs the following steps:

1.  **Read** from the BigQuery table `bigquery-public-data.austin_crime.crime`.
2.  **Filter** for crimes that:
    - Happened in the year `2015`.
    - Have a `primary_type` involving the word **"THEFT"** (Case-insensitive).
3.  **Transform**: Extract only the `primary_type` and the `description`.
4.  **Count**: Use a Beam transform (like `beam.combiners.Count.PerElement()`) to find how many times each `primary_type` occurred.
5.  **Write** the results to a text file in GCS (`gs://your-bucket/dataflow/output/counts.txt`).

---

## 2. Tips

- Use `beam.io.ReadFromBigQuery(query='SELECT ... FROM ...')` if you want to filter with SQL before it even hits Beam.
- Use `beam.io.WriteToText()` for the final output.
- Remember that `Count.PerElement()` returns a tuple of `(element, count)`. You might need a final `Map` to format that tuple as a string before writing to text.

---

## 3. Submission Checklist

- [ ] Does the pipeline run without errors on `DirectRunner`?
- [ ] Did you successfully submit a job to the `DataflowRunner`?
- [ ] Can you see the output file in your GCS bucket?

Good luck! The answers are available in the next tutorial file.
