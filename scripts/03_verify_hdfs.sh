#!/usr/bin/env bash
# Menampilkan bukti data tersimpan di HDFS (screenshot output skrip ini)
set -euo pipefail
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")/.."

echo "=== 1. Struktur direktori ==="
docker compose exec -T namenode hdfs dfs -ls -R /user/kelompok8

echo
echo "=== 2. Isi direktori raw (ukuran terbaca manusia) ==="
docker compose exec -T namenode hdfs dfs -ls -h /user/kelompok8/airquality/raw

echo
echo "=== 3. Total ukuran ==="
docker compose exec -T namenode hdfs dfs -du -s -h /user/kelompok8/airquality/raw

echo
echo "=== 4. Status DataNode ==="
docker compose exec -T namenode hdfs dfsadmin -report | head -n 25

echo
echo "=== 5. Cek integritas (fsck) ==="
docker compose exec -T namenode hdfs fsck /user/kelompok8/airquality/raw | tail -n 15
