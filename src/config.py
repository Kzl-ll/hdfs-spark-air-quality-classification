"""Konfigurasi bersama untuk seluruh job Spark kelompok 8.
Import dari job lain:  from config import get_spark, read_raw, RAW_PATH, CLEAN_PATH, OUTPUT_PATH
"""
from pyspark.sql import SparkSession

HDFS_BASE = "hdfs://namenode:8020/user/kelompok8/airquality"
RAW_PATH = f"{HDFS_BASE}/raw/*.csv"      # dataset mentah (12 CSV, satu per stasiun)
CLEAN_PATH = f"{HDFS_BASE}/clean"        # hasil cleaning (diisi peran B)
OUTPUT_PATH = f"{HDFS_BASE}/output"      # hasil analisis / prediksi


def get_spark(app_name: str) -> SparkSession:
    return SparkSession.builder.appName(app_name).getOrCreate()


def read_raw(spark: SparkSession):
    """Membaca CSV mentah dari HDFS. Nilai 'NA' dianggap null."""
    return (
        spark.read.option("header", True)
        .option("inferSchema", True)
        .option("nullValue", "NA")
        .csv(RAW_PATH)
    )
