# Proyek Akhir Big Data - Kelompok 8
Klasifikasi Kategori Kualitas Udara Menggunakan Linear SVC pada Apache Spark dengan Penyimpanan HDFS.
Dataset: UCI Beijing Multi-Site Air Quality (lihat `docs/sumber-data.md`).

Alur: **Sumber Data -> HDFS -> Apache Spark -> Spark MLlib (Linear SVC) -> Evaluasi -> Draf Artikel**

## Struktur repo
```
compose.yml            cluster HDFS + Spark
hadoop.env             konfigurasi HDFS
scripts/               unduh data, upload HDFS, verifikasi, jalankan job Spark
src/                   kode PySpark (config.py dipakai bersama)
docs/sumber-data.md    sumber, lisensi, DOI, sitasi
docs/screenshots/      bukti HDFS dan Spark untuk artikel
data/                  dataset lokal (tidak di-commit)
```

## Prasyarat
- Docker Desktop (atau Docker Engine + Compose v2), RAM kosong minimal 4 GB
- Windows: jalankan skrip `.sh` lewat **Git Bash** atau **WSL**
- Skrip download butuh `curl`; ekstraksi otomatis memakai `unzip`, `python`, atau PowerShell, mana yang ada

## Menjalankan (urutan)
```bash
# 1. Nyalakan cluster
docker compose up -d
docker compose ps                       # kel8-namenode, kel8-datanode, kel8-spark-master, kel8-spark-worker harus Up

# 2. Unduh dataset ke data/raw (12 CSV)
bash scripts/01_download_dataset.sh

# 3. Upload ke HDFS
bash scripts/02_upload_to_hdfs.sh

# 4. Bukti data tersimpan 
bash scripts/03_verify_hdfs.sh

# 5. Spark membaca data dari HDFS 
bash scripts/04_run_spark_read.sh
```

Web UI: HDFS http://localhost:9870 (menu Utilities -> Browse the file system), Spark Master http://localhost:8090.

Semua skrip memakai `docker compose exec <service>`, jadi tetap jalan walau nama container diubah. Jalankan dari folder proyek.

Mematikan cluster:
- `docker compose stop` : berhenti, data HDFS tetap ada
- `docker compose down` : container dihapus, **data HDFS ikut hilang** (ulangi langkah 3, dataset di `data/raw` tetap ada)

## Jalur HDFS (disepakati seluruh anggota)
| Jalur | Isi | Pengisi |
|---|---|---|
| `/user/kelompok8/airquality/raw` | CSV mentah, jangan diubah | A |
| `/user/kelompok8/airquality/clean` | data bersih + label | B |
| `/user/kelompok8/airquality/output` | hasil analisis, prediksi, metrik | C, D |

## Menulis job Spark baru
Taruh file di `src/`, lalu:
```python
from config import get_spark, read_raw, CLEAN_PATH, OUTPUT_PATH
spark = get_spark("Nama-Job")
df = read_raw(spark)
```
Jalankan: `bash scripts/04_run_spark_read.sh nama_file.py`

Catatan: nama kolom `PM2.5` mengandung titik. Di DataFrame API tulis `` F.col("`PM2.5`") `` (dengan backtick), kalau tidak Spark mengira itu field bersarang.

## Setiap anggota menjalankan cluster sendiri
HDFS ini berjalan di laptop masing-masing. Anggota lain cukup `git pull`, lalu ulangi langkah 1 sampai 3. Hasil kerja dibagikan lewat kode di GitHub, bukan lewat HDFS.

## Bukti untuk artikel (checklist screenshot, simpan di `screenshots/`)
- [ ] `docker compose ps` (4 container kel8-* Up)
- [ ] Output `03_verify_hdfs.sh` (struktur direktori dan ukuran file)
- [ ] HDFS Web UI, halaman Browse the file system pada `/user/kelompok8/airquality/raw`
- [ ] Output `04_run_spark_read.sh` (skema, jumlah baris 420.768, null per kolom)
- [ ] Spark Master UI di localhost:8090 (worker Alive, aplikasi selesai)

## Troubleshooting
| Gejala | Penyebab / solusi |
|---|---|
| `docker compose up` gagal menarik image | cek koneksi; tag image: `apache/hadoop:3.3.6`, `apache/spark:3.5.8-python3` |
| `Name node is in safe mode` | tunggu 30 sampai 60 detik; skrip 02 sudah menunggu otomatis |
| `File ... could only be written to 0 nodes` | DataNode belum hidup: `docker compose logs datanode` |
| `container name ... is already in use` | nama container bentrok dengan container lama. Proyek ini memakai prefix `kel8-`; hapus sisa container kel8 dengan `docker compose down` |
| `port is already allocated` | container lain memakai port 9870/8090/8081/7077: `docker ps` lalu `docker stop <nama>` |
| Namenode Exited, log `chmod: changing permissions of '/data': Read-only file system` | dataset harus di-mount ke `/dataset`, bukan `/data` (sudah diperbaiki di compose) |
| Spark master Exited, log `UnknownHostException: spark-master` | butuh `SPARK_LOCAL_HOSTNAME` (sudah ada di compose); jalankan `docker compose down` lalu `up -d` |
| Container Exited | `docker compose ps -a`, lalu `docker compose logs --tail=40 <service>` |
| Path `/user/...` berubah jadi `C:/Program Files/Git/...` | gunakan skrip yang disediakan (sudah memakai `MSYS_NO_PATHCONV=1`) |
| Job Spark: `Connection refused ... 8020` | pastikan namenode Up dan URL memakai `hdfs://namenode:8020` |
| Worker tidak muncul di Spark UI | `docker compose logs spark-worker`; pastikan RAM Docker cukup |
| Ekstraksi gagal / tidak ada `curl` | unduh manual dari halaman UCI, taruh 12 CSV di `data/raw/`, lanjut ke langkah 3 |

## Perintah manual dari PowerShell (tanpa Git Bash)
Jalankan dari folder proyek, setelah 12 CSV ada di `data\raw`:
```powershell
docker compose exec -T namenode hdfs dfsadmin -safemode wait
docker compose exec -T namenode hdfs dfs -mkdir -p /user/kelompok8/airquality/raw
docker compose exec -T namenode hdfs dfs -mkdir -p /user/kelompok8/airquality/clean
docker compose exec -T namenode hdfs dfs -mkdir -p /user/kelompok8/airquality/output
docker compose exec -T namenode bash -c "hdfs dfs -put -f /dataset/raw/*.csv /user/kelompok8/airquality/raw/"
docker compose exec -T namenode hdfs dfs -ls -h /user/kelompok8/airquality/raw
docker compose exec -T spark-master /opt/spark/bin/spark-submit --master spark://spark-master:7077 /opt/spark/jobs/read_from_hdfs.py
```
