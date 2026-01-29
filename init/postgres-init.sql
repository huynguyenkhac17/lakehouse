-- PostgreSQL Init Script for Lakehouse
-- This database is used by:
-- 1. Iceberg REST Catalog (iceberg_catalog - default DB)
-- 2. Apache Superset (superset)

-- Create Superset database
CREATE DATABASE superset;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE superset TO admin;
GRANT ALL PRIVILEGES ON DATABASE iceberg_catalog TO admin;
