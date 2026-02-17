# Beam Advanced: Branching, Flattening, and Custom Aggregations

As pipelines grow in complexity, you may need to branch your data flow or perform custom aggregations like calculating averages.

## 1. Branching Pipelines

You can apply multiple transforms to the same `PCollection`, effectively "branching" the pipeline.

```python
import apache_beam as beam

with beam.Pipeline() as p:
    input_collection = ( 
        p 
        | "Read Source" >> beam.io.ReadFromText('dept_data.txt')
        | "Split Rows" >> beam.Map(lambda x: x.split(','))
    )

    # Branch 1: Accounts Department
    accounts_count = (
        input_collection
        | 'Filter Accounts' >> beam.Filter(lambda x: x[3] == 'Accounts')
        | 'Pair Accounts' >> beam.Map(lambda x: ("Accounts, " + x[1], 1))
        | 'Sum Accounts' >> beam.CombinePerKey(sum)
    )

    # Branch 2: HR Department
    hr_count = (
        input_collection
        | 'Filter HR' >> beam.Filter(lambda x: x[3] == 'HR')
        | 'Pair HR' >> beam.Map(lambda x: ("HR, " + x[1], 1))
        | 'Sum HR' >> beam.CombinePerKey(sum)
    )
```

---

## 2. Flattening: Merging Branches

The `Flatten` transform allows you to merge multiple `PCollection` objects of the same type into a single one.

```python
    # Merging the two branches from above
    merged_output = (
        (accounts_count, hr_count)
        | beam.Flatten()
        | 'Write Merged' >> beam.io.WriteToText('data/merged_results')
    )
```

---

## 3. Custom Accumulators with `CombineFn`

Standard transforms like `sum` or `max` are simple. If you need something more complex, like an **Average**, you use a `CombineFn`.

A `CombineFn` has four steps:
1. `create_accumulator`: Initialize the state (e.g., `(total_sum, count)`).
2. `add_input`: Update the state for each new element.
3. `merge_accumulators`: Merge multiple states (crucial for parallel processing).
4. `extract_output`: Perform the final calculation.

```python
class AverageFn(beam.CombineFn):
  def create_accumulator(self):
    return (0.0, 0)   # (sum, count)

  def add_input(self, sum_count, input):
    (total_sum, count) = sum_count
    return total_sum + input, count + 1

  def merge_accumulators(self, accumulators):
    # merges partial results from different workers
    sums, counts = zip(*accumulators)
    return sum(sums), sum(counts)

  def extract_output(self, sum_count):
    (total_sum, count) = sum_count
    return total_sum / count if count else float('NaN')

# Usage:
# p | beam.Create([10, 20, 30]) | beam.CombineGlobally(AverageFn())
```

---

## 4. Composite Transforms

A **Composite Transform** allows you to group multiple steps into a single reusable component by subclassing `beam.PTransform`.

```python
class ProcessDepartment(beam.PTransform):
  def expand(self, input_coll):
    return (
        input_coll
        | 'Combine' >> beam.CombinePerKey(sum)
        | 'Filter High Performers' >> beam.Filter(lambda x: x[1] > 30)
        | 'Format' >> beam.Map(lambda x: f"{x[0]}: {x[1]} records")
    )

# Usage in pipeline:
# accounts_data | 'Process Dept' >> ProcessDepartment()
```
