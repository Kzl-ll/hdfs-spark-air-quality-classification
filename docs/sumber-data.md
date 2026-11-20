# Sumber Data

| Item | Keterangan |
|---|---|
| Nama dataset | Beijing Multi-Site Air Quality |
| Penyedia | UCI Machine Learning Repository |
| Halaman dataset | https://archive.ics.uci.edu/dataset/501/beijing |
| DOI | https://doi.org/10.24432/C5RK5G |
| Lisensi | CC BY 4.0 (konfirmasi ulang di bagian "License" pada halaman UCI sebelum artikel dikumpulkan) |
| Cakupan | 12 stasiun pemantauan, 1 Maret 2013 sampai 28 Februari 2017, data per jam |
| Jumlah data | 420.768 baris (12 file CSV, satu per stasiun) |
| Variabel | Polutan: PM2.5, PM10, SO2, NO2, CO, O3. Cuaca: TEMP, PRES, DEWP, RAIN, wd, WSPM. Waktu: year, month, day, hour. Identitas: station |
| Nilai kosong | Ditandai `NA` pada file CSV |

## Metode pengumpulan
Dataset diunduh langsung dari UCI memakai `scripts/01_download_dataset.sh`, lalu diunggah ke HDFS memakai `scripts/02_upload_to_hdfs.sh`. Tidak ada API atau web crawling yang digunakan.

## Sitasi
Chen, S. (2017). *Beijing Multi-Site Air Quality* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5RK5G

## Catatan etika dan keterbatasan
- Data bersifat agregat pengukuran stasiun, tidak memuat data pribadi.
- Data berasal dari Beijing (2013 sampai 2017), sehingga hasil model tidak otomatis berlaku untuk kondisi Indonesia. Tulis ini pada bagian keterbatasan artikel.
- Dataset tidak memiliki label kategori kualitas udara. Label dibuat oleh tim (peran B) dari konsentrasi polutan; ambang batas dan acuannya didokumentasikan terpisah.
