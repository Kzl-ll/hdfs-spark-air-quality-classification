#!/usr/bin/env bash
# Membuat direktori HDFS dan mengunggah dataset mentah
set -euo pipefail
export MSYS_NO_PATHCONV=1   # mencegah Git Bash (Windows) mengubah path /user/...
cd "$(dirname "$0")/.."

HDFS_RAW=/user/kelompok8/airquality/raw

echo ">> Menunggu NameNode keluar dari safe mode..."
docker compose exec -T namenode hdfs dfsadmin -safemode wait

echo ">> Membuat direktori $HDFS_RAW"
docker compose exec -T namenode hdfs dfs -mkdir -p "$HDFS_RAW"
docker compose exec -T namenode hdfs dfs -mkdir -p /user/kelompok8/airquality/clean
docker compose exec -T namenode hdfs dfs -mkdir -p /user/kelompok8/airquality/output

echo ">> Mengunggah CSV (dibaca dari /dataset/raw di dalam container)"
docker compose exec -T namenode bash -c "hdfs dfs -put -f /dataset/raw/*.csv $HDFS_RAW/"

echo ">> Selesai. Jalankan scripts/03_verify_hdfs.sh untuk bukti."
