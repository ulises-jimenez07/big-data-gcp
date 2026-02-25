# Apache Beam: ParDo, DoFn, and Pipeline Patterns

This guide covers the core concepts of data transformation in Apache Beam, ranging from basic element-wise processing to complex branching and custom aggregations.

---

## 1. Core Concepts: ParDo and DoFn

The most common way to transform data in Apache Beam is using the **ParDo** transform.

### What is ParDo?
**ParDo** stands for "Parallel Do." It is analogous to the "Map" phase of a MapReduce algorithm. You apply a ParDo to a `PCollection`, and it processes every element in that collection independently and potentially in parallel.

Use ParDo for:
- **Filtering**: Selecting elements based on a condition.
- **Formatting**: Changing data structure (e.g., CSV to JSON).
- **Extracting Parts**: Pulling specific fields from a record.
- **Calculations**: Performing math on each element.

### What is a DoFn?
To use `ParDo`, you must provide the logic for how to process each element. This logic is defined in a **DoFn** (Do Function).

**Anatomy of a DoFn in Python:**
```python
import apache_beam as beam

class MyTransform(beam.DoFn):
    def process(self, element):
        # 'element' is a single item from the input PCollection
        # transform to uppercase
        transformed = element.upper()
        
        # You 'yield' the result (allows for 0, 1, or multiple outputs per element)
        yield transformed
```

### Applying ParDo in a Pipeline
In the Beam Python SDK, you apply a `ParDo` using the piping operator (`|`):

```python
# Assuming 'input_data' is a PCollection of strings
upper_data = (
    input_data 
    | 'Convert to Upper' >> beam.ParDo(MyTransform())
)
```

### Map vs. FlatMap (Shorthands)
Beam provides shorthand methods for common ParDo operations:
- `beam.Map`: For 1-to-1 transformations (one input produces exactly one output).
- `beam.FlatMap`: For 1-to-many transformations (one input produces zero or many outputs).

```python
words = (
    lines 
    | 'Split Lines' >> beam.FlatMap(lambda x: x.split(' '))
    | 'Uppercase' >> beam.Map(lambda x: x.upper())
)
```

---

## 2. Advanced Pipeline Patterns

As pipelines grow in complexity, you may need to branch your data flow, merge results, or perform custom aggregations.

### Branching Pipelines
You can apply multiple transforms to the same `PCollection`, effectively "branching" the pipeline.

```python
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

### Flattening: Merging Branches
The `Flatten` transform allows you to merge multiple `PCollection` objects of the same type into a single one.

```python
# Merging the two branches from above
merged_output = (
    (accounts_count, hr_count)
    | beam.Flatten()
    | 'Write Merged' >> beam.io.WriteToText('data/merged_results')
)
```

### Custom Aggregations with `CombineFn`
Standard transforms like `sum` or `max` are simple. If you need something more complex, like an **Average**, you use a `CombineFn`.

A `CombineFn` has four steps:
1. `create_accumulator`: Initialize the state (e.g., `(0.0, 0)` for sum and count).
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
    sums, counts = zip(*accumulators)
    return sum(sums), sum(counts)

  def extract_output(self, sum_count):
    (total_sum, count) = sum_count
    return total_sum / count if count else float('NaN')
```

### Composite Transforms
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

# Usage: accounts_data | 'Process Dept' >> ProcessDepartment()
```

---

## 3. Full Example: Processing Employee Data

In this example, we combine these concepts to process a CSV-like text file.

```python
import apache_beam as beam

# 1. Define custom DoFns
class SplitRow(beam.DoFn):
    def process(self, element):
        # '01,Marco,Accounts,30' -> ['01', 'Marco', 'Accounts', '30']
        return [element.split(',')]

class FilterDept(beam.DoFn):
    def __init__(self, department):
        self.department = department
        
    def process(self, element):
        if element[2] == self.department:
            yield element

# 2. Build and run the pipeline
with beam.Pipeline() as p:
    attendance_count = (
        p
        | 'Read Source' >> beam.io.ReadFromText('dept_data.txt')
        | 'Split' >> beam.ParDo(SplitRow())
        | 'Filter Accounts' >> beam.ParDo(FilterDept('Accounts'))
        | 'Pairing' >> beam.Map(lambda x: (f"{x[2]}, {x[1]}", 1))
        | 'Sum' >> beam.CombinePerKey(sum)
        | 'Write' >> beam.io.WriteToText('data/output_final')
    )
```

In the next tutorial, we will see how to set up a GCP environment to run these pipelines at scale.
