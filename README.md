# Big Data on Google Cloud Platform

This repository contains notes, tutorials, and code for working with Big Data technologies on GCP, covering Cloud Infrastructure, Hadoop, and Hive.

## Tech Stack

- **Cloud**: GCP (Compute Engine, Dataproc, GCS)
- **SQL**: MariaDB, Hive, BigQuery
- **Processing**: Hadoop (HDFS, MapReduce)
- **Languages**: SQL and Python

## Project Structure

The repository is organized by technology:

### Intro to Cloud
- [GCP and MariaDB Setup](./intro_cloud/01_gcp_mariadb_setup.md): Project creation, VM setup, and MariaDB installation.
- [Employee DB Queries](./intro_cloud/02_employees_db_queries.md): SQL exercises and database maintenance.

### Hadoop & MapReduce
- [Dataproc & HDFS](./hadoop/map_reduce/01_dataproc_hdfs_tutorial.md): Cluster setup and basic HDFS management.
- [MapReduce Concepts](./hadoop/map_reduce/02_mapreduce_tutorial.md): Distributed processing theory and word count logic.
- [Python MapReduce on Dataproc](./hadoop/map_reduce/03_run_mapreduce_on_dataproc.md): Running streaming jobs on a live cluster.
- **[MapReduce Challenge](./hadoop/map_reduce/04_mapreduce_challenge.md)**: Practice Keyword Analysis using BigQuery public data.

### Hive
- [Hive Tutorial](./hadoop/hive/01_hive_tutorial.md): Managing external/managed tables, partitioning, and ORC optimization.
- **[Hive Challenge](./hadoop/hive/02_hive_challenge.md)**: Urban mobility analysis using BigQuery public data.

### Spark
- [Spark Cluster Setup](./hadoop/spark/01_spark_cluster_setup.md): Optimization for Spark/Jupyter on Dataproc.
- [Spark and Hive/BigQuery](./hadoop/spark/03_spark_and_hive.md): Using Spark as a bridge between storage layers.
- [ML Regression](./hadoop/spark/04_spark_ml_regression.md): Building predictive models with Chicago Taxi data.
- [Complex Data](./hadoop/spark/05_spark_complex_data.md): Handling Arrays and Structs from GitHub.
- [Recommendation Systems](./hadoop/spark/06_spark_recommender.md): Collaborative Filtering with Stack Overflow data.
- **[Final Spark Challenge](./hadoop/spark/07_spark_challenge.md)**: Complete analysis using Hacker News data.

## Author
Ulises Jimenez

Last Update: 2026-02-03