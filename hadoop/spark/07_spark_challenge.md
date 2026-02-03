# Spark Final Challenge

Your mission is to perform a full Big Data analysis and predictive task using a BigQuery public dataset.

## The Objective
Analyze the **Hacker News** public dataset to predict whether a story will be popular based on its length and other features, then build a clustering model to group similar stories.

## Step 1: Data Acquisition
Read the `bigquery-public-data.hacker_news.stories` table into a Spark DataFrame.

## Step 2: Feature Engineering
1.  Filter for rows where `score` and `title` are not null.
2.  Create a column `title_length` based on the character count of the title.
3.  Create a label `is_popular`: 1 if `score > 50`, else 0.
4.  Handle missing values for `author` or `text` (if any) or just drop rows with nulls in critical columns.

## Step 3: Predictive Modeling (Regression/Classification)
Using a **Pipeline**:
1.  Assemble `title_length` and other numerical columns you find useful.
2.  Train a **Linear Regression** model to predict the `score`.
3.  Evaluate using **RMSE**.

## Step 4: Clustering
1.  Using the same features (and perhaps more, like `num_comments`), perform a **K-Means clustering** with $k=3$.
2.  Assign each story to a cluster ID.
3.  Summarize each cluster by calculating the average `score` and `num_comments` for each.

## Step 5: Save your Results
Save the summarized clusters into a new BigQuery table in your own project.

---

**Good luck!** Remember to use the Spark UI to monitor your jobs.
