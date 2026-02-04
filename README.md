# Fullstack Open-source Lakehouse Platform

`Hướng dẫn dành riêng cho BTC/BGK DataFlow 2026. Hãy và chỉ thực hiện theo các hướng dẫn bên dưới.`

## Yêu cầu hệ thống

- Docker & Docker Compose
- Tối thiểu **7GB RAM** trống và **14GB ổ đĩa**
- Khuyến nghị **8 CPU cores** để chạy Spark
- Các cổng sau phải trống: `8080`, `8088`, `8888`, `9001`

## Hướng dẫn chạy hệ thống

### 1. Clone repo về máy local

```bash
git clone https://github.com/huynguyenkhac17/lakehouse
cd lakehouse
```

### 2. Cấu hình biến môi trường

Copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

> **Lưu ý:** Có thể chỉnh sửa các giá trị trong file `.env` nếu cần thiết (ví dụ: thay đổi mật khẩu, ports,...). Với mục đích demo, giữ nguyên giá trị mặc định là đủ.

### 3. Khởi chạy hệ thống

Đảm bảo dung lượng mạng trong quá trình tải các images ~ 8.5GB, thời gian chờ phụ thuộc vào tốc độ mạng.

```bash
docker compose up -d
```

### 4. Kiểm tra hệ thống

Hệ thống cần 1 khoảng thời gian nhất định để thực sự hoạt động sau khi build xong. Xem logs để đảm bảo hệ thống đã hoạt động:

```bash
docker compose logs -f lakehouse-superset
```

Khi thấy thông báo sau tức là hệ thống đã sẵn sàng:

```
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8088
```

### 5. Truy cập các services

| Service | URL | Credentials |
|---------|-----|-------------|
| Jupyter Lab | http://localhost:8888 | Không cần đăng nhập |
| Spark Master UI | http://localhost:8080 | - |
| MinIO Console | http://localhost:9001 | admin / password |
| Apache Superset | http://localhost:8088 | admin / admin |
| ClickHouse HTTP | http://localhost:8123 | admin / password |

## Data

Bộ dữ liệu [eCommerce Events History in Cosmetics Shop](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop) từ Kaggle.

Giải nén và đặt các file CSV vào thư mục `./notebooks/` (giữ nguyên tên file).

## Hướng dẫn chạy quy trình ETL

1. Truy cập Jupyter Lab: http://localhost:8888
2. Mở notebook `lakehouse_test.ipynb`
3. Chạy các cells từ trên xuống dưới theo thứ tự

Notebook sẽ thực hiện:
- **Bronze layer**: Đọc CSV và ghi raw data
- **Silver layer**: Clean và transform data
- **Gold layer**: Tạo các bảng aggregation
- **ClickHouse**: Tạo tables và load data từ MinIO
- **Superset**: Tạo datasource kết nối ClickHouse

## Chạy dbt transformations

```bash
# Vào container dbt
docker exec -it lakehouse-dbt bash

# Test connection
dbt debug

# Chạy models
dbt run
```

dbt models nằm tại:
- `dbt/lakehouse_dbt/models/silver/` - Silver layer transformations
- `dbt/lakehouse_dbt/models/gold/` - Gold layer aggregations

## Reset hệ thống

Nếu muốn xóa toàn bộ dữ liệu và bắt đầu lại:

```bash
docker compose down -v
docker compose up -d
```

## Cấu trúc thư mục

```
lakehouse/
├── .env.example          # Template biến môi trường
├── .env                  # Biến môi trường (nên tạo từ .env.example)
├── docker-compose.yml    # Docker services configuration
├── notebooks/            # Jupyter notebooks & data files
├── spark/                # Spark configuration
│   ├── conf/
│   │   └── spark-defaults.conf
│   ├── entrypoint-master.sh
│   └── entrypoint-worker.sh
├── dbt/                  # dbt project
├── clickhouse/           # ClickHouse configuration
└── init/                 # Database initialization scripts
```

---

This project is our team's submission for the DataFlow 2026 contest in the "Fullstack Open-Source Lakehouse Platform" category.

Contest website: [HAMIC - Dataflow 2026](https://dataflow.hamictoantin.com/vi)
