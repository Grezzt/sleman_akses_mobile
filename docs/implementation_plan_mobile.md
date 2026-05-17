# Sleman Akses — Mobile Implementation Plan

> **Platform:** Android / iOS (Flutter atau React Native)  
> **Scope:** Aplikasi mobile untuk pengguna publik — registrasi, login, kirim laporan GPS, lihat riwayat, lihat peta  
> **Backend API:** Semua komunikasi via REST API (`/api/v1/`) yang dibangun di backend fase B1–B7

---

## Ringkasan Fase

| #   | Fase                           | Output Utama                      | Status |
| --- | ------------------------------ | --------------------------------- | ------ |
| M1  | Setup Project & Arsitektur     | Struktur folder, dependencies     | ⬜     |
| M2  | Auth — Register & Login        | Screen register, login, logout    | ⬜     |
| M3  | Home & Peta Fasilitas          | Peta interaktif marker approved   | ⬜     |
| M4  | Kirim Laporan (Geo-tagging)    | Form laporan + GPS + foto         | ⬜     |
| M5  | Riwayat Laporan                | List laporan user + detail        | ⬜     |
| M6  | Profil Pengguna                | Lihat & edit profil               | ⬜     |
| M7  | Finalisasi & Polish            | Error handling, loading state, QA | ⬜     |

---

## FASE M1 — Setup Project & Arsitektur

### Task: Inisialisasi Project

- [ ] Buat project baru:
  ```bash
  # Flutter
  flutter create sleman_akses --org id.sleman.akses

  # atau React Native
  npx react-native init SlemanAkses
  ```

- [ ] Tentukan minimum SDK / target:
  - Android: minSdk 21 (Android 5.0+)
  - iOS: iOS 13+

### Task: Dependencies Utama

**Flutter:**
```yaml
# pubspec.yaml
dependencies:
  http: ^1.x                 # HTTP client
  flutter_map: ^6.x          # Peta interaktif (Leaflet-equivalent)
  latlong2: ^0.9.x           # Koordinat GPS
  geolocator: ^11.x          # Akses GPS device
  image_picker: ^1.x         # Ambil foto dari kamera/galeri
  shared_preferences: ^2.x   # Simpan token lokal
  provider: ^6.x             # State management
  cached_network_image: ^3.x # Cache gambar dari server
```

**React Native:**
```json
// package.json
"react-native-maps": "^1.x",
"@react-native-community/geolocation": "^3.x",
"react-native-image-picker": "^7.x",
"@react-native-async-storage/async-storage": "^1.x",
"axios": "^1.x",
"zustand": "^4.x"
```

### Task: Struktur Folder

```
lib/  (Flutter)  /  src/  (React Native)
├── api/
│   ├── api_client.dart       ← Base HTTP client (set base URL + token header)
│   ├── auth_api.dart         ← Endpoint auth
│   ├── report_api.dart       ← Endpoint laporan
│   ├── map_api.dart          ← Endpoint peta
│   └── category_api.dart     ← Endpoint kategori
├── models/
│   ├── user.dart
│   ├── report.dart
│   ├── map_location.dart
│   └── facility_category.dart
├── providers/ (atau stores/)
│   ├── auth_provider.dart
│   ├── report_provider.dart
│   └── map_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart       ← Peta interaktif
│   ├── report/
│   │   ├── report_list_screen.dart
│   │   ├── report_detail_screen.dart
│   │   └── create_report_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── loading_overlay.dart
│   ├── error_snackbar.dart
│   ├── report_card.dart
│   └── status_badge.dart
└── main.dart
```

### Task: Konfigurasi Base URL

```dart
// lib/api/api_client.dart
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2/sleman-akses/public/api/v1'; // emulator
  // static const String baseUrl = 'http://192.168.x.x/...';  // device fisik

  static String? _token;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
}
```

---

## FASE M2 — Auth: Register & Login

### Task: API Layer

- [ ] **[NEW]** `api/auth_api.dart`
  ```dart
  Future<Map> register(String name, String email, String pass)
  → POST /api/v1/auth/register
  → return { token, user }

  Future<Map> login(String email, String pass)
  → POST /api/v1/auth/login
  → return { token, user }

  Future<void> logout()
  → POST /api/v1/auth/logout  (Bearer token)
  ```

### Task: AuthProvider / Store

- [ ] **[NEW]** `providers/auth_provider.dart`
  ```dart
  class AuthProvider extends ChangeNotifier {
    User? _user;
    String? _token;
    bool _isLoading = false;

    Future<void> register(name, email, pass) { ... }
    Future<void> login(email, pass) { ... }
    Future<void> logout() { ... }
    Future<void> loadFromStorage() { ... }  // restore session dari SharedPreferences
  }
  ```
  - Simpan token ke `SharedPreferences` setelah login
  - Hapus token dari storage saat logout

### Task: Screen Register

- [ ] **[NEW]** `screens/auth/register_screen.dart`
  ```
  Elemen UI:
  - Logo + judul "Buat Akun Baru"
  - Input: Nama Lengkap, Email, Password, Konfirmasi Password
  - Tombol "Daftar"
  - Loading indicator saat proses
  - Pesan error per field (dari API validation errors)
  - Link "Sudah punya akun? Masuk"
  ```

### Task: Screen Login

- [ ] **[NEW]** `screens/auth/login_screen.dart`
  ```
  Elemen UI:
  - Logo Sleman Akses + judul "Masuk"
  - Input: Email, Password (dengan toggle show/hide)
  - Tombol "Masuk"
  - Loading indicator
  - Error snackbar jika gagal
  - Link "Belum punya akun? Daftar"
  ```

### Task: Route Guard

- [ ] Setup route guard: jika token ada di storage → langsung ke Home, jika tidak → ke Login
  ```dart
  // main.dart — SplashScreen logic
  final token = await SharedPreferences.getInstance().getString('token');
  Navigator.pushReplacementNamed(context, token != null ? '/home' : '/login');
  ```

---

## FASE M3 — Home: Peta Fasilitas Interaktif

### Task: API Layer

- [ ] **[NEW]** `api/map_api.dart`
  ```dart
  Future<List<MapLocation>> getPublishedLocations()
  → GET /api/v1/map
  → return list of MapLocation

  Future<MapLocation> getLocationDetail(int id)
  → GET /api/v1/map/{id}
  ```

- [ ] **[NEW]** `api/category_api.dart`
  ```dart
  Future<List<FacilityCategory>> getCategories()
  → GET /api/v1/categories
  ```

### Task: Models

- [ ] **[NEW]** `models/map_location.dart`
  ```dart
  class MapLocation {
    final int locationId;
    final double latitude;
    final double longitude;
    final String publishDate;
    final String? photoUrl;
    final String reportedBy;
    final List<FacilityDetail> facilities;

    factory MapLocation.fromJson(Map<String, dynamic> json) { ... }
  }
  ```

### Task: Screen Home (Peta)

- [ ] **[NEW]** `screens/home/home_screen.dart`
  ```
  Elemen UI:
  - flutter_map / MapView fullscreen (OpenStreetMap tile)
  - Marker per lokasi approved (ikon berbeda per kategori)
  - Tap marker → bottom sheet popup:
      · Foto fasilitas
      · Nama pelapor
      · Daftar fasilitas & status (✓ ada / ✗ tidak)
      · Tanggal dipublikasikan
  - Tombol filter kategori (chip/pill di bagian atas)
  - Floating button kanan bawah → "Laporkan Fasilitas" (navigasi ke CreateReport)
  - Bottom navigation bar: [Peta] [Laporan] [Profil]
  ```

---

## FASE M4 — Kirim Laporan (Geo-tagging)

### Task: API Layer

- [ ] **[NEW]** `api/report_api.dart` (fungsi create)
  ```dart
  Future<Report> createReport({
    required double latitude,
    required double longitude,
    required File photo,
    required List<Map> categories,  // [{id: 1, available: true}, ...]
  })
  → POST /api/v1/reports (multipart/form-data)
  → return Report
  ```

### Task: GPS Service

- [ ] **[NEW]** `services/gps_service.dart`
  ```dart
  Future<Position> getCurrentPosition() async {
    // Cek permission GPS
    // Jika ditolak → throw exception dengan pesan
    // return Geolocator.getCurrentPosition(accuracy: LocationAccuracy.high)
  }
  ```

### Task: Screen Create Report

- [ ] **[NEW]** `screens/report/create_report_screen.dart`

  **Step 1 — Lokasi GPS:**
  ```
  - Tombol "Ambil Lokasi GPS"
  - Tampilkan koordinat lat/lng setelah dapat
  - Mini peta preview titik lokasi
  - Indikator loading saat fetch GPS
  - Error jika GPS tidak aktif / permission ditolak
  ```

  **Step 2 — Foto:**
  ```
  - Tombol "Ambil Foto" (kamera) dan "Pilih dari Galeri"
  - Preview thumbnail foto yang dipilih
  - Validasi: wajib pilih foto, maks 5MB
  ```

  **Step 3 — Detail Fasilitas:**
  ```
  - List semua kategori fasilitas (dari API /categories)
  - Per kategori: checkbox "Tersedia" / "Tidak Tersedia"
  - Wajib pilih minimal 1 kategori
  ```

  **Kirim:**
  ```
  - Tombol "Kirim Laporan"
  - Loading overlay saat upload
  - Sukses: snackbar "Laporan berhasil dikirim" + navigasi ke Riwayat
  - Gagal: snackbar error + tetap di form
  ```

---

## FASE M5 — Riwayat Laporan

### Task: API Layer

- [ ] **[NEW]** `api/report_api.dart` (fungsi list & detail)
  ```dart
  Future<List<Report>> getUserReports()
  → GET /api/v1/reports  (Bearer token)

  Future<Report> getReportDetail(int id)
  → GET /api/v1/reports/{id}
  ```

### Task: Models

- [ ] **[NEW]** `models/report.dart`
  ```dart
  class Report {
    final int reportId;
    final double latitude, longitude;
    final String photoUrl;
    final String timestamp;
    final String validationStatus;  // pending | approved | rejected
    final List<ReportDetail> details;
    factory Report.fromJson(Map<String, dynamic> json) { ... }
  }
  ```

### Task: Screen Report List

- [ ] **[NEW]** `screens/report/report_list_screen.dart`
  ```
  Elemen UI:
  - List card laporan
    · Foto thumbnail (kiri)
    · Status badge: Pending / Disetujui / Ditolak (warna sesuai)
    · Tanggal laporan
    · Jumlah fasilitas yang dilaporkan
  - Pull-to-refresh
  - Empty state jika belum ada laporan
  - Loading skeleton saat fetch
  ```

### Task: Screen Report Detail

- [ ] **[NEW]** `screens/report/report_detail_screen.dart`
  ```
  Elemen UI:
  - Foto laporan (fullwidth, tap untuk zoom)
  - Status validasi (badge berwarna + teks)
  - Koordinat GPS (tampilkan teks lat/lng)
  - Mini peta dengan marker lokasi laporan
  - Tabel/list detail fasilitas per kategori (tersedia / tidak)
  - Catatan evaluasi admin (jika rejected)
  ```

---

## FASE M6 — Profil Pengguna

### Task: API Layer

- [ ] **[NEW]** `api/profile_api.dart`
  ```dart
  Future<User> getProfile()
  → GET /api/v1/profile  (Bearer token)

  Future<User> updateProfile({String? name, String? email, String? password})
  → PUT /api/v1/profile  (Bearer token)
  ```

### Task: Screen Profil

- [ ] **[NEW]** `screens/profile/profile_screen.dart`
  ```
  Elemen UI:
  - Avatar (inisial nama, tidak ada upload foto profil)
  - Nama lengkap + Email (read-only display)
  - Tombol "Edit Profil" → bottom sheet / halaman edit
  - Tombol "Logout" dengan konfirmasi dialog

  Form Edit:
  - Input: Nama Lengkap, Email, Password Baru (optional)
  - Tombol "Simpan"
  - Loading saat menyimpan
  - Snackbar sukses/gagal
  ```

---

## FASE M7 — Finalisasi & Polish

### Task: Global Error Handling

- [ ] Buat `interceptor` / wrapper di `ApiClient`:
  ```dart
  // Tangani response error global:
  // 401 → hapus token, redirect ke Login
  // 422 → return validation errors ke screen
  // 500 → tampilkan snackbar "Terjadi kesalahan server"
  // timeout / no connection → snackbar "Tidak ada koneksi internet"
  ```

### Task: Loading & Empty States

- [ ] Setiap screen yang fetch data harus punya:
  - `isLoading = true` → tampilkan shimmer/skeleton atau CircularProgressIndicator
  - `isLoading = false + data kosong` → tampilkan empty state widget (ikon + teks)
  - `isLoading = false + error` → tampilkan error widget + tombol retry

### Task: Permissions

- [ ] Konfigurasi permission di `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```
- [ ] Konfigurasi permission di `Info.plist` (iOS):
  ```
  NSLocationWhenInUseUsageDescription
  NSCameraUsageDescription
  NSPhotoLibraryUsageDescription
  ```

### Task: QA Checklist

- [ ] Register akun baru → auto login → masuk home
- [ ] Login dengan akun existing → token tersimpan
- [ ] Session restore: tutup-buka app → tetap login
- [ ] Logout → token terhapus → redirect login
- [ ] Peta tampil marker lokasi approved
- [ ] Tap marker → popup info fasilitas
- [ ] Filter kategori peta berjalan
- [ ] Kirim laporan: GPS aktif + foto + kategori → sukses
- [ ] Kirim laporan: GPS tidak aktif → pesan error
- [ ] Kirim laporan: foto > 5MB → validasi error dari API
- [ ] Riwayat laporan tampil dengan status badge
- [ ] Detail laporan tampil foto + fasilitas + status
- [ ] Edit profil berhasil → data terupdate
- [ ] Tidak ada koneksi → pesan error yang informatif

---

## API Endpoints yang Digunakan Mobile

| Method | Endpoint                  | Auth          | Kegunaan                      |
| ------ | ------------------------- | ------------- | ----------------------------- |
| POST   | `/api/v1/auth/register`   | —             | Daftar akun baru              |
| POST   | `/api/v1/auth/login`      | —             | Login, dapat token            |
| POST   | `/api/v1/auth/logout`     | Bearer Token  | Logout, hapus token           |
| GET    | `/api/v1/profile`         | Bearer Token  | Lihat profil                  |
| PUT    | `/api/v1/profile`         | Bearer Token  | Update profil                 |
| GET    | `/api/v1/categories`      | —             | Daftar kategori fasilitas     |
| GET    | `/api/v1/map`             | —             | Semua lokasi approved         |
| GET    | `/api/v1/map/{id}`        | —             | Detail satu lokasi            |
| GET    | `/api/v1/reports`         | Bearer Token  | Riwayat laporan user          |
| POST   | `/api/v1/reports`         | Bearer Token  | Kirim laporan baru            |
| GET    | `/api/v1/reports/{id}`    | Bearer Token  | Detail satu laporan           |

---

*Tandai setiap item dengan `[x]` saat selesai dikerjakan.*
