# Google Cloud Storage (GCS): Basics and Bucket Creation

Google Cloud Storage is a RESTful online file storage web service for storing and accessing data on Google Cloud Platform infrastructure. It is an object storage service, meaning you store files (objects) in containers (buckets).

## 1. Core Concepts
- **Buckets**: Containers that hold your data. Every object in GCS must reside in a bucket.
- **Objects**: The individual pieces of data you store (files, images, etc.).
- **Global Namespace**: Bucket names must be unique across the entire Google Cloud ecosystem.

---

## 2. Creating a Bucket

You can create a bucket using the GCP Console, the `gsutil` tool, or the `gcloud` CLI.

### Option A: GCP Console
1.  Go to the **Cloud Storage** > **Buckets** page in the GCP Console.
2.  Click **Create**.
3.  **Name your bucket**: Pick a globally unique name (e.g., `my-unique-data-bucket-123`).
4.  **Location type**: Choose between Multi-region, Dual-region, or Region.
5.  **Storage class**: Choose **Standard** for frequent access.
6.  **Access control**: Choose **Uniform** (recommended for most use cases).
7.  Click **Create**.

### Option B: `gsutil` (Legacy but common)
The `gsutil` command is specifically designed for storage operations.

```bash
# Create a bucket in a specific region
gsutil mb -l us-central1 gs://my-unique-bucket-name/
```

### Option C: `gcloud storage` (Next-gen)
Google is moving towards `gcloud storage` for better performance.

```bash
# Create a bucket
gcloud storage buckets create gs://my-unique-bucket-name/ --location=us-central1
```

---

## 3. Adding Files to your Bucket

You can upload files or entire folders to GCS.

### Option A: GCP Console (Drag & Drop)
1.  Open your bucket in the Console.
2.  **Upload Files**: Click the **Upload Files** button OR simply drag files from your computer and drop them into the browser window.
3.  **Upload Folder**: Click the **Upload Folder** button to maintain the local directory structure.

### Option B: The CLI (`gsutil` or `gcloud`)
The command line is much faster for large batches of files.

```bash
# Upload a single file
gsutil cp my_data.csv gs://my-unique-bucket-name/

# Upload an entire directory (recursively)
gsutil cp -r ./my_folder gs://my-unique-bucket-name/

# Using the next-gen gcloud storage (parallel uploads for speed)
gcloud storage cp *.png gs://my-unique-bucket-name/images/
```

---

## 4. Basic Operations

### Listing Contents
To see what's inside:
```bash
gsutil ls gs://my-unique-bucket-name/
```

### Downloading a File
```bash
gsutil cp gs://my-unique-bucket-name/my_data.csv ./local_destination/
```

### Deleting an Object
```bash
gsutil rm gs://my-unique-bucket-name/my_data.csv
```
