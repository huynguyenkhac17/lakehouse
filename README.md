# Fullstack Open-source Lakehouse Platform

This is a docker compose environment to quickly get up and running with a Spark environment with a local REST catalog, and MinIO as a storage backend, also provided full ETL python-script then visualization 'E-commerces event history' data with Spark-thrift-sever, Clickhouse and Apache Superset.

**note**: If you don't have docker installed, you can head over to the [Get Docker](http://docs.docker.com/get-started/get-docker/) page for installation instructions.

# Data

This repository uses the “eCommerce Events History in Cosmetics Shop” dataset to demonstrate ETL scripts and data visualization. The dataset can be downloaded from Kaggle via this [link](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop).

# Usage

## Start up the system

Clone this repo by running the following:
```
git clone https://github.com/huynguyenkhac17/lakehouse
cd lakehouse
```
  
Start up the system:
```
docker compose up -d
```

**note**: If this is not the first time you are running the system, make sure to run the following commands before executing the command above:
```
docker compose down -v
rm -rf ./minio/data/*
```

While the notebook server is running, you can use any of the following commands if you prefer to use spark-shell, spark-sql, or pyspark.
```
docker exec -it spark-iceberg spark-shell
```
```
docker exec -it spark-iceberg spark-sql
```
```
docker exec -it spark-iceberg pyspark
```
To stop everything, just run `docker compose down -v`

## Run ETL script

After the system started, jupyter notebook server will then be available at http://localhost:8888

The complete ETL pipeline (Python) is implemented in `lakehouse_complete.ipynb`. Execute the notebook sequentially, running cells from top to bottom.

## Run dbt transformations

```
# Vào container dbt
docker exec -it lakehouse-dbt bash

# Navigate tới project
cd /usr/app/dbt/lakehouse_dbt

# Test connection
dbt debug

# Chạy models
dbt run
```

dbt models are located in:
- `/dbt/lakehouse_dbt/models/silver/` - Silver layer transformations
- `/dbt/lakehouse_dbt/models/gold/` - Gold layer aggregations

## Visualization

Superset is running at http://localhost:8088. Log in using `admin/admin`, then create a database connection and a dataset to build your dashboard.

---

This project is our team’s submission for the DataFlow 2026 contest in the “Fullstack Open-Source Lakehouse Platform” category.

Contest website: [HAMIC - Dataflow 2026](https://dataflow.hamictoantin.com/vi)
