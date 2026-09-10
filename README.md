# 📉 Global Layoffs Data Cleaning & Exploratory Data Analysis (SQL)

Proyek ini menganalisis data PHK (*layoffs*) perusahaan-perusahaan di seluruh dunia menggunakan **PostgreSQL**. Proyek dibagi menjadi dua tahap utama: **Data Cleaning** untuk membersihkan data mentah agar siap dianalisis, dan **Exploratory Data Analysis (EDA)** untuk menggali insight dari data tersebut.

---

## 📌 Daftar Isi
- [Latar Belakang](#-latar-belakang)
- [Dataset](#-dataset)
- [Tools & Teknologi](#-tools--teknologi)
- [Alur Kerja Proyek](#-alur-kerja-proyek)
- [1. Data Cleaning](#1-data-cleaning)
- [2. Exploratory Data Analysis (EDA)](#2-exploratory-data-analysis-eda)
- [Insight Utama](#-insight-utama)
- [Struktur Folder](#-struktur-folder)
- [Cara Menjalankan](#-cara-menjalankan)
- [Skill yang Didemonstrasikan](#-skill-yang-didemonstrasikan)
- [Kontak](#-kontak)

---

## 🧭 Latar Belakang

Gelombang PHK massal terjadi di berbagai industri (terutama teknologi) dalam beberapa tahun terakhir. Proyek ini bertujuan untuk membersihkan data mentah tentang layoffs perusahaan global, kemudian menggali pola dan tren dari data tersebut — perusahaan mana yang paling terdampak, industri apa yang paling banyak melakukan PHK, dan bagaimana tren PHK dari waktu ke waktu.

## 🗂 Dataset

Dataset berisi informasi layoffs dari berbagai perusahaan dengan kolom-kolom berikut:

| Kolom | Deskripsi |
|---|---|
| `company` | Nama perusahaan |
| `location` | Lokasi kantor perusahaan |
| `industry` | Industri/sektor perusahaan |
| `total_laid_off` | Jumlah karyawan yang di-PHK |
| `percentage_laid_off` | Persentase karyawan yang di-PHK |
| `date` | Tanggal pengumuman PHK |
| `stage` | Tahap pendanaan perusahaan (Seed, Series A, IPO, dst.) |
| `country` | Negara |
| `funds_raised_millions` | Total dana yang berhasil dihimpun perusahaan (dalam juta USD) |

> *Sumber data: https://www.kaggle.com/datasets/swaptr/layoffs-2022

## 🛠 Tools & Teknologi
- **PostgreSQL** — database & query engine
- **SQL** — window functions, CTE, aggregate functions, self-join

---

## 🔄 Alur Kerja Proyek

```
Raw Data (layoffs)
      │
      ▼
Staging Table (layoffs_staging)      ← backup data mentah
      │
      ▼
Deduplication (layoffs_staging2)     ← ROW_NUMBER() + DELETE duplikat
      │
      ▼
Standardization                      ← perbaiki typo, format, isi NULL
      │
      ▼
Remove Null/Empty Rows               ← hapus baris tak berguna
      │
      ▼
Clean Dataset ✅ → siap untuk EDA
      │
      ▼
Exploratory Data Analysis (EDA)
```

---

### 1. Data Cleaning
📄 File: [`layoffs_cleaning_data.sql`](./layoffs_cleaning_data.sql)

Tahapan yang dilakukan:

1. **Backup Data** — menyalin data mentah ke tabel `layoffs_staging` agar data asli tetap aman dan tidak diubah langsung.
2. **Identifikasi & Hapus Duplikat**
   Menggunakan `ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)` untuk menandai baris duplikat, lalu menghapus baris dengan `duplicat_data > 1`.
3. **Standarisasi Data**
   - Mengubah nilai kosong (`''`) pada kolom `industry` menjadi `NULL` agar konsisten.
   - Mengisi nilai `industry` yang `NULL` dengan mencocokkan data perusahaan yang sama menggunakan **self-join**.
   - Memperbaiki inkonsistensi penulisan kategori, contoh: `'Cyrpto'` → `'Crypto'`.
   - Menyamakan format nama negara, contoh: `'United States.'` → `'United States'`.
4. **Menangani Missing Values**
   Menghapus baris yang tidak memiliki informasi `total_laid_off` **dan** `percentage_laid_off` sekaligus, karena baris tersebut tidak memberikan informasi yang bisa dianalisis.
5. **Pembersihan Akhir**
   Menghapus kolom bantu (`duplicat_data`) yang hanya digunakan untuk proses deduplikasi.

### 2. Exploratory Data Analysis (EDA)
📄 File: [`EDA.sql`](./EDA.sql)

Analisis yang dilakukan:

- **Statistik umum**: nilai maksimum `total_laid_off`, serta nilai max & min dari `percentage_laid_off`.
- **Perusahaan dengan PHK 100%** yang tetap berhasil menghimpun dana besar (kombinasi `percentage_laid_off = 1` dan `funds_raised_millions`).
- **Top 5 perusahaan** dengan jumlah PHK terbanyak dalam satu kali pengumuman.
- **Total PHK per perusahaan, lokasi, dan negara** (agregasi + `GROUP BY`).
- **Tren PHK per tahun** menggunakan `RIGHT(date, 4)`.
- **Total PHK per industri dan per stage pendanaan**.
- **Top 3 perusahaan dengan PHK terbanyak di setiap tahun**, menggunakan kombinasi **CTE** dan `DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC)`.
- **Tren bulanan** menggunakan `SUBSTRING(date, 1, 7)` untuk mengelompokkan data per bulan.
- **Rolling total (kumulatif) PHK per bulan** menggunakan window function `SUM() OVER (ORDER BY dates)` — berguna untuk melihat akumulasi PHK dari waktu ke waktu.

---

## 💡 Insight Utama

- Industry Consumer dan Retail mencatat angka PHK tertinggi mulai tahun 2020 - 2023, dengan angka 45182 orang untuk sektor Consumer dan 43613 orang sektor Retail.
- Tahun 2022 merupakan puncak gelombang PHK dengan total 160661 karyawan terdampak.
- Perusahaan Google melakukan PHK terbesar dalam satu pengumuman, yaitu 12000 karyawan.
- United States menjadi negara dengan akumulasi PHK tertinggi.


---

## 📁 Struktur Folder

Saran struktur repository agar terlihat rapi dan profesional:

```
layoffs-sql-analysis/
├── README.md
├── data/
│   └── layoffs.csv                  # dataset mentah (jika diizinkan untuk dibagikan)
├── layoffs_cleaning_data.sql        # tahap 1: data cleaning
├── EDA.sql                          # tahap 2: exploratory data analysis
```

## ▶️ Cara Menjalankan

1. Buat database dan schema:
   ```sql
   CREATE SCHEMA world_layoffs;
   ```
2. Import dataset mentah ke tabel `world_layoffs.layoffs` (misalnya lewat pgAdmin *Import/Export* atau `COPY` command).
3. Jalankan `layoffs_cleaning_data.sql` secara berurutan untuk membersihkan data.
4. Jalankan `EDA.sql` untuk melakukan eksplorasi data pada tabel `layoffs_staging2` yang sudah bersih.

---

## 🧠 Skill yang Didemonstrasikan

- Data cleaning: deduplikasi, standarisasi, penanganan *missing values*
- SQL window functions: `ROW_NUMBER()`, `DENSE_RANK()`, `SUM() OVER()`
- Common Table Expressions (CTE), termasuk CTE bertingkat
- Self-join untuk mengisi data yang hilang
- Aggregate functions & `GROUP BY` untuk analisis multi-dimensi
- Analisis tren waktu (time-series) dan rolling/cumulative total

---

## 📬 Kontak

**Muhammad Umam**
📧 umammuhamad22@gmail.com · 🔗 https://www.linkedin.com/in/muhammad-umam/ · 💻 github.com/iamumam

---
*Proyek ini dibuat sebagai bagian dari portfolio data analyst untuk mendemonstrasikan kemampuan SQL dalam data cleaning dan exploratory data analysis.*
