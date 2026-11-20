"""Membuktikan Spark dapat membaca dataset mentah dari HDFS.
Output job ini dipakai sebagai screenshot bukti di artikel.
"""
from pyspark.sql import functions as F
from config import get_spark, read_raw, RAW_PATH

spark = get_spark("Kel8-ReadFromHDFS")
spark.sparkContext.setLogLevel("WARN")

df = read_raw(spark)

print("\n=== Sumber data ===")
print(RAW_PATH)

print("\n=== Skema (nama kolom dan tipe data) ===")
df.printSchema()

print("=== Jumlah baris dan kolom ===")
print(f"Baris : {df.count():,}")
print(f"Kolom : {len(df.columns)}")

print("\n=== Jumlah baris per stasiun ===")
df.groupBy("station").count().orderBy("station").show(20, truncate=False)

print("=== Jumlah nilai kosong (null) per kolom ===")
# backtick wajib karena nama kolom seperti PM2.5 mengandung titik
null_counts = df.select(
    [F.count(F.when(F.col(f"`{c}`").isNull(), 1)).alias(c) for c in df.columns]
)
null_counts.show(vertical=True, truncate=False)

print("=== 5 baris pertama ===")
df.show(5, truncate=False)

spark.stop()
