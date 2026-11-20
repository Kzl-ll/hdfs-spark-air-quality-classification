#!/usr/bin/env bash
# Mengunduh dataset UCI Beijing Multi-Site Air Quality ke data/raw/
# Butuh curl. Ekstraksi memakai unzip, atau python, atau PowerShell (otomatis dipilih).
set -euo pipefail
cd "$(dirname "$0")/.."

URL1="https://archive.ics.uci.edu/static/public/501/beijing+multi+site+air+quality+data.zip"
URL2="https://archive.ics.uci.edu/ml/machine-learning-databases/00501/PRSA2017_Data_20130301-20170228.zip"
ZIP="data/beijing.zip"

# extract <file.zip> <folder-tujuan> : coba beberapa cara sampai ada yang berhasil
extract() {
  local zip="$1" dest="$2"
  if command -v unzip >/dev/null 2>&1 && unzip -o -q "$zip" -d "$dest"; then return 0; fi
  if command -v python3 >/dev/null 2>&1 && python3 -m zipfile -e "$zip" "$dest"; then return 0; fi
  if command -v python >/dev/null 2>&1 && python -m zipfile -e "$zip" "$dest"; then return 0; fi
  if command -v powershell.exe >/dev/null 2>&1; then
    local wz="$zip" wd="$dest"
    if command -v cygpath >/dev/null 2>&1; then wz="$(cygpath -w "$zip")"; wd="$(cygpath -w "$dest")"
    elif command -v wslpath >/dev/null 2>&1; then wz="$(wslpath -w "$zip")"; wd="$(wslpath -w "$dest")"; fi
    if powershell.exe -NoProfile -Command "Expand-Archive -LiteralPath '$wz' -DestinationPath '$wd' -Force"; then return 0; fi
  fi
  echo "!! Gagal mengekstrak $zip. Ekstrak manual lalu taruh 12 file PRSA_Data_*.csv di data/raw/"
  return 1
}

mkdir -p data/raw data/tmp
rm -rf data/tmp/*

if [ ! -s "$ZIP" ]; then
  echo ">> Mengunduh dataset..."
  if ! curl -fL --retry 3 -o "$ZIP" "$URL1"; then
    echo ">> URL utama gagal, mencoba URL cadangan..."
    curl -fL --retry 3 -o "$ZIP" "$URL2"
  fi
else
  echo ">> $ZIP sudah ada, lewati unduhan"
fi

echo ">> Mengekstrak..."
extract "$ZIP" data/tmp
# Arsip UCI bisa berisi zip di dalam zip
find data/tmp -mindepth 1 -name '*.zip' -print0 | while IFS= read -r -d '' z; do
  extract "$z" data/tmp
done
find data/tmp -name 'PRSA_Data_*.csv' -exec cp {} data/raw/ \;

echo ">> File CSV di data/raw/:"
ls -1 data/raw
echo ">> Jumlah file: $(ls -1 data/raw/*.csv | wc -l) (harus 12, satu per stasiun)"
