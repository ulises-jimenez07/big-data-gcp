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
### GCS
- [GCS Basics](./gcs/01_gcs_basics.md): Fundamental concepts of Cloud Storage.
- [Storage Classes](./gcs/02_storage_classes.md): Choosing the right class for your data.
- [Lifecycle & Versioning](./gcs/03_lifecycle_versioning.md): Automating data management.
- **[GCS Challenge](./gcs/05_gcs_challenge.md)**: Practice organizing data buckets.

### BigQuery
- [Ingestion Tutorial](./big_query/01_bigquery_ingestion_tutorial.md): Loading data into BQ.
- [SQL Essentials](./big_query/02_bigquery_sql_essentials.md): Best practices for querying.
- [Advanced Analytics](./big_query/04_advanced_analytics.md): Window functions and complex joins.
- [BigQuery ML](./big_query/05_bigquery_ml.md): Building models directly in SQL.
- **[BigQuery Challenge](./big_query/07_bigquery_challenge.md)**: Real-world analysis of NYC taxi data.

### Dataflow & Apache Beam
- [Beam Intro](./dataflow/01_introduction_to_beam_dataflow.md): Core concepts of the unified model.
- [ParDo & DoFn](./dataflow/02_beam_concepts_pardo_dofn.md): Custom transformations in Python.
- [Advanced Beam Patterns](./dataflow/02b_advanced_beam_patterns.md): Branching, Flattening, and Custom Aggregations.
- [Dataflow Notebooks](./dataflow/03_dataflow_notebooks.md): Interactive development in the console.
- [End-to-End Pipeline](./dataflow/04_end_to_end_dataflow_pipeline.md): Complete Dataflow job using public data.
- **[Dataflow Challenge](./dataflow/05_dataflow_challenge.md)**: Crime data analysis challenge.

## Author
Ulises Jimenez

Last Update: 2026-02-03