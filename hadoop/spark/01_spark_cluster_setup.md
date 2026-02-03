# Setting up a Spark Cluster on GCP Dataproc

This guide explains how to create a Dataproc cluster optimized for Spark development. 

## 1. Do you already have a cluster?

If you followed the **[Hadoop Tutorial](../map_reduce/01_dataproc_hdfs_tutorial.md)** and enabled the **Component Gateway** and **Jupyter**, you are already set up! Spark is included by default in all Dataproc clusters.

If you don't have a cluster yet, or want to create a new one specifically for Spark, follow the instructions below.

## 2. Creating a Spark Cluster via GCP Console

1.  **Navigate to Dataproc**: Search for **Dataproc** and select **Clusters**.
2.  **Create Cluster**: Click **Create Cluster** and select **Cluster on Compute Engine**.
3.  **Set Up Cluster**:
    - **Name**: `spark-cluster` (or your choice).
    - **Region/Zone**: Select your preferred region (e.g., `us-central1`).
    - **Cluster Type**: **Standard (1 master, N workers)**.
4.  **Configure Components (CRITICAL)**:
    - Under **Components**, find **Component Gateway** and check **Enable component gateway**. This allows you to access web UIs (Spark History Server, Jupyter) securely.
    - Under **Optional components**, click **Add** and select:
        - **Jupyter Notebook**
        - **Docker** (optional but useful)
5.  **Nodes Configuration**:
    - Master and Worker nodes: Default (`n1-standard-4` is recommended for Spark ML tasks to avoid memory issues).
6.  **Create**: Click **Create**.

## 2. Creating a Spark Cluster via gcloud CLI

Using the CLI is often faster and more reproducible. The following command enables the **Component Gateway** and installs **Jupyter**.

```bash
gcloud dataproc clusters create spark-cluster \
    --region=us-central1 \
    --image-version=2.1-debian11 \
    --master-machine-type=n1-standard-4 \
    --worker-machine-type=n1-standard-4 \
    --num-workers=2 \
    --enable-component-gateway \
    --optional-components=JUPYTER
```

*Note: The `--enable-component-gateway` flag is what allows us to access the Jupyter and Spark web interfaces without complex SSH tunneling.*

## 3. Accessing Web Interfaces

Once the cluster is "Running":
1.  Click on the cluster name (`spark-cluster`).
2.  Navigate to the **Web Interfaces** tab.
3.  You will see links for:
    - **Jupyter**: To start writing Spark code in notebooks.
    - **Spark History Server**: To monitor completed Spark jobs.
    - **Yarn ResourceManager**: To see cluster resource allocation.
    - **HDFS NameNode**: To browse the distributed file system.

## 4. Verification

Open the **Jupyter** link, create a new notebook with the **PySpark** kernel, and run:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Verification") \
    .getOrCreate()

print(f"Spark version: {spark.version}")
```

If it prints the Spark version (e.g., `3.3.2`), your cluster is ready!
