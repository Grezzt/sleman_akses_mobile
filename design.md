# SlemanAkses — Mobile App Design System
> Peta Aksesibilitas Fasilitas Umum & Edukasi bagi Penyandang Disabilitas Fisik di Kabupaten Sleman

---

## Daftar Isi

1. [Identitas Produk](#1-identitas-produk)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Bentuk, Border & Solid Shadow](#4-bentuk-border--solid-shadow)
5. [Component Library](#5-component-library)
6. [Mascot & Iconography](#6-mascot--iconography)
7. [Navigation System](#7-navigation-system)
8. [Page Catalog & Fitur](#8-page-catalog--fitur)

---

## 1. Identitas Produk

| Properti        | Nilai                                                                 |
|-----------------|-----------------------------------------------------------------------|
| **Nama Aplikasi** | SlemanAkses                                                         |
| **Tagline**     | Peta Aksesibilitas Kabupaten Sleman                                   |
| **Platform**    | Android (Flutter, cross-platform)                                     |
| **Target User** | Penyandang disabilitas fisik, masyarakat umum, relawan pelapor        |
| **Tone Visual** | Solid, Clean, Modern, Inclusive, Friendly                             |

---

## 2. Color System

Skema warna dirancang untuk memberikan kontras yang jelas serta kesan modern.

| Token | Hex Code | Penggunaan |
|-------|----------|------------|
| **Primary** | `#037940` | Warna utama (hijau gelap), tombol CTA, teks heading utama, ikon aktif. |
| **Secondary** | `#C7DE64` | Warna aksen (hijau lime), badge, avatar background, shadow alternatif. |
| **Surface** | `#FFFFFF` | Latar belakang Card, BottomSheet, Dialog, form input (putih bersih). |
| **Background** | `#F3F4F6` | Latar belakang layar/Scaffold (abu-abu terang) agar Card lebih kontras. |
| **Text Primary** | `#037940` | Warna teks judul dan heading. |
| **Text Muted** | `#4B5563` | Warna teks deskripsi, *hint text*, dan subtitle. |
| **Border** | `#D4D4D4` | Garis tepi (*border*) pada Card, form, serta warna *Solid Shadow* bawaan. |
| **Error / Red** | `#DC2626` | Pesan error, tombol logout, status ditolak. |

---

## 3. Typography

Menggunakan **KitRounded** (atau font berujung membulat sejenis) untuk menciptakan kesan *friendly* dan mudah dibaca.
- **Headings (H1-H3)**: Bold (700), ukuran 20-28, warna `Primary`.
- **Body Text**: Regular (400) atau Medium (500), ukuran 14-16, warna `Text Muted`.
- **Label / Badge**: Bold (700), ukuran 12.

---

## 4. Bentuk, Border & Solid Shadow

Aplikasi ini menggunakan gaya desain **Solid Shadow** (Neobrutalism ringan) untuk interaksi visual yang jelas.
Setiap elemen mengambang (Card, Tombol, Dialog) menggunakan aturan berikut:

- **Border Radius**: 16px untuk Card/Dialog, 8px untuk input/tombol kecil, 24-28px untuk tombol utama (*pill shape*).
- **Border**: Garis tepi setebal 1px - 2px dengan warna `AppTheme.border`.
- **Shadow**: 
  - Tidak ada *blur* (`blurRadius: 0`).
  - *Offset*: `(4, 4)`.
  - *Color*: `AppTheme.border` (untuk Card normal) atau `AppTheme.secondary` (untuk Card spesifik atau tombol).

---

## 5. Component Library

### 5.1 System Response Dialog
Dialog bawaan untuk menampilkan status (Sukses, Error, Informasi, Segera Hadir).
- **Elemen**: Terdiri dari ilustrasi maskot di atas, Judul, Deskripsi, dan tombol aksi.
- **Kustomisasi**: Memiliki parameter opsional `imagePath` untuk mengganti maskot (contoh: `maskot-genit.svg`, `maskot-side-eye.svg`), serta `shadowColor` untuk mengubah warna *Solid Shadow* pada dialog.

### 5.2 Input Form & Text Field
- **Latar belakang**: Abu-abu terang (`Colors.grey[100]`) tanpa border luar secara *default*, namun divalidasi dengan border merah jika *error*.
- **Ikon**: Menggunakan visibilitas *toggle* untuk *password*.
- Ditata rapi secara vertikal di tengah layer (`Center` > `SingleChildScrollView`) agar fokus, seperti pada halaman Edit Profil dan Ubah Sandi.

### 5.3 Tombol (Buttons)
- **Primary Button**: Warna *background* `Primary`, teks putih, `border-radius: 28` (*pill shape*), memiliki state *loading* (berupa *CircularProgressIndicator* putih).
- **Outlined Button**: Tanpa *background*, *border* sesuai warna aksi (misalnya merah untuk Logout), teks sesuai warna *border*.

### 5.4 Peta (FlutterMap)
Peta digunakan di banyak bagian aplikasi dengan perlakuan berbeda:
- **Eksplor (Home)**: Interaktif penuh (geser, *zoom*), marker *upright* anti-rotasi, dukungan *clustering*.
- **Preview / Detail / Konfirmasi**: **Peta Statis** (`InteractiveFlag.none`), berfungsi murni sebagai penampil visual lokasi absolut untuk memudahkan pemahaman ruang, tidak dapat digeser agar layar dapat di-*scroll* dengan mulus.

---

## 6. Mascot & Iconography

Ilustrasi maskot dalam format **SVG** digunakan secara luas untuk menghidupkan antarmuka:
- `konfirmasi-titik-lokasi-unactive.svg`: Dialog sukses (standar).
- `maskot-nangis.svg`: Dialog error atau status penolakan.
- `maskot-genit.svg` / `maskot-side-eye.svg`: Penghias *header* form profil, pengaturan, dan berita (*coming soon*).
- `onboarding slide 3.svg`: Ilustrasi keamanan pada form Ubah Kata Sandi.
- *Icon Set*: Ikon fasilitas seperti `toilet-difabel.svg`, `parkir-difabel.svg`, `ramp.svg`, `lift.svg` dengan warna aksen `Primary`.

*Gambar yang memuat dari internet (Cloudinary) menggunakan `CachedNetworkImage` untuk efisiensi.*

---

## 7. Navigation System

### Bottom Navigation Bar (NavigationBar)
Menu utama pada layar *Home* menggunakan `NavigationBar` (M3) dengan indikator aktif berupa siluet *pill*.
1. **Eksplor**: Menampilkan peta persebaran interaktif dengan *Search bar* melayang bergaya *Solid Shadow*.
2. **Fasilitas**: Menampilkan daftar fasilitas dalam mode *List* / *Card*.
3. **Berita**: Menu rintisan (saat ini menampilkan `SystemResponseDialog` dengan status "Segera Hadir").
4. **Riwayat**: Halaman *Tabbed View* untuk memantau status Laporan pengguna.
5. **Profil**: Halaman pengaturan akun.

---

## 8. Page Catalog & Fitur

### 8.1 Auth
- **Login & Register**: Form layar penuh untuk autentikasi *Sanctum*. Menampilkan *SystemResponseDialog* saat sukses/gagal.

### 8.2 Menu Utama (Beranda)
- Menampilkan *Map* yang secara dinamis mengambil data fasilitas (`/map`).
- Pengguna dapat mengetuk ikon *marker* di peta yang memunculkan `BottomSheet` pratinjau lokasi, kemudian dialihkan ke *Detail Fasilitas*.

### 8.3 Pembuatan Laporan (Create Report Screen)
- Alur *wizard* (berkelanjutan) di dalam 1 layar tanpa perlu berpindah *page*.
- **Tahap 1**: Upload foto berganda (unggah langsung ke Cloudinary), isi deskripsi, kategori.
- **Tahap 2**: *Geo-tagging* via map interaktif.
- **Tahap 3**: Pratinjau laporan dengan **Peta Statis** lokasi dan daftar foto, sebelum menekan tombol Kirim.

### 8.4 Riwayat Laporan (Report History)
- Terdiri dari 4 *Tab*: Semua, Menunggu, Disetujui, Ditolak.
- Menampilkan daftar laporan (*Cards*).
- Ketuk untuk membuka **Report Detail Screen** (berisi rincian beserta Peta Statis lokasi).

### 8.5 Tab Profil & Pengaturan
- **Header Profil**: Mengambil data API dinamis `GET /reports/stats` untuk menampilkan total laporan (Dikirim, Disetujui, Ditolak). Tampilan membulat dengan inisial nama.
- **Edit Profil**: Form terpusat (*centered*) dengan maskot, pembaruan nama asli via `PUT /profile`.
- **Ubah Kata Sandi**: Form keamanan terpusat dengan maskot keamanan, validasi kata sandi lama, sandi baru via `PUT /profile/password`.
- **Menu Ekstra**: Notifikasi, Tentang, Kebijakan Privasi (Saat ini diintegrasikan dengan `SystemResponseDialog` "Segera Hadir").

---
*Dokumentasi ini mencerminkan struktur fungsionalitas & estetika aplikasi versi produksi (terkini).*
