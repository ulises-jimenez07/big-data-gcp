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
- [Dataproc & HDFS](./hadoop/map_reduce_py/01_dataproc_hdfs_tutorial.md): Cluster setup and basic HDFS management.
- [MapReduce Concepts](./hadoop/map_reduce_py/02_mapreduce_tutorial.md): Distributed processing theory and word count logic.
- [Python MapReduce on Dataproc](./hadoop/map_reduce_py/03_run_mapreduce_on_dataproc.md): Running streaming jobs on a live cluster.
- **[MapReduce Challenge](./hadoop/map_reduce_py/04_mapreduce_challenge.md)**: Practice Keyword Analysis using BigQuery public data.

### Hive
- [Hive Tutorial](./hadoop/hive/01_hive_tutorial.md): Managing external/managed tables, partitioning, and ORC optimization.
- **[Hive Challenge](./hadoop/hive/02_hive_challenge.md)**: Urban mobility analysis using BigQuery public data.

## Author
Ulises Jimenez

Last Update: 2026-02-02