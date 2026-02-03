# GCS: Lifecycle and Versioning

Manage the lifespan of your data and protect against accidental deletions using Object Versioning and Lifecycle Management rules.

## 1. Object Versioning

Object Versioning allows you to keep a history of every change made to a file. When enabled, overwriting or deleting an object creates a "non-current" version rather than deleting it permanently.

### Enable Versioning
```bash
gsutil versioning set on gs://my-bucket/
```

### Visualizing Versions (The Example)
When you enable versioning, GCS assigns a **Generation Number** to every version of a file.

If you upload `readme.txt` three times, GCS stores them like this:

```text
gs://my-bucket/readme.txt#1691234567890123  (Oldest version)
gs://my-bucket/readme.txt#1691234578901234  (Middle version)
gs://my-bucket/readme.txt#1691234599999999  (Current Live version)
```

To see this in your terminal, use the `-a` (all) flag:

```bash
gsutil ls -a gs://my-bucket/readme.txt
```

**Output Example:**
```bash
gs://my-bucket/readme.txt#1691234567890123
gs://my-bucket/readme.txt#1691234578901234
gs://my-bucket/readme.txt#1691234599999999
```

### Restoring an Older Version
If you accidentally deleted the current version, you can "restore" an old one by copying it over the current name:

```bash
gsutil cp gs://my-bucket/readme.txt#1691234567890123 gs://my-bucket/readme.txt
```

---

## 2. Lifecycle Management

Lifecycle rules allow you to automate tasks like deleting old files or moving them to cheaper storage classes based on conditions (age, number of versions, etc.).

### Common Use Cases
1.  **Delete files** older than 365 days.
2.  **Downgrade to Nearline** after 30 days of no access.
3.  **Keep only 3 versions** of a file and delete older ones.

### Configuring Lifecycle (JSON)
Create a file named `lifecycle.json`:

```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 30}
      }
    ]
  }
}
```

### Apply the Lifecycle Rule
```bash
gsutil lifecycle set lifecycle.json gs://my-bucket/
```

### View Current Rules
```bash
gsutil lifecycle get gs://my-bucket/
```
