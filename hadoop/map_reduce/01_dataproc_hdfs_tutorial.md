# Hadoop and HDFS on GCP Dataproc

This guide covers the basic setup of a Hadoop cluster using Google Cloud Dataproc and fundamental HDFS commands.

## 1. Prerequisites (Permissions)

Before creating a cluster, ensure the default Compute Engine service account has permissions to manage storage buckets. If you see "Permissions missing" errors, run this command:

```bash
# Replace [PROJECT_ID] and [PROJECT_NUMBER] with your details
gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:[PROJECT_NUMBER]-compute@developer.gserviceaccount.com" \
    --role="roles/storage.admin"
```

## 2. Creating a Dataproc Cluster

To create a Hadoop cluster in the GCP Console with default values (Master and Worker nodes), follow these steps:

1.  **Go to Dataproc**: In the GCP Console, search for **Dataproc** in the search bar and select **Clusters**.
2.  **Enable API**: If prompted, enable the Dataproc API.
3.  **Create Cluster**: 
    - Click **Create Cluster**.
    - Choose **Cluster on Compute Engine**.
4.  **Configure Cluster**:
    - **Cluster Name**: Give it a name (e.g., `hadoop-cluster`).
    - **Region/Zone**: Choose your preferred region (e.g., `us-central1`).
    - **Cluster Type**: Set to **Standard (1 master, N workers)**. By default, it usually comes with 2 worker nodes.
    - **Components (Recommended for Spark/Jupyter)**: 
        - Click **Component Gateway** and check **Enable component gateway**.
        - Under **Optional components**, click **Add** and select **Jupyter Notebook**.
5.  **Defaults**: Leave all other settings (Machine type, Disk size, etc.) as default.
6.  **Create**: Click the **Create** button. It will take a few minutes to provision the VMs and set up Hadoop.

### Create via gcloud CLI

Alternatively, you can create the same cluster using the `gcloud` command-line tool. **Note:** We are adding Spark-ready options (`enable-component-gateway` and `JUPYTER`) now to avoid recreating the cluster later.

```bash
gcloud dataproc clusters create hadoop-cluster \
    --region=us-central1 \
    --num-workers=2 \
    --master-machine-type=n1-standard-4 \
    --worker-machine-type=n1-standard-4 \
    --image-version=2.1-debian11 \
    --enable-component-gateway \
    --optional-components=JUPYTER
```

*Note: Replace `us-central1` with your desired region. We use `n1-standard-4` to ensure sufficient RAM for Spark and Jupyter later.*

---

## 2. Local File System vs. HDFS

Hadoop uses the **Hadoop Distributed File System (HDFS)** to store large files across multiple machines. Unlike your local Linux file system, HDFS is optimized for high-throughput access to data.

### Comparison
| Feature | Local File System (ext4/NTFS) | HDFS |
| :--- | :--- | :--- |
| **Storage** | Single disk/machine | Distributed across many machines |
| **Redundancy** | None (unless RAID) | Triple replication by default |
| **Access** | Standard OS calls | `hdfs dfs` command-line utility |

---

## 3. Basic HDFS Commands

The following commands demonstrate how to interact with HDFS and Move data between the local environment and the distributed cluster.

### Listing Files
To list the contents of the HDFS root directory:
```bash
hdfs dfs -ls /
```

### Working with Directories
Create a user directory:
```bash
hdfs dfs -mkdir -p /user/example1
```

### Moving Data to HDFS
First, create a local file:
```bash
echo "esto es un ejemplo" > mi_archivo.txt
```
Then, copy it from the local disk to HDFS:
```bash
hdfs dfs -copyFromLocal mi_archivo.txt /user/example1
```

### Listing HDFS Contents
Check if the file arrived:
```bash
hdfs dfs -ls /user/example1
```

### Downloading Data from HDFS
To copy a file back from HDFS to your local system:
```bash
hdfs dfs -get /user/example1/mi_archivo.txt local_copy.txt
```

### Other Relevant Commands
- `hdfs dfs -cat <path>`: View the contents of a small file in HDFS.
- `hdfs dfs -rm <path>`: Delete a file from HDFS.
- `hdfs dfs -du -h <path>`: Check disk usage of a directory in HDFS.
- `hdfs dfs -put <local> <hdfs>`: Similar to `copyFromLocal`.
