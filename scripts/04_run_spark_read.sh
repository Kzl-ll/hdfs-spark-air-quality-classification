#!/usr/bin/env bash
# Menjalankan job Spark yang membaca dataset dari HDFS
# Pemakaian: scripts/04_run_spark_read.sh [nama_file.py]   (default: read_from_hdfs.py)
set -euo pipefail
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")/.."

JOB="${1:-read_from_hdfs.py}"
docker compose exec -T spark-master /opt/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  "/opt/spark/jobs/$JOB"
