#!/bin/bash
# set -e

echo "=========================================="
echo "Starting Spark Master Node"
echo "=========================================="

# Export Spark environment
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Start Spark Master daemon in background
echo "[1/3] Starting Spark Master daemon on port 7077..."
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master \
    --host spark-master \
    --port 7077 \
    --webui-port 8080 &

# Wait for master to be ready
echo "Waiting for Spark Master to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "Spark Master is ready!"
        break
    fi
    echo "Attempt $i/30: Waiting for Spark Master..."
    sleep 2
done

# Start Thrift Server for dbt connections in background
# IMPORTANT: Limit Thrift Server resources to leave room for Jupyter notebooks
# NOTE: Use --total-executor-cores for Standalone mode (--num-executors only works with YARN)
echo "[2/3] Starting Spark Thrift Server on port 10000..."
$SPARK_HOME/sbin/start-thriftserver.sh \
    --master spark://spark-master:7077 \
    --driver-memory 512m \
    --executor-memory 1g \
    --total-executor-cores 2 \
    --conf spark.cores.max=2 \
    --conf spark.dynamicAllocation.enabled=false \
    --hiveconf hive.server2.thrift.port=10000 \
    --hiveconf hive.server2.thrift.bind.host=0.0.0.0 &

# Wait for thrift server
echo "Waiting for Thrift Server to initialize..."
sleep 10
echo "Thrift Server initialization wait completed"

# Start Jupyter Lab (foreground - keeps container alive)
echo "[3/3] Starting Jupyter Lab on port 8888..."
cd /home/iceberg/notebooks
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password=''
