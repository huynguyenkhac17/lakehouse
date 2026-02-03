#!/bin/bash
set -e

SPARK_MASTER_URL=${SPARK_MASTER_URL:-spark://spark-master:7077}
SPARK_WORKER_CORES=${SPARK_WORKER_CORES:-2}
SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-4g}
SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}

echo "=========================================="
echo "Starting Spark Worker Node"
echo "Master URL: $SPARK_MASTER_URL"
echo "Cores: $SPARK_WORKER_CORES"
echo "Memory: $SPARK_WORKER_MEMORY"
echo "WebUI Port: $SPARK_WORKER_WEBUI_PORT"
echo "=========================================="

# Export Spark environment
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Wait for master to be ready
echo "Waiting for Spark Master to be ready..."
max_attempts=30
attempt=0
while ! curl -s http://spark-master:8080 > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "ERROR: Spark Master not available after $max_attempts attempts"
        exit 1
    fi
    echo "Attempt $attempt/$max_attempts - Waiting for Spark Master..."
    sleep 2
done
echo "Spark Master is ready!"

# Start Spark Worker (foreground - keeps container alive)
echo "Starting Spark Worker..."
exec $SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker \
    --cores $SPARK_WORKER_CORES \
    --memory $SPARK_WORKER_MEMORY \
    --webui-port $SPARK_WORKER_WEBUI_PORT \
    $SPARK_MASTER_URL
