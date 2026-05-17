# Dokumentasi Sistem Sleman Akses (Ringkas + Teknis)

> Tanggal: Mei 2026
> Platform: Web Admin + Web Publik + Mobile (API)
> Backend: Laravel 12 (PHP 8.2) + MySQL

Dokumen ini merangkum arsitektur, daftar routes, dan dokumentasi per modul/folder dengan konteks arsitektur MVC + Service + Repository.

## 1. Ringkasan Arsitektur

Pola utama: MVC + Service + Repository.

Alur umum:

1. Client (Web/Mobile) mengirim HTTP request.
2. Controller memvalidasi input dan memanggil Service.
3. Service menjalankan business logic dan memanggil Repository.
4. Repository berinteraksi dengan Model (Eloquent) dan database.
5. Controller mengembalikan View (Web) atau JSON Resource (API).

Layer utama:

- Controller: app/Http/Controllers
- Service: app/Services
- Repository: app/Repositories
- Model: app/Models
- View: resources/views
- Routes: routes/web.php dan routes/api.php
- Form Request (validasi): app/Http/Requests/Api
- API Resource (formatter): app/Http/Resources

## 2. Daftar Routes

### 2.1 Web Routes (routes/web.php)

Public:

- GET / -> PublicMapController@index (name: public.map)

Auth:

- GET /login -> LoginController@showForm (name: login)
- POST /login -> LoginController@login
- POST /logout -> LoginController@logout (name: logout)

Admin (prefix /admin, middleware: auth + role:admin, name: admin.):

- GET /admin/dashboard -> DashboardController@index (admin.dashboard)
- GET /admin/reports -> Admin\ReportController@index (admin.reports.index)
- GET /admin/reports/{id} -> Admin\ReportController@show (admin.reports.show)
- POST /admin/reports/{id}/validate -> Admin\ValidationController@store (admin.reports.validate)
- GET /admin/map -> Admin\MapController@index (admin.map.index)
- DELETE /admin/map/{id} -> Admin\MapController@destroy (admin.map.destroy)
- GET /admin/categories -> Admin\CategoryController@index (admin.categories.index)
- POST /admin/categories -> Admin\CategoryController@store (admin.categories.store)
- PUT /admin/categories/{id} -> Admin\CategoryController@update (admin.categories.update)
- DELETE /admin/categories/{id} -> Admin\CategoryController@destroy (admin.categories.destroy)
- GET /admin/users -> Admin\UserController@index (admin.users.index)

### 2.2 API Routes (routes/api.php)

Prefix: /api/v1

Public:

- POST /api/v1/auth/register -> Api\AuthController@register
- POST /api/v1/auth/login -> Api\AuthController@login
- GET /api/v1/categories -> Api\CategoryController@index
- GET /api/v1/map -> Api\MapController@index
- GET /api/v1/map/{id} -> Api\MapController@show

Protected (middleware: auth:sanctum):

- POST /api/v1/auth/logout -> Api\AuthController@logout
- GET /api/v1/profile -> Api\ProfileController@show
- PUT /api/v1/profile -> Api\ProfileController@update
- GET /api/v1/reports -> Api\ReportController@index
- POST /api/v1/reports -> Api\ReportController@store
- GET /api/v1/reports/{id} -> Api\ReportController@show

## 3. Dokumentasi Modul (MVC + Service + Repository)

### 3.1 Modul Public Map (Web Publik)

Tujuan: Menampilkan peta publik dengan marker fasilitas yang sudah disetujui.

Komponen:

- Controller: app/Http/Controllers/PublicMapController.php
- Service: app/Services/MapLocationService.php, app/Services/CategoryService.php
- Repository: app/Repositories/MapLocationRepository.php, app/Repositories/CategoryRepository.php
- Model: app/Models/MapLocation.php, app/Models/Validation.php, app/Models/Report.php, app/Models/ReportDetail.php, app/Models/FacilityCategory.php
- View: resources/views/public/map.blade.php
- Layout: resources/views/layouts/public.blade.php

Alur ringkas:

- Controller memanggil MapLocationService untuk data lokasi terpublikasi.
- Data marker dirapikan (kategori, ikon, fasilitas) dan dikirim ke view.
- Maptiler API key dibaca dari config services.maptiler.key.

### 3.2 Modul Auth Web (Admin Login)

Tujuan: Login admin untuk akses dashboard.

Komponen:

- Controller: app/Http/Controllers/Auth/LoginController.php
- View: resources/views/auth/login.blade.php
- Middleware: auth + role:admin (di routes/web.php)

Alur ringkas:

- GET /login menampilkan form login.
- POST /login memvalidasi kredensial + role=admin.
- POST /logout menghapus session.

### 3.3 Modul Dashboard Admin

Tujuan: Ringkasan statistik laporan dan aktivitas.

Komponen:

- Controller: app/Http/Controllers/Admin/DashboardController.php
- Model: app/Models/Validation.php, app/Models/User.php
- Service: app/Services/MapLocationService.php
- View: resources/views/admin/dashboard/index.blade.php
- Components: resources/views/components/stat-card.blade.php

Data utama:

- Total laporan, status pending/approved/rejected, total user.
- Grafik laporan bulanan.
- 5 lokasi terakhir yang dipublikasikan.

### 3.4 Modul Laporan (Admin)

Tujuan: Meninjau dan melihat detail laporan masuk.

Komponen:

- Controller: app/Http/Controllers/Admin/ReportController.php
- Repository: app/Repositories/ReportRepository.php
- View: resources/views/admin/reports/index.blade.php, resources/views/admin/reports/show.blade.php
- Component: resources/views/components/badge-status.blade.php

Fitur:

- Filter laporan berdasarkan status (pending/approved/rejected).
- Detail laporan dengan data fasilitas dan bukti foto.

### 3.5 Modul Validasi Laporan (Admin)

Tujuan: Approve/Reject laporan dan publikasi ke peta.

Komponen:

- Controller: app/Http/Controllers/Admin/ValidationController.php
- Service: app/Services/ValidationService.php
- Repository: app/Repositories/ValidationRepository.php, app/Repositories/MapLocationRepository.php, app/Repositories/ReportRepository.php
- Model: app/Models/Validation.php, app/Models/MapLocation.php

Alur ringkas:

- Admin mengirim status approved/rejected + catatan.
- Jika approved, sistem membuat MapLocation.

### 3.6 Modul Peta Admin

Tujuan: Menampilkan lokasi yang sudah dipublikasikan dan menghapus lokasi.

Komponen:

- Controller: app/Http/Controllers/Admin/MapController.php
- Service: app/Services/MapLocationService.php
- Repository: app/Repositories/MapLocationRepository.php
- View: resources/views/admin/map/index.blade.php

Fitur:

- Tampilkan daftar lokasi terpublikasi.
- Hapus lokasi (delete).

### 3.7 Modul Kategori Fasilitas

Tujuan: CRUD kategori fasilitas umum.

Komponen:

- Controller: app/Http/Controllers/Admin/CategoryController.php
- Service: app/Services/CategoryService.php
- Repository: app/Repositories/CategoryRepository.php
- Model: app/Models/FacilityCategory.php
- View: resources/views/admin/categories/index.blade.php

Fitur:

- Tambah, ubah, hapus kategori (name + icon).

### 3.8 Modul Pengguna (Admin)

Tujuan: Daftar user mobile dan jumlah laporan.

Komponen:

- Controller: app/Http/Controllers/Admin/UserController.php
- Model: app/Models/User.php
- View: resources/views/admin/users/index.blade.php

Fitur:

- List user role=user, count reports, pagination.

### 3.9 Modul API Auth & Profil (Mobile)

Komponen:

- Controller: app/Http/Controllers/Api/AuthController.php
- Service: app/Services/AuthService.php
- Request: app/Http/Requests/Api/RegisterRequest.php, LoginRequest.php
- Controller: app/Http/Controllers/Api/ProfileController.php
- Request: app/Http/Requests/Api/UpdateProfileRequest.php
- Repository: app/Repositories/UserRepository.php

Validasi request:

- Register: full_name, email unik, password min 8 + confirmed.
- Login: email + password.
- Update profile: field opsional, email unik, password min 8 + confirmed.

### 3.10 Modul API Laporan (Mobile)

Komponen:

- Controller: app/Http/Controllers/Api/ReportController.php
- Service: app/Services/ReportService.php
- Repository: app/Repositories/ReportRepository.php, ValidationRepository.php
- Request: app/Http/Requests/Api/StoreReportRequest.php
- Resource: app/Http/Resources/ReportResource.php
- Service pendukung: app/Services/PhotoUploadService.php

Validasi request:

- latitude, longitude (range valid)
- photo (jpg/jpeg/png, max 5MB)
- categories[]: id (exists) + available (boolean)

Alur ringkas:

- Upload foto -> simpan report -> detail -> init validation pending.

### 3.11 Modul API Peta & Kategori

Komponen:

- Controller: app/Http/Controllers/Api/MapController.php
- Resource: app/Http/Resources/MapLocationResource.php
- Controller: app/Http/Controllers/Api/CategoryController.php
- Resource: app/Http/Resources/CategoryResource.php

Fitur:

- List lokasi terpublikasi.
- Detail lokasi terpublikasi.
- List kategori fasilitas.

## 4. Dokumentasi Per Folder Utama

### 4.1 app/Http/Controllers

- Api/: controller untuk REST API (Mobile).
- Admin/: controller untuk dashboard admin (Web).
- Auth/: controller login web admin.
- PublicMapController: peta publik.

### 4.2 app/Services

- AuthService: register, login, logout token.
- ReportService: create report + detail + validation.
- ValidationService: approve/reject + publish map.
- MapLocationService: fetch/delete map locations.
- CategoryService: CRUD kategori.
- PhotoUploadService: upload/resize/hapus foto.

### 4.3 app/Repositories

- Contracts/: definisi interface repository.
- Implementasi untuk User, Report, Validation, MapLocation, Category.

### 4.4 app/Models

- User, Report, ReportDetail, Validation, MapLocation, FacilityCategory.

### 4.5 app/Http/Requests/Api

- RegisterRequest, LoginRequest, UpdateProfileRequest, StoreReportRequest.

### 4.6 app/Http/Resources

- CategoryResource, ReportResource, MapLocationResource, UserResource.

### 4.7 routes

- web.php: public map + admin web.
- api.php: REST API (mobile).

### 4.8 resources/views

- layouts/: layout umum (app/public).
- components/: komponen tampilan (alert, badge-status, stat-card).
- public/: peta publik.
- auth/: login admin.
- admin/: dashboard, reports, map, categories, users.

### 4.9 database

- migrations/: struktur tabel dan relasi.
- seeders/: data awal kategori + admin.

## 5. Catatan Konfigurasi

- Auth API menggunakan Laravel Sanctum (auth:sanctum di API).
- Maptiler API Key: config/services.php -> services.maptiler.key.
- Storage publik untuk foto: storage/app/public (diakses melalui /storage).

## 6. Dokumen Pendukung

- Dokumen rancangan sistem: docs/dokumen_rancangan_sistem.md
- Rencana implementasi backend: docs/implementation_plan_backend.md
- Rencana implementasi web/mobile: docs/implementation_plan_web.md, docs/implementation_plan_mobile.md
