# Beam Concepts: ParDo and DoFn

The most common way to transform data in Apache Beam is using the **ParDo** transform. ParDo is a Beam transform for generic parallel processing.

## 1. What is ParDo?

**ParDo** stands for "Parallel Do." It is analogous to the "Map" phase of a MapReduce algorithm. You apply a ParDo to a `PCollection`, and it processes every element in that collection independently and potentially in parallel.

Use ParDo for:
- **Filtering**: Selecting elements from a collection based on a condition.
- **Formatting**: Changing the structure or type of your data (e.g., converting a CSV string to a JSON object).
- **Extracting Parts**: Pulling specific fields from a complex record.
- **Calculations**: Performing math on each element.

---

## 2. What is a DoFn?

To use `ParDo`, you must provide the logic for how to process each element. This logic is defined in a **DoFn** (Do Function). 

A `DoFn` is a specialized Beam class that defines a distributed processing function. When you apply `ParDo`, the runner takes your `DoFn` and executes its logic on the elements of the input `PCollection`.

### Anatomy of a DoFn in Python

```python
import apache_beam as beam

class MyTransform(beam.DoFn):
    def process(self, element):
        # Your logic goes here
        # 'element' is a single item from the input PCollection
        
        # Example: transform to uppercase
        transformed = element.upper()
        
        # You 'yield' the result (allows for 0, 1, or multiple outputs per element)
        yield transformed
```

---

## 3. Applying ParDo in a Pipeline

In the Beam Python SDK, you typically apply a `ParDo` using the piping operator (`|`):

```python
# Assuming 'input_data' is a PCollection of strings
upper_data = (
    input_data 
    | 'Convert to Upper' >> beam.ParDo(MyTransform())
)
```

### Map vs. FlatMap
Beam also provides shorthand methods for common ParDo operations:
- `beam.Map`: For 1-to-1 transformations (one input produces exactly one output).
- `beam.FlatMap`: For 1-to-many transformations (one input produces zero or many outputs).

Example using `beam.Map` with a lambda function:

```python
words = (
    lines 
    | 'Split Lines' >> beam.FlatMap(lambda x: x.split(' '))
    | 'Uppercase' >> beam.Map(lambda x: x.upper())
)
```

---

---

## 5. Full ParDo Example: Employee Attendance

In this example, we process a CSV-like text file of employee department data. We split each row, filter for a specific department, and count the occurrences.

```python
import apache_beam as beam

# 1. Define custom DoFns
class SplitRow(beam.DoFn):
    def process(self, element):
        # element: '01,Marco,Accounts,30'
        # returns a list containing one list (the split row)
        return [element.split(',')]

class FilterDept(beam.DoFn):
    def __init__(self, department):
        self.department = department
        
    def process(self, element):
        # element is a list: ['01', 'Marco', 'Accounts', '30']
        if element[2] == self.department:
            yield element

class PairEmployees(beam.DoFn):
    def process(self, element):
        # Input: ['01', 'Marco', 'Accounts', '30']
        # Output: ('Accounts, Marco', 1)
        yield (f"{element[2]}, {element[1]}", 1)

# 2. Build and run the pipeline
with beam.Pipeline() as p1:
    attendance_count = (
        p1
        | 'Read Source' >> beam.io.ReadFromText('dept_data.txt')
        | 'Split' >> beam.ParDo(SplitRow())
        | 'Filter Accounts' >> beam.ParDo(FilterDept('Accounts'))
        | 'Pairing' >> beam.ParDo(PairEmployees())
        | 'Group' >> beam.GroupByKey()
        | 'Sum' >> beam.Map(lambda x: (x[0], sum(x[1])))
        | 'Write' >> beam.io.WriteToText('data/output_final')
    )
```

In the next tutorial, we will see how to set up an environment in GCP to run these pipelines.
