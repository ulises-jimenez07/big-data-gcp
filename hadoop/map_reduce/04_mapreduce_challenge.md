# MapReduce Practice Challenge: Hacker News Keywords

Now that you've mastered the basic Word Count, it's time to apply your MapReduce skills to a real-world dataset. Your task is to analyze trends in technology and news by processing titles from Hacker News.

## 1. The Dataset
We will use the **Hacker News** public dataset available in BigQuery.

### Preparation
Extract the titles of stories from the last few years into a CSV file in your GCS bucket.

```bash
# Variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-hadoop"

# Extract only the titles to a CSV (using * for sharding)
bq extract --destination_format=CSV \
    bigquery-public-data:hacker_news.full \
    gs://$BUCKET_NAME/hacker_news/titles_*.csv
```
*Note: Make sure you have enough permissions and quota for the extract.*

## 2. Your Mission
Create a MapReduce job (Python Mapper and Reducer) that performs a **Keyword Frequency Analysis** with the following requirements:

### Mapper Requirements (`hn_mapper.py`):
1.  **Clean the data**: Convert all text to lowercase.
2.  **Remove Punctuation**: Strip any non-alphanumeric characters.
3.  **Filter Stop Words**: Do NOT count common words like: `the`, `a`, `an`, `to`, `in`, `of`, `and`, `is`, `for`, `with`, `on`, `at`, `by`, `from`.
4.  **Minimum Length**: Only count words that are at least 3 characters long.
5.  **Output**: Emit key-value pairs in the format: `word\t1`.

### Reducer Requirements (`hn_reducer.py`):
1.  **Aggregate**: Sum the occurrences of each keyword.
2.  **Threshold**: Only output keywords that appear more than **50 times**.

## 3. Execution
1.  Test your scripts locally using a small sample of the data.
2.  Upload the scripts to your Dataproc cluster (or GCS).
3.  Submit the job using Hadoop Streaming.

```bash
# Example Submit Command
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -files hn_mapper.py,hn_reducer.py \
    -mapper "python3 hn_mapper.py" \
    -reducer "python3 hn_reducer.py" \
    -input /user/data/hacker_news/titles_*.csv \
    -output /user/data/hacker_news/keyword_counts
```

## 4. Expected Output
The final output should be a list of significant keywords found in Hacker News titles, such as:
```text
google      1240
python      850
startup     620
ai          1500
...
```