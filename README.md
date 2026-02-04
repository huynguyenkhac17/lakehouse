# Fullstack Open-source Lakehouse Platform
`Hướng dẫn dành riêng cho BTC/BGK DataFlow 2026. Hãy và chỉ thực hiện theo các hướng dẫn bên dưới.`

## Hướng dẫn chạy hệ thống
- Hệ thống yêu cầu tối thiểu 7GB RAM trống và 14GB ổ đĩa (lớn nếu trên file system xfs) để có thể chạy. Trong quá trình chạy spark hãy đảm bảo số lượng cpu rảnh (khuyến nghị ~ 8).
- Đảm bảo tối thiểu các cổng 8080, 8088, 8888, 9001 đều đang trống.

1. Clone repo về máy local
```
git clone https://github.com/huynguyenkhac17/lakehouse
cd lakehouse
```
2. Khởi chạy hệ thống
Đảm bảo dung lượng mạng trong quá trình tải các images ~ 8.5GB, thời gian chờ phụ thuộc vào tốc độ mạng.
```
docker compose up -d
```
3. Kiểm tra hệ thống
Hệ thống cần 1 khoảng thời gian nhất định để thực sự hoạt động sau khi build xong, nếu dùng Docker Desktop, BGK có thể vào xem logs qua phần mềm.
Hoặc xem logs trực tiếp bằng lệnh:
```
docker logs -f lakehouse-superset
```

Container lakehouse-superset sẽ được chạy cuối cùng, nếu thấy thông báo kiểu này tức là hệ thống đã hoạt động đầy đủ:
```
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8088
 * Running on http://172.18.0.5:8088
2026-02-04 09:06:16,328:INFO:werkzeug:Press CTRL+C to quit
2026-02-04 09:06:27,153:INFO:werkzeug:127.0.0.1 - - [04/Feb/2026 09:06:27] "GET /health HTTP/1.1" 200 -
2026-02-04 09:06:57,211:INFO:werkzeug:127.0.0.1 - - [04/Feb/2026 09:06:57] "GET /health HTTP/1.1" 200 -
```

## Hướng dẫn chạy quy trình ETL

Truy cập địa chỉ http://localhost:8888, chạy

## Data

Bộ dữ liệu [“eCommerce Events History in Cosmetics Shop” dataset](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop).

Giải nén dữ liệu và để trong thư mục ./notebooks (lưu ý không đổi tên)

# Fullstack Open-source Lakehouse Platform

This is a docker compose environment to quickly get up and running with a Spark environment with a local REST catalog, and MinIO as a storage backend, also provided full ETL python-script then visualization 'E-commerces event history' data with Spark-thrift-sever, Clickhouse and Apache Superset.

**note**: If you don't have docker installed, you can head over to the [Get Docker](http://docs.docker.com/get-started/get-docker/) page for installation instructions.

# Data

This repository uses the [“eCommerce Events History in Cosmetics Shop” dataset](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop) to demonstrate ETL scripts and data visualization. The dataset can be downloaded from Kaggle.

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

The complete ETL pipeline (Python) is implemented in `ETL_full_script.ipynb`. Execute the notebook sequentially, running cells from top to bottom.

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
