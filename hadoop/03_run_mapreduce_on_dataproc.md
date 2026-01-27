# Running MapReduce on GCP Dataproc

This guide details the end-to-end process of testing your scripts locally and then deploying them to a production Hadoop cluster.

## 1. Local Testing and Verification

Before running a job on a cluster, you must verify that your scripts work correctly using standard Linux pipes. This simulates the MapReduce flow (Map -> Sort -> Reduce).

### Get Test Data
Download a book from Project Gutenberg:
```bash
curl -L https://www.gutenberg.org/ebooks/20417.txt.utf-8 -o book.txt
```

### Run Simulation
Set execution permissions and run the local pipe:
```bash
chmod +x wc_mapper.py wc_reducer.py

# Simulate MapReduce:
cat book.txt | ./wc_mapper.py | sort -k1,1 | ./wc_reducer.py | head -n 20
```
*Note: The `sort` command is critical as it mimics the "Shuffle & Sort" phase of Hadoop.*

---

## 2. Preparing Data in HDFS

Once verified, upload your data from the Master node's local disk to HDFS.

```bash
# Create input directory in HDFS
hdfs dfs -mkdir -p /user/inputs

# Upload the file
hdfs dfs -copyFromLocal book.txt /user/inputs/
```

---

## 3. Executing with Hadoop Streaming

Hadoop Streaming allows you to run any executable as a mapper/reducer.

```bash
# Define paths (assuming scripts are in your home directory)
MAPPER_PATH="$HOME/wc_mapper.py"
REDUCER_PATH="$HOME/wc_reducer.py"
INPUT_HDFS="/user/inputs/book.txt"
OUTPUT_HDFS="/user/outputs/wc_result"

# Execute Hadoop Job
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -file $MAPPER_PATH -mapper $MAPPER_PATH \
    -file $REDUCER_PATH -reducer $REDUCER_PATH \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS
```

### Key Arguments:
- `-file`: Uploads the physical script to the Worker nodes.
- `-mapper`: The command to run the Mapper (e.g., `./wc_mapper.py`).
- `-reducer`: The command to run the Reducer (e.g., `./wc_reducer.py`).
- `-input`: source data in HDFS.
- `-output`: destination in HDFS (**must not already exist**).

---

## 4. Verifying Cluster Results

After the job completes successfully, inspect the output in HDFS:

```bash
# List output files (usually part-00000, part-00001, etc.)
hdfs dfs -ls /user/outputs/wc_result

# View top 20 lines of the result
hdfs dfs -cat /user/outputs/wc_result/part-00000 | head -n 20
```
