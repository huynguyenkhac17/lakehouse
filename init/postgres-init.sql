CREATE DATABASE metastore_db;
CREATE DATABASE superset_db;
CREATE USER hive WITH PASSWORD 'password';
CREATE USER superset WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE metastore_db TO hive;
GRANT ALL PRIVILEGES ON DATABASE superset_db TO superset;