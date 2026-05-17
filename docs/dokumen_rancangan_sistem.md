# Dokumen Rancangan Sistem

# Sleman Akses — Sistem Peta Aksesibilitas Fasilitas Umum Ramah Disabilitas

> **Versi:** 1.0
> **Tanggal:** Mei 2026
> **Platform:** Web (Admin Dashboard) + Mobile App
> **Backend:** Laravel 12 (PHP 8.2) · MySQL

---

## 1. Pendahuluan

### 1.1 Latar Belakang

Sleman Akses adalah sistem informasi berbasis peta digital yang dirancang untuk membantu masyarakat — khususnya penyandang disabilitas — dalam menemukan fasilitas umum yang ramah disabilitas di wilayah Kabupaten Sleman. Sistem ini memungkinkan pengguna untuk melaporkan kondisi aksesibilitas fasilitas umum secara geo-tagging (berbasis GPS), sedangkan administrator dapat memvalidasi laporan tersebut dan mempublikasikannya ke peta digital yang dapat diakses oleh masyarakat umum.

### 1.2 Tujuan Sistem

| Tujuan                  | Keterangan                                                              |
| ----------------------- | ----------------------------------------------------------------------- |
| Pemetaan Digital        | Menampilkan sebaran fasilitas umum ramah disabilitas di peta interaktif |
| Partisipasi Publik      | Mengumpulkan laporan kondisi aksesibilitas dari pengguna mobile         |
| Validasi Data           | Menyediakan mekanisme verifikasi laporan oleh administrator             |
| Aksesibilitas Informasi | Memungkinkan masyarakat umum mengakses data tanpa perlu login           |

### 1.3 Ruang Lingkup

Sistem ini terdiri dari dua platform utama:

1. **Aplikasi Mobile** — Digunakan oleh pengguna publik untuk mendaftar, login, dan mengirim laporan geo-tagging fasilitas umum
2. **Web Admin Panel** — Digunakan oleh administrator untuk memvalidasi laporan, mengelola data spasial, dan memantau sistem
3. **Halaman Web Publik** — Peta interaktif yang dapat diakses tanpa login oleh siapapun

---

## 2. Aktor Sistem

### 2.1 Diagram Aktor

| Aktor                   | Platform             | Hak Akses                                                                  |
| ----------------------- | -------------------- | -------------------------------------------------------------------------- |
| **Pengguna Mobile**     | Aplikasi Android/iOS | Daftar akun, login, kirim laporan, lihat riwayat laporan, edit profil      |
| **Administrator**       | Web Browser          | Login web, validasi laporan, kelola peta, kelola kategori, lihat statistik |
| **Pengguna Web Publik** | Web Browser          | Lihat peta sebaran fasilitas (tanpa autentikasi)                           |

### 2.2 Spesifikasi Hak Akses

#### Pengguna Mobile

- Mendaftarkan akun baru dengan nama lengkap, email, dan password
- Login dan mendapatkan token autentikasi
- Mengakses menu pelaporan: ekstrak GPS otomatis → isi form → unggah foto
- Melihat riwayat laporan yang telah dikirim beserta status validasi
- Melihat peta digital lokasi fasilitas yang telah diverifikasi
- Mengedit data profil akun

#### Administrator

- Login menggunakan akun yang telah terdaftar dengan role `admin`
- Melihat dashboard dengan statistik sistem
- Meninjau semua laporan masuk dengan status _pending_, _approved_, atau _rejected_
- Melihat detail laporan: foto, koordinat GPS, kategori fasilitas, data pengirim
- Memberikan keputusan validasi: **Setujui** (data masuk ke peta) atau **Tolak** (dengan catatan evaluasi)
- Mengelola kategori fasilitas umum (CRUD)
- Mengelola lokasi pada peta (hapus jika perlu)
- Melihat daftar pengguna terdaftar

#### Pengguna Web Publik

- Mengakses halaman utama tanpa login
- Melihat peta interaktif sebaran fasilitas umum ramah disabilitas
- Melihat detail informasi fasilitas: kategori, status aksesibilitas, foto
- Memfilter tampilan peta berdasarkan kategori fasilitas

---

## 3. Use Case

### 3.1 Daftar Use Case

| ID    | Use Case                       | Aktor                          | Include      |
| ----- | ------------------------------ | ------------------------------ | ------------ |
| UC-01 | Mendaftarkan Akun              | Pengguna Mobile                | —            |
| UC-02 | Login                          | Pengguna Mobile, Administrator | —            |
| UC-03 | Mengirim Laporan Geo-tagging   | Pengguna Mobile                | UC-04, UC-05 |
| UC-04 | Mengekstraksi Koordinat GPS    | Sistem                         | —            |
| UC-05 | Mengunggah Bukti Foto          | Pengguna Mobile                | —            |
| UC-06 | Meninjau Detail Aksesibilitas  | Pengguna Mobile, Publik        | —            |
| UC-07 | Melihat Peta Sebaran Fasilitas | Pengguna Mobile, Publik        | —            |
| UC-08 | Login Admin                    | Administrator                  | UC-02        |
| UC-09 | Memvalidasi Data Laporan       | Administrator                  | UC-08        |
| UC-10 | Mengelola Informasi Spasial    | Administrator                  | UC-08        |
| UC-11 | Logout                         | Semua aktor                    | —            |

### 3.2 Spesifikasi Use Case Utama

#### UC-03: Mengirim Laporan Geo-tagging

| Atribut             | Detail                                                                                                                                                                                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Aktor**           | Pengguna Mobile                                                                                                                                                                                                                                                          |
| **Precondition**    | Pengguna sudah login, GPS aktif                                                                                                                                                                                                                                          |
| **Alur Normal**     | 1. Pengguna buka menu Pelaporan → 2. Sistem ekstrak koordinat GPS → 3. Pengguna isi form fasilitas & pilih kategori → 4. Pengguna unggah foto → 5. Pengguna kirim laporan → 6. Sistem simpan ke database dengan status `pending` → 7. Sistem tampilkan notifikasi sukses |
| **Alur Alternatif** | GPS tidak aktif → Sistem minta pengguna aktifkan GPS                                                                                                                                                                                                                     |
| **Postcondition**   | Laporan tersimpan, validasi dibuat dengan status `pending`                                                                                                                                                                                                               |

#### UC-09: Memvalidasi Data Laporan

| Atribut           | Detail                                                                                                                                                                                                                                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Aktor**         | Administrator                                                                                                                                                                                                                                                          |
| **Precondition**  | Admin sudah login, ada laporan dengan status `pending`                                                                                                                                                                                                                 |
| **Alur Normal**   | 1. Admin buka daftar laporan → 2. Admin pilih laporan → 3. Admin tinjau foto & koordinat → 4. Admin pilih Setujui/Tolak + isi catatan → 5. Admin submit → 6. Jika Setujui: sistem insert `map_locations`, update status → 7. Jika Tolak: hanya update status + catatan |
| **Postcondition** | Status laporan berubah, jika approved data muncul di peta                                                                                                                                                                                                              |

---

## 4. Rancangan Basis Data

### 4.1 Entity Relationship Diagram (ERD)

Sistem menggunakan 6 tabel utama dengan relasi sebagai berikut:

```
USERS ──< REPORTS ──< REPORT_DETAILS >── FACILITY_CATEGORIES
  │           │
  │           └──< VALIDATIONS >── MAP_LOCATIONS
  │                    │
  └────────────────────┘ (admin melakukan validasi)
```

**Kardinalitas:**

- `USERS` → `REPORTS` : One to Many (satu user bisa kirim banyak laporan)
- `REPORTS` → `REPORT_DETAILS` : One to Many (satu laporan bisa punya banyak detail fasilitas)
- `FACILITY_CATEGORIES` → `REPORT_DETAILS` : One to Many (satu kategori bisa ada di banyak detail)
- `REPORTS` → `VALIDATIONS` : One to One (satu laporan punya satu validasi)
- `USERS` → `VALIDATIONS` : One to Many (satu admin bisa memvalidasi banyak laporan)
- `VALIDATIONS` → `MAP_LOCATIONS` : One to One (satu validasi menghasilkan satu lokasi peta)

### 4.2 Spesifikasi Tabel

#### Tabel `users`

| Kolom            | Tipe                 | Constraint         | Keterangan           |
| ---------------- | -------------------- | ------------------ | -------------------- |
| `user_id`        | INT                  | PK, Auto Increment | ID unik pengguna     |
| `full_name`      | VARCHAR(255)         | NOT NULL           | Nama lengkap         |
| `email`          | VARCHAR(255)         | NOT NULL, UNIQUE   | Email login          |
| `password`       | VARCHAR(255)         | NOT NULL           | Hash bcrypt          |
| `role`           | ENUM('user','admin') | DEFAULT 'user'     | Peran pengguna       |
| `remember_token` | VARCHAR(100)         | NULLABLE           | Session token web    |
| `created_at`     | TIMESTAMP            | —                  | Timestamp dibuat     |
| `updated_at`     | TIMESTAMP            | —                  | Timestamp diperbarui |

#### Tabel `facility_categories`

| Kolom           | Tipe         | Constraint         | Keterangan                   |
| --------------- | ------------ | ------------------ | ---------------------------- |
| `category_id`   | INT          | PK, Auto Increment | ID kategori                  |
| `facility_name` | VARCHAR(255) | NOT NULL           | Nama fasilitas (mis. "Ramp") |
| `icon_marker`   | VARCHAR(255) | NOT NULL           | Nama/URL ikon marker peta    |
| `created_at`    | TIMESTAMP    | —                  | —                            |
| `updated_at`    | TIMESTAMP    | —                  | —                            |

#### Tabel `reports`

| Kolom        | Tipe          | Constraint          | Keterangan            |
| ------------ | ------------- | ------------------- | --------------------- |
| `report_id`  | INT           | PK, Auto Increment  | ID laporan            |
| `user_id`    | INT           | FK → users(user_id) | Pengirim laporan      |
| `latitude`   | DECIMAL(10,7) | NOT NULL            | Koordinat lintang GPS |
| `longitude`  | DECIMAL(10,7) | NOT NULL            | Koordinat bujur GPS   |
| `photo_url`  | VARCHAR(255)  | NOT NULL            | Path/URL foto bukti   |
| `timestamp`  | TIMESTAMP     | DEFAULT CURRENT     | Waktu laporan dibuat  |
| `created_at` | TIMESTAMP     | —                   | —                     |
| `updated_at` | TIMESTAMP     | —                   | —                     |

#### Tabel `report_details`

| Kolom                 | Tipe      | Constraint                            | Keterangan                     |
| --------------------- | --------- | ------------------------------------- | ------------------------------ |
| `detail_id`           | INT       | PK, Auto Increment                    | ID detail                      |
| `report_id`           | INT       | FK → reports(report_id)               | Laporan terkait                |
| `category_id`         | INT       | FK → facility_categories(category_id) | Kategori fasilitas             |
| `availability_status` | BOOLEAN   | NOT NULL                              | TRUE = tersedia, FALSE = tidak |
| `created_at`          | TIMESTAMP | —                                     | —                              |
| `updated_at`          | TIMESTAMP | —                                     | —                              |

#### Tabel `validations`

| Kolom             | Tipe                                  | Constraint              | Keterangan                    |
| ----------------- | ------------------------------------- | ----------------------- | ----------------------------- |
| `validation_id`   | INT                                   | PK, Auto Increment      | ID validasi                   |
| `user_id`         | INT                                   | FK → users(user_id)     | Admin yang memvalidasi        |
| `report_id`       | INT                                   | FK → reports(report_id) | Laporan yang divalidasi       |
| `approval_status` | ENUM('pending','approved','rejected') | DEFAULT 'pending'       | Status validasi               |
| `evaluation_note` | TEXT                                  | NULLABLE                | Catatan evaluasi admin        |
| `validation_date` | TIMESTAMP                             | NULLABLE                | Waktu admin memberi keputusan |
| `created_at`      | TIMESTAMP                             | —                       | —                             |
| `updated_at`      | TIMESTAMP                             | —                       | —                             |

#### Tabel `map_locations`

| Kolom           | Tipe          | Constraint                      | Keterangan                        |
| --------------- | ------------- | ------------------------------- | --------------------------------- |
| `location_id`   | INT           | PK, Auto Increment              | ID lokasi peta                    |
| `validation_id` | INT           | FK → validations(validation_id) | Validasi yang menghasilkan lokasi |
| `latitude`      | DECIMAL(10,7) | NOT NULL                        | Koordinat final di peta           |
| `longitude`     | DECIMAL(10,7) | NOT NULL                        | Koordinat final di peta           |
| `publish_date`  | TIMESTAMP     | NULLABLE                        | Waktu dipublikasikan ke peta      |
| `created_at`    | TIMESTAMP     | —                               | —                                 |
| `updated_at`    | TIMESTAMP     | —                               | —                                 |

### 4.3 Data Awal (Seed)

**Kategori Fasilitas:**

| ID  | Nama Fasilitas      | Icon Marker         |
| --- | ------------------- | ------------------- |
| 1   | Ramp / Jalur Khusus | `ramp.png`          |
| 2   | Toilet Difabel      | `toilet.png`        |
| 3   | Parkir Difabel      | `parking.png`       |
| 4   | Lift Aksesibel      | `elevator.png`      |
| 5   | Guiding Block       | `guiding-block.png` |

**Akun Admin Default:**

- Email: `admin@sleman-akses.id`
- Password: `password` (harus diganti saat deployment)
- Role: `admin`

---

## 5. Arsitektur Sistem

### 5.1 Pola Arsitektur: MVC + Service + Repository

Sistem menggunakan arsitektur berlapis yang memisahkan tanggung jawab secara jelas:

```
┌──────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
│   ┌────────────────┐   ┌─────────────────┐   ┌───────────────────┐  │
│   │  Mobile App    │   │  Web Browser    │   │  Web Browser      │  │
│   │  (Android/iOS) │   │  (Admin Panel)  │   │  (Publik)         │  │
│   └───────┬────────┘   └────────┬────────┘   └─────────┬─────────┘  │
└───────────┼─────────────────────┼─────────────────────┼─────────────┘
            │ JSON / REST         │ HTML (Blade)         │ HTML (Blade)
            │                    │                      │
┌───────────▼────────────────────▼──────────────────────▼─────────────┐
│                    [1] CONTROLLER LAYER (MVC - C)                    │
│                                                                      │
│   app/Http/Controllers/Api/*      app/Http/Controllers/Admin/*       │
│   ─ Terima HTTP request           ─ Terima HTTP request              │
│   ─ Validasi via FormRequest      ─ Validasi via FormRequest         │
│   ─ Delegasi ke Service           ─ Delegasi ke Service              │
│   ─ Return JSON Resource          ─ Return Blade View                │
└───────────────────────────┬──────────────────────────────────────────┘
                            │ Panggil
┌───────────────────────────▼──────────────────────────────────────────┐
│                    [2] SERVICE LAYER                                  │
│                                                                      │
│   app/Services/                                                      │
│   ─ Berisi business logic utama                                      │
│   ─ Orkestrasi antar Repository                                      │
│   ─ Tidak langsung akses database                                    │
│   ─ Dapat dipanggil dari Controller API maupun Web                   │
│                                                                      │
│   AuthService       │ ReportService      │ ValidationService         │
│   CategoryService   │ MapLocationService │ PhotoUploadService        │
└───────────────────────────┬──────────────────────────────────────────┘
                            │ Panggil
┌───────────────────────────▼──────────────────────────────────────────┐
│                    [3] REPOSITORY LAYER                               │
│                                                                      │
│   app/Repositories/                                                  │
│   ─ Abstraksi query database                                         │
│   ─ Satu-satunya layer yang berinteraksi dengan Model/Eloquent       │
│   ─ Implementasi interface (mudah di-mock untuk testing)             │
│                                                                      │
│   UserRepository        │ ReportRepository   │ ValidationRepository  │
│   CategoryRepository    │ MapLocationRepository                       │
└───────────────────────────┬──────────────────────────────────────────┘
                            │ Eloquent ORM
┌───────────────────────────▼──────────────────────────────────────────┐
│                    [4] MODEL LAYER (MVC - M)                          │
│                                                                      │
│   app/Models/                                                        │
│   ─ Definisi tabel, fillable, casts                                  │
│   ─ Relasi Eloquent antar model                                      │
│   ─ Tidak berisi business logic                                      │
└───────────────────────────┬──────────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────────┐
│                       MySQL Database                                  │
│   users · reports · report_details · facility_categories              │
│   validations · map_locations                                         │
└──────────────────────────────────────────────────────────────────────┘
```

### 5.2 Tanggung Jawab Tiap Layer

#### Controller Layer

| Tanggung Jawab                      | ✅ Ya | ❌ Tidak |
| ----------------------------------- | ----- | -------- |
| Menerima dan memvalidasi input HTTP | ✅    |          |
| Memanggil Service yang sesuai       | ✅    |          |
| Mengembalikan response (JSON/View)  | ✅    |          |
| Mengandung business logic           |       | ❌       |
| Langsung query database             |       | ❌       |

#### Service Layer

| Tanggung Jawab                               | ✅ Ya | ❌ Tidak |
| -------------------------------------------- | ----- | -------- |
| Mengandung business logic utama              | ✅    |          |
| Memanggil satu atau lebih Repository         | ✅    |          |
| Mengorkestrasi transaksi database            | ✅    |          |
| Dapat digunakan ulang dari banyak Controller | ✅    |          |
| Menerima HTTP Request langsung               |       | ❌       |
| Langsung query database (Eloquent)           |       | ❌       |

#### Repository Layer

| Tanggung Jawab                       | ✅ Ya | ❌ Tidak |
| ------------------------------------ | ----- | -------- |
| Abstraksi semua query database       | ✅    |          |
| Implementasikan interface Repository | ✅    |          |
| Gunakan Eloquent Model untuk query   | ✅    |          |
| Mengandung business logic            |       | ❌       |

#### Model Layer

| Tanggung Jawab                   | ✅ Ya | ❌ Tidak |
| -------------------------------- | ----- | -------- |
| Definisi kolom, fillable, casts  | ✅    |          |
| Definisi relasi Eloquent         | ✅    |          |
| Scope query sederhana (optional) | ✅    |          |
| Business logic                   |       | ❌       |

### 5.3 Alur Data per Use Case

#### Contoh: POST `/api/v1/reports` (Kirim Laporan)

```
Mobile App
  │
  │  POST /api/v1/reports { lat, lng, photo, categories[] }
  ▼
Api\ReportController@store
  ├─ [1] Validasi input via StoreReportRequest
  ├─ [2] Panggil ReportService::createReport($request, $user)
  │         │
  │         ├─ Panggil PhotoUploadService::upload($photo, $userId)
  │         │       └─ Simpan file → return path
  │         │
  │         ├─ Panggil ReportRepository::create([lat, lng, photo_url, user_id])
  │         │       └─ Report::create() → return $report
  │         │
  │         ├─ Foreach $categories:
  │         │    Panggil ReportRepository::addDetail($report, $categoryId, $status)
  │         │
  │         └─ Panggil ValidationRepository::initPending($report)
  │                 └─ Validation::create([report_id, status:'pending'])
  │
  └─ [3] Return ReportResource($report) → JSON response
```

#### Contoh: POST `/admin/reports/{id}/validate` (Validasi Laporan)

```
Admin Web
  │
  │  POST /admin/reports/5/validate { approval_status, evaluation_note }
  ▼
Admin\ValidationController@store
  ├─ [1] Ambil laporan via ReportRepository::findWithValidation($id)
  ├─ [2] Panggil ValidationService::validate($report, $data, $admin)
  │         │
  │         ├─ Panggil ValidationRepository::update($validation, $data)
  │         │
  │         └─ Jika approval_status == 'approved':
  │               Panggil MapLocationRepository::createFromReport($validation, $report)
  │                     └─ MapLocation::create([validation_id, lat, lng, publish_date])
  │
  └─ [3] Redirect /admin/reports dengan flash message sukses
```

### 5.4 Daftar Service & Repository

#### Services (`app/Services/`)

| Service              | Metode Utama                                   | Deskripsi                                           |
| -------------------- | ---------------------------------------------- | --------------------------------------------------- |
| `AuthService`        | `register()`, `login()`, `logout()`            | Logika autentikasi, buat/revoke token Sanctum       |
| `ReportService`      | `createReport()`, `getUserReports()`           | Buat laporan + detail + init validasi pending       |
| `ValidationService`  | `validate()`                                   | Proses approve/reject, trigger publikasi ke peta    |
| `MapLocationService` | `getPublished()`, `delete()`                   | Ambil & hapus data lokasi yang terpublish           |
| `CategoryService`    | `getAll()`, `create()`, `update()`, `delete()` | CRUD kategori fasilitas                             |
| `PhotoUploadService` | `upload()`, `delete()`                         | Upload, resize (via Intervention Image), hapus foto |

#### Repositories (`app/Repositories/`)

| Repository             | Metode Utama                                                          | Model                    |
| ---------------------- | --------------------------------------------------------------------- | ------------------------ |
| `UserRepository`       | `findByEmail()`, `create()`, `update()`                               | `User`                   |
| `ReportRepository`     | `create()`, `addDetail()`, `findWithRelations()`, `getAllPaginated()` | `Report`, `ReportDetail` |
| `ValidationRepository` | `initPending()`, `update()`, `findByReport()`                         | `Validation`             |

### 5.5 Arsitektur Mobile Flutter (Layered: UI / Logic / Data)

Aplikasi mobile Flutter menggunakan pola Layered Architecture sederhana dengan 3 lapisan: UI, Logic, dan Data. Pola ini mengikuti dokumentasi Flutter tentang pemisahan tanggung jawab dan menjaga kode tetap mudah diuji serta mudah dipelihara.

```
┌───────────────────────────────────────────────────────────────┐
│ UI LAYER                                                      │
│ Widgets, Screens, UI State (stateful/stateless)               │
└───────────────┬───────────────────────────────────────────────┘
                │ kirim event / ambil state
┌───────────────▼───────────────────────────────────────────────┐
│ LOGIC LAYER                                                   │
│ State management (Controller/Notifier/BLoC) + Use Cases       │
└───────────────┬───────────────────────────────────────────────┘
                │ panggil repository / service
┌───────────────▼───────────────────────────────────────────────┐
│ DATA LAYER                                                    │
│ Repositories + Data Sources (API, local storage)              │
└───────────────┬───────────────────────────────────────────────┘
                │ HTTP/DB/Cache
        REST API (Laravel) / Local Storage (Hive/Prefs)
```

#### 5.5.1 Tujuan Pemisahan Layer

- UI fokus pada tampilan dan interaksi pengguna.
- Logic fokus pada alur bisnis dan pengelolaan state.
- Data fokus pada akses data (remote/local) dan mapping model.

#### 5.5.2 Struktur Folder yang Disarankan

```
lib/
  core/
    constants/
    errors/
    network/
    utils/
  features/
    auth/
      ui/
        screens/
        widgets/
      logic/
        controllers/
        state/
      data/
        models/
        repositories/
        datasources/
    reports/
      ui/
      logic/
      data/
    maps/
      ui/
      logic/
      data/
  app.dart
  main.dart
```

Catatan: nama folder bisa disesuaikan, yang penting konsisten: `ui/`, `logic/`, dan `data/` per fitur.

#### 5.5.3 Tanggung Jawab Tiap Layer

##### UI Layer

- Menampilkan layar dan komponen UI.
- Mengirim event ke Logic (mis. tombol submit, refresh, filter).
- Mengambil state yang sudah siap ditampilkan.
- Tidak melakukan HTTP, tidak memproses JSON.

##### Logic Layer

- Menyimpan state (loading, data, error).
- Menjalankan use case (login, kirim laporan, ambil peta).
- Memanggil repository pada Data Layer.
- Mengubah data mentah menjadi state yang siap ditampilkan UI.

##### Data Layer

- Menangani komunikasi API (REST), cache lokal, dan sumber data lain.
- Melakukan mapping model (fromJson/toJson).
- Menyediakan Repository sebagai abstraksi untuk Logic Layer.

#### 5.5.4 Alur Data Contoh: Kirim Laporan

```
UI (ReportFormScreen)
  -> Logic (ReportController.submitReport)
     -> Data (ReportRepository.createReport)
        -> DataSource (ReportRemoteDataSource.postReport)
           -> REST API (Laravel)
```

#### 5.5.5 Contoh Pemetaan Komponen

| Fitur   | UI                                        | Logic                             | Data                                                        |
| ------- | ----------------------------------------- | --------------------------------- | ----------------------------------------------------------- |
| Auth    | `LoginScreen`, `RegisterScreen`           | `AuthController`, `AuthState`     | `AuthRepository`, `AuthRemoteDataSource`, `UserModel`       |
| Laporan | `ReportFormScreen`, `ReportHistoryScreen` | `ReportController`, `ReportState` | `ReportRepository`, `ReportRemoteDataSource`, `ReportModel` |
| Peta    | `MapScreen`, `MapFilterWidget`            | `MapController`, `MapState`       | `MapRepository`, `MapRemoteDataSource`, `MapLocationModel`  |

#### 5.5.6 Catatan Implementasi

- State management bebas: `ChangeNotifier`, `Provider`, `Riverpod`, `Bloc`, atau `Cubit`.
- Logic tidak bergantung ke Flutter UI; idealnya mudah di-unit-test.
- Data layer dapat di-mock untuk pengujian (mis. repository interface).
  | `MapLocationRepository` | `createFromReport()`, `getAllPublished()`, `delete()` | `MapLocation` |
  | `CategoryRepository` | `all()`, `find()`, `create()`, `update()`, `delete()` | `FacilityCategory` |

#### Interface (`app/Repositories/Contracts/`)

Setiap Repository memiliki Interface-nya:

```
app/Repositories/Contracts/
├── UserRepositoryInterface.php
├── ReportRepositoryInterface.php
├── ValidationRepositoryInterface.php
├── MapLocationRepositoryInterface.php
└── CategoryRepositoryInterface.php
```

Interface di-bind ke implementasi di `AppServiceProvider`:

```php
// app/Providers/AppServiceProvider.php
$this->app->bind(UserRepositoryInterface::class, UserRepository::class);
$this->app->bind(ReportRepositoryInterface::class, ReportRepository::class);
// dst...
```

### 5.5 Komponen Teknologi

| Komponen          | Teknologi               | Fungsi                                 |
| ----------------- | ----------------------- | -------------------------------------- |
| Backend Framework | Laravel 12              | Routing, ORM, Auth, Middleware         |
| Database          | MySQL 8                 | Penyimpanan data utama                 |
| Auth Mobile       | Laravel Sanctum         | Token-based API authentication         |
| Auth Web          | Laravel Session         | Cookie-based session untuk admin web   |
| File Storage      | Laravel Storage (local) | Penyimpanan foto laporan               |
| Template Engine   | Blade                   | Render HTML halaman web admin & publik |
| Peta Interaktif   | Leaflet.js              | Render peta di browser                 |
| CSS Framework     | Bootstrap 5             | UI komponen admin panel                |

---

## 6. Alur Proses Bisnis

### 6.1 Alur Utama: Pelaporan & Validasi

```
[Mobile User]                [Sistem]               [Admin]
     │                           │                      │
     │── Login ─────────────────►│                      │
     │◄─ Token Sanctum ──────────│                      │
     │                           │                      │
     │── Buka Menu Pelaporan ───►│                      │
     │◄─ Form + Koordinat GPS ───│                      │
     │                           │                      │
     │── Isi Form + Upload Foto ►│                      │
     │   (lat, lng, photo,       │                      │
     │    categories[])          │                      │
     │                           │── Validasi Input     │
     │                           │── Simpan Report      │
     │                           │── Simpan ReportDetails│
     │                           │── Buat Validation    │
     │                           │   (status: pending)  │
     │◄─ Response Sukses ────────│                      │
     │                           │                      │
     │                           │◄── Admin Login ──────│
     │                           │                      │
     │                           │◄── Buka Daftar Laporan│
     │                           │──► Tampil Laporan ───►│
     │                           │                      │
     │                           │◄── Review Foto/Data ─│
     │                           │◄── Submit Keputusan ─│
     │                           │    (approve/reject   │
     │                           │     + catatan)       │
     │                           │                      │
     │                           │── Update Validation  │
     │                           │   (status: approved) │
     │                           │── Insert MapLocation │
     │                           │   (koordinat dipublik│
     │                           │◄─ Konfirmasi Sukses ─│
```

### 6.2 Alur: Melihat Peta (Pengguna Publik)

```
[Browser Publik] ─── GET / ──► [PublicMapController]
                                        │
                                        ├── Ambil semua MapLocation
                                        │   (validation.approval_status = 'approved')
                                        │
                                        ├── Eager load: validation.report.reportDetails.category
                                        │
                                        └── Return view dengan data JSON marker
                                                │
                              [Leaflet.js render peta dengan marker]
                              [Klik marker → popup info fasilitas + foto]
```

### 6.3 Alur Autentikasi

#### Web Admin (Session-based)

```
POST /login ──► Cek email + password + role='admin'
             ├── Berhasil ──► Buat session, redirect /admin/dashboard
             └── Gagal    ──► Redirect /login dengan error
```

#### Mobile (Token-based Sanctum)

```
POST /api/v1/auth/login ──► Cek email + password
                         ├── Berhasil ──► Buat token, return { token, user }
                         └── Gagal    ──► Return 401 { message: "Unauthorized" }
```

---

## 7. Spesifikasi API

### 7.1 Format Response

Semua response API menggunakan format JSON standar:

```json
// Sukses
{
  "success": true,
  "message": "Laporan berhasil dikirim.",
  "data": { ... }
}

// Gagal
{
  "success": false,
  "message": "Validasi gagal.",
  "errors": { "email": ["Email sudah terdaftar."] }
}
```

### 7.2 Daftar Endpoint API

#### Auth

| Method | Endpoint                | Auth         | Request Body                                              | Response          |
| ------ | ----------------------- | ------------ | --------------------------------------------------------- | ----------------- |
| POST   | `/api/v1/auth/register` | —            | `full_name`, `email`, `password`, `password_confirmation` | `{ token, user }` |
| POST   | `/api/v1/auth/login`    | —            | `email`, `password`                                       | `{ token, user }` |
| POST   | `/api/v1/auth/logout`   | Bearer Token | —                                                         | `{ message }`     |

#### Profil

| Method | Endpoint          | Auth         | Request Body                      | Response   |
| ------ | ----------------- | ------------ | --------------------------------- | ---------- |
| GET    | `/api/v1/profile` | Bearer Token | —                                 | `{ user }` |
| PUT    | `/api/v1/profile` | Bearer Token | `full_name`, `email`, `password?` | `{ user }` |

#### Laporan

| Method | Endpoint               | Auth         | Request Body                                            | Response        |
| ------ | ---------------------- | ------------ | ------------------------------------------------------- | --------------- |
| GET    | `/api/v1/reports`      | Bearer Token | —                                                       | `{ reports[] }` |
| POST   | `/api/v1/reports`      | Bearer Token | `latitude`, `longitude`, `photo` (file), `categories[]` | `{ report }`    |
| GET    | `/api/v1/reports/{id}` | Bearer Token | —                                                       | `{ report }`    |

#### Peta & Kategori

| Method | Endpoint             | Auth | Response                               |
| ------ | -------------------- | ---- | -------------------------------------- |
| GET    | `/api/v1/map`        | —    | `{ locations[] }` (approved only)      |
| GET    | `/api/v1/map/{id}`   | —    | `{ location }` dengan detail fasilitas |
| GET    | `/api/v1/categories` | —    | `{ categories[] }`                     |

### 7.3 Struktur Response Utama

#### Report Resource

```json
{
  "report_id": 1,
  "latitude": -7.7956,
  "longitude": 110.3695,
  "photo_url": "http://sleman-akses.test/storage/reports/1/foto.jpg",
  "timestamp": "2026-05-15T19:00:00+07:00",
  "validation_status": "pending",
  "details": [
    {
      "category": "Ramp / Jalur Khusus",
      "icon_marker": "ramp.png",
      "availability_status": true
    }
  ]
}
```

#### MapLocation Resource

```json
{
  "location_id": 1,
  "latitude": -7.7956,
  "longitude": 110.3695,
  "publish_date": "2026-05-15T20:00:00+07:00",
  "facilities": [
    {
      "category": "Ramp / Jalur Khusus",
      "available": true
    }
  ],
  "photo_url": "...",
  "reported_by": "Budi Santoso"
}
```

---

## 8. Rancangan Antarmuka (UI)

### 8.1 Halaman Publik — Peta Interaktif (`/`)

**Elemen:**

- Peta Leaflet.js fullscreen sebagai background utama
- Navbar transparan: logo "Sleman Akses", tombol "Masuk Admin"
- Marker berwarna per kategori fasilitas
- MarkerCluster saat zoom out
- Panel filter kategori (floating di kanan atas)
- Popup saat klik marker: foto, nama lokasi, daftar fasilitas + status, tanggal publish

### 8.2 Halaman Login Admin (`/login`)

**Elemen:**

- Halaman dua kolom: kiri background peta blur, kanan card login
- Logo sistem + nama "Sleman Akses Admin"
- Input email + password
- Pesan error jika gagal
- Tidak ada link registrasi (admin hanya dibuat via seeder/tinker)

### 8.3 Dashboard Admin (`/admin/dashboard`)

**Elemen:**

- Sidebar: logo, menu navigasi (ikon + label)
- Topbar: nama admin, tombol logout
- 4 Stat Card: Total Laporan, Pending, Disetujui, Ditolak
- Grafik Chart.js: laporan masuk per bulan (bar chart)
- Mini peta Leaflet: lokasi yang sudah approved

### 8.4 Halaman Laporan Admin (`/admin/reports`)

**Elemen:**

- DataTables dengan kolom: No, Pengirim, Tanggal, Kategori, Status (badge), Aksi
- Filter by status (All / Pending / Approved / Rejected)
- Tombol "Lihat Detail" per baris

### 8.5 Detail & Validasi Laporan (`/admin/reports/{id}`)

**Elemen:**

- Kiri: info pengirim, timestamp, koordinat GPS, mini peta marker
- Kanan: foto laporan (klik untuk zoom)
- Bawah: tabel detail per kategori fasilitas (ada/tidak)
- Form validasi: select status + textarea catatan + tombol Submit
- Konfirmasi SweetAlert2 sebelum submit

### 8.6 Halaman Peta Admin (`/admin/map`)

**Elemen:**

- Leaflet.js fullscreen
- Sidebar list semua lokasi published
- Klik baris → pindah ke marker di peta
- Tombol hapus lokasi + konfirmasi

### 8.7 Halaman Kategori (`/admin/categories`)

**Elemen:**

- Tabel kategori + preview ikon marker
- Tombol "Tambah" → Bootstrap Modal form
- Tombol edit & hapus per baris

---

## 9. Keamanan Sistem

| Aspek             | Mekanisme                                       |
| ----------------- | ----------------------------------------------- |
| Auth API Mobile   | Laravel Sanctum (Bearer Token)                  |
| Auth Web Admin    | Laravel Session (Cookie)                        |
| Otorisasi Role    | Middleware `CheckRole` (cek `role === 'admin'`) |
| CSRF Protection   | Laravel CSRF Token pada semua form web          |
| Input Validation  | Laravel Form Request (semua input divalidasi)   |
| Upload File       | Validasi MIME type (jpg/png), max size 5MB      |
| Password          | Bcrypt hashing via Laravel Hash                 |
| API Rate Limiting | Laravel built-in `throttle:60,1` middleware     |
| Policy            | User hanya bisa akses laporan miliknya sendiri  |

---

## 10. Teknologi & Dependensi

### Backend

| Package                    | Versi | Kegunaan                      |
| -------------------------- | ----- | ----------------------------- |
| Laravel Framework          | ^12.0 | Core framework                |
| laravel/sanctum            | ^4.x  | API token authentication      |
| intervention/image-laravel | ^1.x  | Resize & optimize foto upload |
| PHP                        | ^8.2  | Runtime                       |
| MySQL                      | 8.x   | Database                      |

### Frontend (via CDN)

| Library               | Versi | Kegunaan                         |
| --------------------- | ----- | -------------------------------- |
| Bootstrap             | 5.3   | CSS framework, komponen UI       |
| Font Awesome          | 6.x   | Ikon                             |
| Leaflet.js            | 1.9   | Peta interaktif                  |
| Leaflet.MarkerCluster | 1.5   | Cluster marker peta              |
| DataTables            | 1.13  | Tabel dengan filter & pagination |
| SweetAlert2           | 11.x  | Dialog konfirmasi                |
| Chart.js              | 4.x   | Grafik dashboard                 |

---

## 11. Constraint & Batasan

| Constraint      | Keterangan                                                                  |
| --------------- | --------------------------------------------------------------------------- |
| Platform Web    | Hanya admin panel & peta publik (bukan full web app untuk pengguna)         |
| Platform Mobile | Di luar scope dokumen ini (hanya API-nya yang dirancang)                    |
| Storage Foto    | Disimpan lokal di server (bukan cloud), path: `storage/app/public/reports/` |
| Bahasa          | Sistem berbahasa Indonesia                                                  |
| Timezone        | Asia/Jakarta (WIB, UTC+7)                                                   |
| Peta Basemap    | OpenStreetMap (gratis, tanpa API key)                                       |
| Autentikasi     | Admin hanya bisa dibuat via database seeder atau CLI Tinker                 |

---

_Dokumen ini merupakan referensi rancangan sistem. Setiap perubahan signifikan pada struktur database atau alur proses harus diperbarui di dokumen ini._
