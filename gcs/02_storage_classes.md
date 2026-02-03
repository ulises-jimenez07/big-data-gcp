# GCS: Storage Classes Explained

GCS offers different storage classes to help you optimize cost based on how frequently you access your data.

## 1. Comparing Storage Classes

| Storage Class | Use Case | Min Duration | Availability |
| :--- | :--- | :--- | :--- |
| **Standard** | Frequent access, website assets, active data. | None | > 99.9% |
| **Nearline** | Accessed < once a month. Backups, long-tail content. | 30 days | > 99.0% |
| **Coldline** | Accessed < once a quarter. Disaster recovery. | 90 days | > 99.0% |
| **Archive** | Accessed < once a year. Long-term compliance. | 365 days | > 99.0% |

---

## 2. Setting a Storage Class

### During Creation
```bash
# Create a Nearline bucket
gsutil mb -c nearline -l us-central1 gs://my-backup-bucket/
```

### Changing an Existing Object
You can change the storage class of an individual object by "rewriting" it.

```bash
gsutil rewrite -s coldline gs://my-bucket/old_file.txt
```

---

## 3. Cost Implications
- **Storage Cost**: Standard is most expensive; Archive is cheapest.
- **Retrieval Cost**: Standard has no retrieval fees; Archive has the highest retrieval fees.
- **Minimum Duration**: If you delete a "Coldline" file after 10 days, you still pay for 90 days of storage.

### Pro Tip: Autoclass
GCS has a feature called **Autoclass** that automatically moves objects to colder storage classes based on access patterns, and moves them back to Standard when accessed.

```bash
# Enable Autoclass during creation
gcloud storage buckets create gs://my-smart-bucket/ --enable-autoclass
```
