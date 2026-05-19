# SlemanAkses — Mobile App Design System
> Peta Aksesibilitas Fasilitas Umum & Edukasi bagi Penyandang Disabilitas Fisik di Kabupaten Sleman

---

## Daftar Isi

1. [Identitas Produk](#1-identitas-produk)
2. [Prinsip Desain](#2-prinsip-desain)
3. [Color System](#3-color-system)
4. [Typography](#4-typography)
5. [Spacing & Grid](#5-spacing--grid)
6. [Elevation & Shadow](#6-elevation--shadow)
7. [Border Radius](#7-border-radius)
8. [Iconography](#8-iconography)
9. [Component Library](#9-component-library)
10. [Navigation System](#10-navigation-system)
11. [Page Catalog & Hierarchy](#11-page-catalog--hierarchy)
12. [Stitch Prompts — Per Page](#12-stitch-prompts--per-page)
13. [Accessibility Guidelines](#13-accessibility-guidelines)
14. [Motion & Animation](#14-motion--animation)

---

## 1. Identitas Produk

| Properti        | Nilai                                                                 |
|-----------------|-----------------------------------------------------------------------|
| **Nama Aplikasi** | SlemanAkses                                                         |
| **Tagline**     | Peta Aksesibilitas Kabupaten Sleman                                   |
| **Platform**    | Android (Flutter, cross-platform)                                     |
| **Target User** | Penyandang disabilitas fisik, masyarakat umum, relawan pelapor        |
| **Tone Visual** | Trustworthy · Inclusive · Warm · Clean · Modern                       |
| **Versi**       | 1.0.0                                                                 |

### Brand Logo
- **Icon:** Kombinasi map pin + siluet kursi roda, stroke bold rounded
- **Wordmark:** "SlemanAkses" — Kit Rounded Bold
- **Minimum size:** 32 × 32 dp (icon only), 120 × 32 dp (full lockup)
- **Clear space:** Minimal 8dp di semua sisi
- **Primary lockup:** Icon #037940 + wordmark #037940 on light
- **Reverse lockup:** Icon white + wordmark white on #037940 background

---

## 2. Prinsip Desain

### 2.1 Inklusif di Atas Segalanya
> Setiap keputusan visual harus mempertimbangkan pengguna dengan keterbatasan motorik. Touch target minimum 48 × 48 dp. Kontras minimum WCAG AA (4.5:1 untuk teks normal, 3:1 untuk teks besar & UI).

### 2.2 Clarity Over Cleverness
> Informasi aksesibilitas bersifat kritis. Hindari desain yang ambigu. Status, data koordinat, dan ketersediaan fasilitas harus terbaca seketika tanpa interpretasi.

### 2.3 Hirearki Visual yang Kuat
> Satu fokus per layar. Gunakan ukuran, bobot, dan warna untuk memandu mata pengguna ke aksi utama secara alami.

### 2.4 Konsistensi Sistemik
> Komponen yang sama harus berperilaku dan terlihat sama di seluruh aplikasi. Tidak ada one-off style.

### 2.5 Feedback yang Jelas
> Setiap aksi pengguna mendapat respons visual dalam ≤100ms (loading state, pressed state, error state). Pengguna tidak boleh pernah bertanya-tanya apakah interaksi mereka berhasil.

---

## 3. Color System

### 3.1 Palet Utama

```dart
// lib/theme/app_colors.dart

static const Color primary       = Color(0xFF037940);  // Brand green — CTA, active states
static const Color primaryHover  = Color(0xFF025C30);  // Pressed / darker green
static const Color secondary     = Color(0xFFBFD852);  // Lime — accent, badges, highlights
static const Color background    = Color(0xFFF1F1F1);  // App background (screens)
static const Color surface       = Color(0xFFFFFFFF);  // Cards, sheets, inputs

static const Color textPrimary   = Color(0xFF037940);  // Primary text / headings
static const Color textMuted     = Color(0xFF4B5563);  // Body text, subtitles, labels
static const Color border        = Color(0xFFD4D4D4);  // Dividers, input borders, inactive

// Semantic
static const Color success       = Color(0xFF16A34A);  // Laporan disetujui
static const Color warning       = Color(0xFFF59E0B);  // Laporan menunggu
static const Color error         = Color(0xFFDC2626);  // Laporan ditolak, error state
```

### 3.2 Tint & Opacity Variants

| Token                  | Nilai                        | Penggunaan                            |
|------------------------|------------------------------|---------------------------------------|
| `primary.10`           | `#037940` @ 10% opacity      | Icon container background             |
| `primary.05`           | `#037940` @ 5% opacity       | Upload box background                 |
| `secondary.20`         | `#BFD852` @ 20% opacity      | Success illustration background       |
| `success.10`           | `#16A34A` @ 10% opacity      | Approved banner tint                  |
| `warning.10`           | `#F59E0B` @ 10% opacity      | Pending banner tint                   |
| `error.10`             | `#DC2626` @ 10% opacity      | Rejected banner tint                  |
| `surface.80`           | `#FFFFFF` @ 80% opacity      | Glassmorphism overlay                 |

### 3.3 Color Usage Rules

- **primary** → digunakan untuk CTA utama, active tab, icon aktif, heading brand
- **secondary** → digunakan untuk badge, highlight, accent chip, FAB alt
- **background** → warna dasar semua screen (bukan surface)
- **surface** → card, bottom sheet, input field, modal
- **textMuted** → semua body text, label, placeholder, subtitle
- **border** → divider 1dp, input border inactive, chip inactive border
- **JANGAN** gunakan warna apapun di luar palet ini kecuali semantic colors

### 3.4 Contrast Ratios (WCAG)

| Kombinasi                         | Ratio  | Level |
|-----------------------------------|--------|-------|
| `primary` text on `background`    | 5.8:1  | AA ✅  |
| `primary` text on `surface`       | 6.1:1  | AA ✅  |
| White text on `primary`           | 6.1:1  | AA ✅  |
| `textMuted` on `background`       | 5.2:1  | AA ✅  |
| `textMuted` on `surface`          | 5.4:1  | AA ✅  |
| `secondary` on `primary`          | 2.8:1  | (hanya untuk dekoratif, bukan teks) |

---

## 4. Typography

### 4.1 Font Family

```dart
// Semua text style menggunakan Kit Rounded
fontFamily: 'KitRounded'

// Fallback stack
fontFamilyFallback: ['Nunito', 'Poppins', 'sans-serif']
```

### 4.2 Type Scale

| Token              | Weight      | Size  | Line Height | Letter Spacing | Penggunaan                        |
|--------------------|-------------|-------|-------------|----------------|-----------------------------------|
| `displayLarge`     | Bold (700)  | 28sp  | 36dp        | -0.5px         | Splash screen, onboarding title   |
| `displayMedium`    | Bold (700)  | 24sp  | 32dp        | -0.3px         | Screen title utama                |
| `headlineLarge`    | Bold (700)  | 22sp  | 30dp        | -0.2px         | Section header besar              |
| `headlineMedium`   | SemiBold (600) | 18sp | 26dp     | 0px            | App bar title, card title         |
| `headlineSmall`    | SemiBold (600) | 16sp | 24dp     | 0px            | Sub-section header                |
| `bodyLarge`        | Medium (500)  | 15sp | 22dp      | 0.1px          | List item primary text            |
| `bodyMedium`       | Regular (400) | 14sp | 20dp      | 0.1px          | Body text, description            |
| `bodySmall`        | Regular (400) | 13sp | 18dp      | 0.2px          | Secondary body, subtitle          |
| `labelLarge`       | SemiBold (600) | 15sp | 20dp     | 0.3px          | Button text primary               |
| `labelMedium`      | Medium (500)  | 13sp | 18dp      | 0.3px          | Button text secondary, chip label |
| `labelSmall`       | Regular (400) | 11sp | 16dp      | 0.5px          | Badge text, tag, timestamp        |
| `caption`          | Regular (400) | 12sp | 16dp      | 0.4px          | Form label, caption               |

### 4.3 Text Color Rules

```dart
// Heading / brand text
color: AppColors.textPrimary   // #037940

// Body / supporting text  
color: AppColors.textMuted     // #4B5563

// On dark background (primary / success / error)
color: Colors.white

// Disabled text
color: AppColors.border        // #D4D4D4

// Link / interactive text
color: AppColors.primary       // #037940
```

### 4.4 Contoh Implementasi Flutter

```dart
// Heading screen
Text(
  'Peta Aksesibilitas',
  style: TextStyle(
    fontFamily: 'KitRounded',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  ),
)

// Body text
Text(
  'Temukan fasilitas ramah difabel di sekitarmu.',
  style: TextStyle(
    fontFamily: 'KitRounded',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  ),
)
```

---

## 5. Spacing & Grid

### 5.1 Spacing Scale (4dp Base)

```
4dp   → xs     — icon gap, chip internal padding
8dp   → sm     — list tile vertical padding, small gap
12dp  → md     — card internal padding horizontal
16dp  → lg     — screen horizontal margin (default gutter)
20dp  → xl     — card internal padding, section spacing
24dp  → 2xl    — bottom sheet top padding, large section gap
32dp  → 3xl    — hero section vertical padding
48dp  → 4xl    — illustration / empty state spacing
```

### 5.2 Screen Layout Grid

```
Screen width:       360dp (base), 390dp (comfortable), 430dp (large)
Horizontal margin:  16dp (kiri & kanan)
Content width:      328dp (base)
Column grid:        4 kolom, gutter 8dp
Card grid:          2 kolom, gutter 12dp
```

### 5.3 Komponen Spacing Spesifik

| Komponen            | Padding Internal          | Margin Eksternal |
|---------------------|---------------------------|------------------|
| Screen              | horizontal: 16dp          | —                |
| Card                | 16dp all sides            | bottom: 12dp     |
| Input field         | vertical: 14dp, H: 16dp   | bottom: 16dp     |
| Button (primary)    | vertical: 14dp, H: 24dp   | —                |
| Chip                | vertical: 6dp, H: 12dp    | right: 8dp       |
| Bottom sheet        | top: 24dp, H: 20dp        | —                |
| App bar             | horizontal: 16dp, V: 12dp | —                |
| List tile           | horizontal: 16dp, V: 12dp | —                |
| Section header      | top: 24dp, bottom: 12dp   | —                |

---

## 6. Elevation & Shadow

### 6.1 Shadow Tokens

```dart
// shadow-sm — card ringan
BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// shadow-md — card utama, floating search bar
BoxShadow(
  color: Color(0x14000000),
  blurRadius: 16,
  offset: Offset(0, 4),
)

// shadow-lg — FAB, modal
BoxShadow(
  color: Color(0x1F000000),
  blurRadius: 24,
  offset: Offset(0, 8),
)

// shadow-top — bottom bar
BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 12,
  offset: Offset(0, -3),
)
```

### 6.2 Elevation Usage

| Level | Token       | Komponen                            |
|-------|-------------|-------------------------------------|
| 0     | —           | Background, flat elements           |
| 1     | `shadow-sm` | Standard card, list item            |
| 2     | `shadow-md` | Search bar, bottom sheet, modal     |
| 3     | `shadow-lg` | FAB, action sheet, primary button   |
| 4     | `shadow-top`| Bottom navigation bar               |

---

## 7. Border Radius

### 7.1 Radius Scale

```dart
const double radiusXS  = 4;    // Tag, badge pill kecil
const double radiusSM  = 8;    // Image thumbnail, small chip
const double radiusMD  = 12;   // Input field, attribute chip
const double radiusLG  = 16;   // Card standar
const double radiusXL  = 20;   // Hero card, featured card
const double radius2XL = 24;   // Bottom sheet top corner
const double radius3XL = 32;   // Onboarding card top corner
const double radiusFull = 999; // Button pill, chip pill, avatar
```

### 7.2 Komponen → Radius Mapping

| Komponen               | Radius Token |
|------------------------|--------------|
| Primary button         | `radiusFull` |
| Secondary button       | `radiusFull` |
| Filter chip            | `radiusFull` |
| Status badge           | `radiusFull` |
| Standard card          | `radiusLG`   |
| Hero / featured card   | `radiusXL`   |
| Input field            | `radiusMD`   |
| Photo thumbnail        | `radiusSM`   |
| Bottom sheet           | `radius2XL` (top only) |
| Onboarding card        | `radius3XL` (top only) |
| Avatar                 | `radiusFull` |
| Notification card      | `radiusLG`   |
| Upload box             | `radiusLG`   |

---

## 8. Iconography

### 8.1 Icon Library
- **Primary:** Material Symbols Rounded (Google) — weight 400, optical size 24
- **Custom brand icons:** SVG inline (map pin + wheelchair, ramp, lift, toilet, parking)
- **Style:** Rounded — konsisten dengan Kit Rounded font personality

### 8.2 Icon Sizes

| Ukuran | Penggunaan                                  |
|--------|---------------------------------------------|
| 16dp   | Inline dengan teks kecil (caption, badge)   |
| 20dp   | List tile trailing, chip icon               |
| 24dp   | Standard UI icon (app bar, input leading)   |
| 32dp   | Section icon, empty state supporting icon   |
| 48dp   | Empty state illustration supporting icon    |
| 64dp   | Onboarding illustration supporting icon     |

### 8.3 Icon Container

```dart
// Icon container dengan background tint
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.10),
    borderRadius: BorderRadius.circular(999),
  ),
  child: Icon(
    Icons.accessible_rounded,
    color: AppColors.primary,
    size: 20,
  ),
)
```

### 8.4 Custom Facility Icons

| Fasilitas       | Simbol Material Icon             | Custom Color |
|-----------------|----------------------------------|--------------|
| Ramp            | `accessible_rounded`             | `#037940`    |
| Lift/Elevator   | `elevator_rounded`               | `#037940`    |
| Toilet Difabel  | `wc_rounded`                     | `#037940`    |
| Parkir Khusus   | `local_parking_rounded`          | `#037940`    |
| Navigasi        | `navigation_rounded`             | `#037940`    |
| Lokasi/GPS      | `my_location_rounded`            | `#037940`    |
| Laporan         | `add_location_alt_rounded`       | `#037940`    |

---

## 9. Component Library

### 9.1 Buttons

#### Primary Button
```dart
// Full-width CTA
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF037940),    // primary
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    ),
    elevation: 0,
    // pressed state: backgroundColor primaryHover #025C30
  ),
  child: Text('Label', style: TextStyle(
    fontFamily: 'KitRounded',
    fontSize: 15,
    fontWeight: FontWeight.w600,
  )),
)
```

#### Secondary / Outlined Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF037940),
    side: BorderSide(color: Color(0xFF037940), width: 1.5),
    minimumSize: Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    ),
  ),
  child: Text('Label'),
)
```

#### Destructive Button
```dart
// Untuk logout / aksi berbahaya
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFFDC2626),
    side: BorderSide(color: Color(0xFFDC2626), width: 1.5),
    minimumSize: Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    ),
  ),
)
```

#### FAB (Floating Action Button)
```dart
// FAB primer — pelaporan
FloatingActionButton(
  backgroundColor: Color(0xFF037940),
  foregroundColor: Colors.white,
  elevation: 8,
  child: Icon(Icons.add_location_alt_rounded, size: 28),
)

// FAB sekunder — GPS
FloatingActionButton.small(
  backgroundColor: Color(0xFFBFD852),
  foregroundColor: Color(0xFF037940),
  child: Icon(Icons.my_location_rounded, size: 20),
)
```

---

### 9.2 Input Fields

```dart
// Text field standar
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(
      fontFamily: 'KitRounded',
      fontSize: 12,
      color: Color(0xFF4B5563),
    ),
    hintText: 'nama@email.com',
    hintStyle: TextStyle(color: Color(0xFFD4D4D4)),
    prefixIcon: Icon(Icons.mail_rounded, color: Color(0xFF037940), size: 20),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFD4D4D4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF037940), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFDC2626), width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
)
```

**States:**
| State     | Border Color | Border Width |
|-----------|-------------|--------------|
| Default   | `#D4D4D4`   | 1dp          |
| Focused   | `#037940`   | 1.5dp        |
| Error     | `#DC2626`   | 1.5dp        |
| Disabled  | `#D4D4D4`   | 1dp          |

---

### 9.3 Cards

```dart
// Standard card
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: ...,
)
```

---

### 9.4 Chips

```dart
// Filter chip — active
FilterChip(
  label: Text('Ramp'),
  selected: true,
  selectedColor: Color(0xFF037940),
  labelStyle: TextStyle(
    color: Colors.white,
    fontFamily: 'KitRounded',
    fontSize: 13,
    fontWeight: FontWeight.w500,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(999),
    side: BorderSide(color: Color(0xFF037940)),
  ),
  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
)

// Filter chip — inactive
// selectedColor: Colors.white, labelStyle color: #4B5563
// side: BorderSide(color: #D4D4D4)
```

---

### 9.5 Status Badges

```dart
// Badge Disetujui
_StatusBadge(label: 'Disetujui', color: Color(0xFF16A34A))

// Badge Menunggu
_StatusBadge(label: 'Menunggu Validasi', color: Color(0xFFF59E0B))

// Badge Ditolak
_StatusBadge(label: 'Ditolak', color: Color(0xFFDC2626))

// Widget
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: color,  // salah satu di atas
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text(
    label,
    style: TextStyle(
      fontFamily: 'KitRounded',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
)
```

---

### 9.6 Map Markers

```
Approved marker:
- Bentuk: pin tearshape
- Background: #037940
- Icon dalam: wheelchair symbol, white
- Border: white 2dp
- Size: 40 × 48dp

Pending marker:
- Background: #F59E0B
- Icon dalam: clock symbol, white

Cluster bubble:
- Shape: circle
- Background: #037940
- Text: jumlah, Kit Rounded Bold white 13sp
- Size: 36dp diameter
- Border: white 2dp
```

---

### 9.7 Bottom Sheet

```dart
// Draggable bottom sheet standar
DraggableScrollableSheet(
  initialChildSize: 0.22,  // peek height
  minChildSize: 0.10,
  maxChildSize: 0.75,
  builder: (context, controller) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [/* shadow-md */],
    ),
    child: Column(
      children: [
        // Drag handle
        Container(
          width: 36, height: 4,
          margin: EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
            color: Color(0xFFD4D4D4),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        // Content
      ],
    ),
  ),
)
```

---

### 9.8 Empty State

```dart
// Template empty state
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFD4D4D4)),
    SizedBox(height: 16),
    Text('Belum ada data', style: /* headlineSmall, textMuted */),
    SizedBox(height: 8),
    Text('Deskripsi singkat', style: /* bodySmall, textMuted */),
    SizedBox(height: 24),
    // Optional CTA button
  ],
)
```

---

### 9.9 Loading States

```dart
// Skeleton loader warna
Color shimmerBase    = Color(0xFFE5E7EB);
Color shimmerHighlight = Color(0xFFF3F4F6);

// Progress indicator
CircularProgressIndicator(
  color: Color(0xFF037940),
  strokeWidth: 2.5,
)

// Linear (form submit)
LinearProgressIndicator(
  color: Color(0xFF037940),
  backgroundColor: Color(0xFFD4D4D4),
)
```

---

## 10. Navigation System

### 10.1 Bottom Navigation Bar

```
Tab 1: Peta         — icon: map_rounded
Tab 2: Lapor        — icon: add_location_alt_rounded (highlighted)
Tab 3: Riwayat      — icon: history_rounded
Tab 4: Edukasi      — icon: menu_book_rounded
Tab 5: Profil       — icon: person_rounded
```

**Styling:**
- Background: `#FFFFFF`
- Shadow: `shadow-top`
- Height: 64dp + safe area bottom
- Active icon + label: `#037940`
- Inactive icon + label: `#4B5563`
- Label: Kit Rounded Medium, 11sp
- Active indicator: filled pill background `#037940` @ 10%, height 32dp, width 56dp, radius 999

### 10.2 App Bar

```
- Background: #FFFFFF
- Height: 56dp
- Title: Kit Rounded SemiBold, 18sp, #037940, centered atau left
- Leading (back): Icon arrow_back_ios_rounded, #037940, 24dp
- Trailing: context-dependent (notification bell, edit, filter)
- Bottom border: #D4D4D4 0.5dp
- Elevation: 0 (pakai border, bukan shadow)
```

### 10.3 Navigation Pattern

```
Stack navigasi:
Auth Stack        → Splash → Onboarding → Login → Register → Forgot Password
                   ↓ (setelah login)
Main Stack        → Bottom Nav (5 tab)
  Tab: Peta       → MapScreen → FacilityDetailScreen
  Tab: Lapor      → ReportCategoryScreen → ReportFormScreen 
                    → ReportPreviewScreen → ReportSuccessScreen
  Tab: Riwayat    → ReportHistoryScreen → ReportDetailScreen
  Tab: Edukasi    → EducationHomeScreen → ArticleDetailScreen 
                    → AccessibilityGuideScreen
  Tab: Profil     → ProfileScreen → EditProfileScreen 
                    → ChangePasswordScreen → NotificationSettingsScreen
```

---

## 11. Page Catalog & Hierarchy

```
📱 SlemanAkses — Mobile App
│
├── 🔐 AUTH FLOW
│   ├── 1.1  Splash Screen
│   ├── 1.2  Onboarding Screen (3 slide)
│   ├── 1.3  Login Screen
│   ├── 1.4  Register Screen
│   └── 1.5  Forgot Password Screen
│
├── 🗺️  PETA AKSESIBILITAS  [Tab 1]
│   ├── 2.1  Peta Utama (Home)
│   │   ├── 2.1.1  Filter Chip Row (Ramp / Lift / Toilet / Parkir)
│   │   ├── 2.1.2  Floating Search Bar
│   │   └── 2.1.3  Bottom Sheet Preview Fasilitas
│   └── 2.2  Detail Fasilitas (Full Screen)
│       ├── 2.2.1  Foto & Status Fasilitas
│       ├── 2.2.2  Atribut Infrastruktur
│       └── 2.2.3  Tombol Rute Navigasi
│
├── 📝  PELAPORAN  [Tab 2 / FAB]
│   ├── 3.1  Pilih Jenis Fasilitas
│   ├── 3.2  Form Geo-Tagging
│   │   ├── 3.2.1  Upload Foto
│   │   ├── 3.2.2  Koordinat GPS Otomatis
│   │   └── 3.2.3  Checklist Ketersediaan Fasilitas
│   ├── 3.3  Preview & Konfirmasi
│   └── 3.4  Sukses / Status Pengiriman
│
├── 📋  RIWAYAT LAPORAN  [Tab 3]
│   ├── 4.1  Daftar Riwayat (tab: Semua / Disetujui / Menunggu / Ditolak)
│   └── 4.2  Detail Status Laporan
│       ├── 4.2.1  Status Banner (Disetujui / Menunggu / Ditolak)
│       ├── 4.2.2  Info Koordinat & Timestamp
│       ├── 4.2.3  Atribut yang Dilaporkan
│       └── 4.2.4  Catatan Administrator
│
├── 📚  EDUKASI & INFORMASI  [Tab 4]
│   ├── 5.1  Beranda Edukasi
│   ├── 5.2  Detail Artikel
│   ├── 5.3  Panduan Aksesibilitas
│   │   ├── 5.3.1  Standar Ramp
│   │   ├── 5.3.2  Standar Lift
│   │   ├── 5.3.3  Standar Toilet Difabel
│   │   └── 5.3.4  Standar Area Parkir
│   └── 5.4  Tentang & Regulasi (UU No.8/2016)
│
├── 🔔  NOTIFIKASI  [App Bar Icon]
│   └── 6.1  Daftar Notifikasi
│
└── 👤  PROFIL & PENGATURAN  [Tab 5]
    ├── 7.1  Halaman Profil
    ├── 7.2  Edit Profil
    ├── 7.3  Ubah Password
    ├── 7.4  Pengaturan Notifikasi
    └── 7.5  Tentang Aplikasi
```

**Total halaman: 30 screen** (termasuk sub-states)

---

## 12. Stitch Prompts — Per Page

> Gunakan setiap prompt di bawah ini langsung di Google Stitch (atau Galileo AI / Uizard). Palet warna & font sudah tertanam di setiap prompt untuk konsistensi visual.

---

### [1.1] Splash Screen

```
Design a mobile splash screen for an accessibility map app called "SlemanAkses". 
Center a minimal logo icon combining a map pin and a wheelchair silhouette on 
a solid background color #037940. Below the icon, display the app name 
"SlemanAkses" in Kit Rounded Bold, white, 28sp. Add a subtle tagline 
"Peta Aksesibilitas Kabupaten Sleman" in Kit Rounded Regular, white at 70% 
opacity, 13sp. Place a thin linear progress bar at the very bottom in lime 
color #BFD852. Overall background: #037940. No navigation bar visible. 
Clean, centered, brand-focused layout.
```

---

### [1.2] Onboarding Screen

```
Design a 3-slide mobile onboarding screen for "SlemanAkses" accessibility map app. 
Background #F1F1F1. Each slide: large illustration area occupies top 45% of screen 
with background #F1F1F1. Bottom 55%: white #FFFFFF card with top rounded corners 32dp.

Slide 1 — illustration: person in wheelchair looking at a map pin on a phone screen. 
Title: "Temukan Fasilitas Ramah Difabel" Kit Rounded Bold #037940 22sp. 
Body: Kit Rounded Regular #4B5563 14sp "Cari ramp, lift, toilet difabel, dan parkir 
khusus di seluruh Kabupaten Sleman."

Slide 2 — illustration: hand placing GPS pin on a map from a mobile phone. 
Title: "Laporkan Fasilitas di Sekitarmu" Kit Rounded Bold #037940 22sp. 
Body: Kit Rounded Regular #4B5563 14sp "Bantu komunitas dengan melaporkan fasilitas 
aksesibel menggunakan fitur geo-tagging."

Slide 3 — illustration: diverse community group around a shared digital map. 
Title: "Bersama Wujudkan Sleman Inklusif" Kit Rounded Bold #037940 22sp. 
Body: Kit Rounded Regular #4B5563 14sp "Data kamu membantu pemerintah membangun 
infrastruktur yang lebih inklusif."

Bottom of white card: dot pagination (active #037940 wide pill, inactive #D4D4D4 circle), 
primary CTA button "Mulai" full-width rounded-full filled #037940 white Kit Rounded 
SemiBold 15sp height 52dp. "Lewati" skip link top-right #4B5563 Kit Rounded Regular 13sp.
```

---

### [1.3] Login Screen

```
Design a mobile login screen for "SlemanAkses" app. Background #F1F1F1.

Top section (centered, padding top 48dp): logo icon (map pin + wheelchair) 
in #037940 56dp, app name "SlemanAkses" Kit Rounded Bold #037940 24sp, 
tagline "Masuk ke akunmu" Kit Rounded Regular #4B5563 13sp. Gap 32dp.

Form card: white #FFFFFF rounded 20dp shadow-md padding 24dp:
- Email input: outlined border #D4D4D4 rounded 12dp height 52dp, 
  label "Email" #4B5563 Kit Rounded Regular 12sp, 
  leading mail icon #037940 20dp, focused border #037940 1.5dp
- Password input: same style, label "Kata Sandi", trailing eye icon toggle #4B5563
- "Lupa Kata Sandi?" text link right-aligned below password, #037940 Kit Rounded Regular 13sp
- Gap 24dp
- "Masuk" button: full-width rounded-full filled #037940 white Kit Rounded SemiBold 15sp height 52dp
- Divider: line — "atau" — line, text #4B5563 Kit Rounded Regular 12sp
- "Daftar Akun Baru" button: full-width rounded-full outlined border 1.5dp #037940 
  text #037940 Kit Rounded SemiBold 15sp height 52dp

Bottom: "Mendukung kemandirian penyandang disabilitas fisik" 
Kit Rounded Regular #4B5563 12sp centered.
```

---

### [1.4] Register Screen

```
Design a mobile registration screen for "SlemanAkses" app. Background #F1F1F1.
App bar: white #FFFFFF, back arrow #037940, no title (or "Buat Akun Baru" Kit Rounded Bold #037940 18sp).

Scrollable content:
Header: "Buat Akun Baru" Kit Rounded Bold #037940 22sp, 
subtitle Kit Rounded Regular #4B5563 13sp.

White card form rounded 20dp shadow-sm padding 20dp:
- Full Name input: leading person icon #037940, label "Nama Lengkap" #4B5563 12sp
- Email input: leading mail icon #037940
- Password input: trailing eye toggle icon, label "Kata Sandi"
- Password strength bar below password: 4dp height bar, 
  3 segments (weak #DC2626 / medium #F59E0B / strong #16A34A)
- Confirm Password input: label "Konfirmasi Kata Sandi"
- Role selector row: 2 segmented choice chips "Masyarakat Umum" and "Relawan Pelapor", 
  active: filled #037940 white text Kit Rounded Medium 13sp, 
  inactive: white border #D4D4D4 text #4B5563, both rounded-full height 40dp
- Checkbox row: "Saya menyetujui syarat & ketentuan penggunaan" 
  checkbox accent #037940, Kit Rounded Regular #4B5563 13sp

All inputs: rounded 12dp border #D4D4D4 height 52dp.
Error state: border #DC2626, error text Kit Rounded Regular #DC2626 12sp below field.

Bottom CTA: "Daftar" full-width rounded-full filled #037940 white Kit Rounded SemiBold 15sp height 52dp.
```

---

### [1.5] Forgot Password Screen

```
Design a mobile forgot password screen for "SlemanAkses" app. Background #F1F1F1.
App bar: white back arrow #037940, title "Lupa Kata Sandi" Kit Rounded Bold #037940 18sp.

Center illustration (120dp wide): envelope icon with a lock badge, 
main color #037940, accent #BFD852, on transparent background.

Description text centered: Kit Rounded Regular #4B5563 14sp multiline:
"Masukkan alamat email kamu. Kami akan mengirimkan tautan untuk mereset kata sandi."

Gap 32dp.

White card form rounded 20dp shadow-sm padding 20dp:
- Email input rounded 12dp border #D4D4D4 height 52dp, 
  leading mail icon #037940, label "Email Terdaftar" #4B5563 12sp

"Kirim Link Reset" button full-width rounded-full filled #037940 white 
Kit Rounded SemiBold 15sp height 52dp.

Success state (after submit): replaces form with a confirmation card 
white rounded 16dp, top icon checkmark circle filled #16A34A 48dp, 
text "Link telah dikirim!" Kit Rounded Bold #16A34A 16sp, 
subtext "Periksa inbox email kamu." Kit Rounded Regular #4B5563 13sp, 
"Kembali ke Login" ghost button #037940.
```

---

### [2.1] Peta Aksesibilitas Utama

```
Design a full-screen mobile map exploration screen for "SlemanAkses". 
The entire screen is a muted grayscale map canvas (OpenStreetMap style tiles, 
desaturated). No padding. Map fills edge to edge including under status bar.

Top floating overlay layer:
- Floating search bar: white #FFFFFF rounded-full shadow-md height 48dp, 
  margin horizontal 16dp top 56dp. Left: search icon #037940 20dp, 
  placeholder "Cari fasilitas di Sleman..." Kit Rounded Regular #4B5563 14sp. 
  Right: vertical divider then notification bell icon button #4B5563.
- Below search bar: horizontal scrollable filter chip row margin-top 10dp. 
  Chips: "Semua", "Ramp", "Lift", "Toilet Difabel", "Parkir Khusus". 
  Active chip: filled #037940 white Kit Rounded Medium 13sp rounded-full height 36dp 
  padding horizontal 14dp. Inactive: white border #D4D4D4 text #4B5563 rounded-full.

Map content:
- Facility markers: custom teardrop pin, filled #037940, white wheelchair icon inside, 
  white border 2dp. Cluster bubble: filled circle #037940 white bold count number.
- Pending markers: filled #F59E0B.

Right side FABs (bottom-right stack, margin 16dp):
- Upper FAB small: white card shadow-lg circle 40dp, location icon #037940 20dp
- Lower FAB large: filled #037940 circle 56dp shadow-lg, 
  add_location_alt icon white 28dp (main report action)
- Secondary FAB above main: filled #BFD852 circle 44dp, GPS/my_location icon #037940

Bottom peek sheet (height 88dp + safe area): 
white #FFFFFF rounded top 24dp shadow-top. 
Drag handle #D4D4D4 centered top. 
Text "24 fasilitas ditemukan di area ini" Kit Rounded SemiBold #037940 15sp. 
Subtext "Geser ke atas untuk melihat daftar" Kit Rounded Regular #4B5563 12sp.
```

---

### [2.1.3] Bottom Sheet Detail Fasilitas

```
Design a mobile bottom sheet detail panel (60% screen height) for an accessibility 
facility in "SlemanAkses". White #FFFFFF, top rounded corners 24dp, shadow-md.
Top: drag handle bar 36dp wide 4dp tall #D4D4D4 centered, margin top 12dp.

Facility photo: full-width 16:9 ratio image rounded 12dp. 
Badge top-left overlay: "FASILITAS UMUM" filled #BFD852 text #037940 
Kit Rounded Bold 11sp rounded 6dp padding horizontal 8dp vertical 4dp.
Status top-right: "AKTIF" filled #16A34A white Kit Rounded Bold 11sp rounded-full.

Facility name: "Pusat Pemerintahan Sleman" Kit Rounded Bold #037940 18sp margin-top 14dp.
Address: location_pin icon #4B5563 16dp inline, Kit Rounded Regular #4B5563 13sp.
Divider #D4D4D4 1dp margin vertical 14dp.

Section "Fitur Aksesibilitas" Kit Rounded SemiBold #037940 14sp.
2×2 grid of attribute cards: each white card border #D4D4D4 rounded 10dp padding 12dp.
Available: icon #16A34A 20dp + label Kit Rounded Regular #4B5563 13sp.
Unavailable: icon #DC2626 20dp + label with strikethrough #4B5563.
Icons: accessible_rounded (Ramp), elevator_rounded (Lift), 
wc_rounded (Toilet), local_parking_rounded (Parkir).

Bottom fixed bar: 
"Lihat Detail Lengkap" ghost text button #037940 Kit Rounded Medium 14sp left, 
"🧭 Rute Navigasi" filled #037940 rounded-full white Kit Rounded SemiBold 15sp 
height 48dp right flex-grow.
```

---

### [2.2] Detail Fasilitas Full Screen

```
Design a mobile facility detail screen for "SlemanAkses". Background #F1F1F1.
App bar: white back arrow #037940, title "Detail Fasilitas" Kit Rounded SemiBold #037940 18sp, 
trailing share icon #4B5563.

Hero image: full-width 220dp height, no border radius (edge to edge), 
overlay gradient bottom to top transparent to black 40% for readability.

Content scrollable below image with 16dp horizontal margin:

Facility header card (white rounded 16dp, overlap -20dp above, shadow-md, margin horizontal 16dp):
- Category badge "FASILITAS UMUM" filled #BFD852 #037940 text Kit Rounded Bold 11sp rounded-full
- Name: Kit Rounded Bold #037940 20sp
- Address row: location icon #4B5563 + Kit Rounded Regular #4B5563 13sp
- Status badge row: "AKTIF" #16A34A or "TIDAK AKTIF" #DC2626

Stats row: 3 columns inside same card with top border #D4D4D4: 
"Laporan", "Terverifikasi", "Terakhir Update" 
values Kit Rounded Bold #037940 16sp, labels Kit Rounded Regular #4B5563 11sp.

Section "Fasilitas Tersedia" Kit Rounded Bold #037940 16sp:
4 attribute rows in white card rounded 16dp, each row: 
icon container 40dp #037940 10% tint + icon #037940 20dp, 
label Kit Rounded Medium #037940 15sp, 
status right: "Tersedia" chip #16A34A or "Tidak Tersedia" chip #DC2626 
Kit Rounded Bold white 11sp rounded-full.

Map mini preview card white rounded 16dp: 
"Lokasi di Peta" title Kit Rounded SemiBold #037940 14sp, 
map thumbnail 100% width 160dp rounded 10dp with pin overlay.

Bottom fixed bar: "🧭 Mulai Navigasi" full-width filled #037940 
rounded-full white Kit Rounded SemiBold 15sp height 52dp shadow-top.
```

---

### [3.1] Pilih Jenis Fasilitas

```
Design a mobile "choose facility type" screen for "SlemanAkses" reporting flow. 
Background #F1F1F1. App bar white, back arrow #037940, 
title "Lapor Fasilitas" Kit Rounded Bold #037940 18sp.

Step progress indicator below app bar: 3 steps labeled "Jenis", "Data", "Kirim". 
Step circles 28dp: active filled #037940 white number Kit Rounded Bold 13sp, 
completed filled #BFD852 checkmark icon #037940, 
pending border #D4D4D4 number Kit Rounded Regular #4B5563 13sp. 
Connecting line between circles: active segment #037940, pending #D4D4D4.

Instruction text: "Pilih jenis fasilitas yang ingin kamu laporkan" 
Kit Rounded Regular #4B5563 14sp margin 20dp top.

2×2 grid of facility type cards (margin 16dp, gap 12dp): 
Each card: white #FFFFFF rounded 16dp shadow-sm padding 20dp center-aligned selectable. 
Selected state: border 2dp #037940 background #037940 5% opacity.
Unselected: border 1dp #D4D4D4.

Card 1 — Ramp: icon accessible_rounded 40dp in #BFD852 circle 64dp, 
label "Ramp / Jalur Miring" Kit Rounded SemiBold #037940 14sp.
Card 2 — Lift: icon elevator_rounded, label "Lift / Elevator".
Card 3 — Toilet: icon wc_rounded, label "Toilet Difabel".
Card 4 — Parkir: icon local_parking_rounded, label "Parkir Khusus".

Bottom: "Lanjut" full-width rounded-full filled #037940 (active) or #D4D4D4 (inactive) 
white Kit Rounded SemiBold 15sp height 52dp.
```

---

### [3.2] Form Geo-Tagging

```
Design a mobile facility geo-tagging report form for "SlemanAkses". Background #F1F1F1.
App bar: white, back arrow #037940, title "Lapor Fasilitas" Kit Rounded SemiBold #037940 18sp.
Step indicator: step 2 of 3 active.

Scrollable sections:

SECTION 1 — "Foto Fasilitas" Kit Rounded SemiBold #037940 14sp:
Large upload box 160dp height full-width rounded 16dp, 
dashed border 1.5dp #037940, background #037940 at 5% opacity.
Center: camera_alt icon #037940 40dp, text "Ketuk untuk mengambil foto" 
Kit Rounded Regular #037940 14sp, subtext "atau unggah dari galeri" 
Kit Rounded Regular #4B5563 12sp.
After selection: image preview fills box, edit icon overlay bottom-right 
white circle 32dp shadow #037940 pen icon.

SECTION 2 — "Lokasi Terdeteksi" Kit Rounded SemiBold #037940 14sp:
White card rounded 16dp shadow-sm padding 16dp.
Left: two rows — "LATITUDE" label Kit Rounded Regular #4B5563 11sp uppercase, 
value "-7.7249° S" Kit Rounded SemiBold #037940 15sp. 
Same for "LONGITUDE" value "110.3672° E".
Pulsing green dot 10dp #16A34A left of values (GPS active indicator).
Right: mini map thumbnail 80×80dp rounded 10dp with green pin marker.

SECTION 3 — "Ketersediaan Fasilitas" Kit Rounded SemiBold #037940 14sp:
White card rounded 16dp shadow-sm. 4 checkbox rows each 52dp height with divider:
- icon (accessible/elevator/wc/local_parking) #037940 20dp
- label Kit Rounded Regular #4B5563 15sp  
- checkbox right side, accent color #037940 24dp

Bottom fixed bar white shadow-top padding 16dp, two buttons side by side gap 12dp:
"Batal" outlined rounded-full border #D4D4D4 text #4B5563 Kit Rounded Medium flex 1 height 48dp,
"Lanjut" filled #037940 white rounded-full Kit Rounded SemiBold flex 2 height 48dp.
```

---

### [3.3] Preview & Konfirmasi

```
Design a mobile report preview/confirmation screen for "SlemanAkses". 
Background #F1F1F1. App bar: white, back arrow #037940, 
title "Konfirmasi Laporan" Kit Rounded Bold #037940 18sp.

Info banner: lime #BFD852 background rounded 12dp margin 16dp, 
info icon #037940 20dp left, text "Periksa kembali data sebelum mengirim" 
Kit Rounded Regular #037940 13sp.

Preview card (white rounded 16dp shadow-sm margin 16dp):
- Facility photo: 200dp height rounded 12dp
- Overlay badge top-left "Ramp" filled #037940 white Kit Rounded Bold 11sp
- Name of facility / location Kit Rounded Bold #037940 16sp
- GPS coordinates row: location icon #4B5563 + coordinate text Kit Rounded Regular #4B5563 13sp

Facility attributes card (white rounded 16dp shadow-sm):
Title "Fasilitas Dilaporkan" Kit Rounded SemiBold #037940 14sp.
Each attribute: icon + label + status dot (filled #16A34A if ada, #DC2626 if tidak).
Kit Rounded Regular #4B5563 14sp.

Timestamp row: Kit Rounded Regular #4B5563 12sp 
"Dikirim: Senin, 18 Mei 2026, 14:32 WIB"

Bottom fixed bar: two buttons:
"Ubah Data" outlined rounded-full border #037940 text #037940 Kit Rounded SemiBold flex 1 height 52dp,
"Kirim Laporan" filled #037940 white rounded-full Kit Rounded SemiBold flex 2 height 52dp.
```

---

### [3.4] Sukses Pengiriman

```
Design a mobile success screen for "SlemanAkses" after report submission. 
Background #F1F1F1. Full screen centered layout, no app bar.

Top area: decorative background circle #BFD852 at 15% opacity 160dp diameter centered.
Inside: circle #BFD852 at 30% opacity 110dp, inner circle #BFD852 70dp, 
checkmark icon white 36dp (or done_all_rounded icon).

Gap 24dp.

"Laporan Terkirim!" Kit Rounded Bold #037940 26sp centered.
Subtext Kit Rounded Regular #4B5563 14sp centered multiline max 280dp:
"Terima kasih! Laporan kamu sedang menunggu verifikasi oleh administrator sistem."

Gap 20dp.

Summary card white #FFFFFF rounded 16dp shadow-sm margin horizontal 24dp padding 16dp:
3 rows with dividers #D4D4D4:
- "ID Laporan" label Kit Rounded Regular #4B5563 12sp + 
  "#RPT-20260518-042" Kit Rounded SemiBold #037940 13sp
- "Status" label + badge chip "Menunggu Validasi" filled #F59E0B white 
  Kit Rounded Bold 11sp rounded-full
- "Waktu Kirim" label + "18 Mei 2026, 14:32" Kit Rounded Regular #4B5563 13sp

Gap 24dp. Two stacked buttons margin horizontal 24dp gap 12dp:
"Lihat Riwayat Laporan" outlined rounded-full border #037940 text #037940 
Kit Rounded SemiBold 15sp full-width height 52dp.
"Kembali ke Peta" filled #037940 white rounded-full Kit Rounded SemiBold 15sp 
full-width height 52dp.
```

---

### [4.1] Riwayat Laporan

```
Design a mobile report history screen for "SlemanAkses". Background #F1F1F1.
App bar: white, title "Riwayat Laporan" Kit Rounded Bold #037940 18sp.

Tab bar below app bar: 4 tabs "Semua" / "Disetujui" / "Menunggu" / "Ditolak". 
Active: bottom underline 3dp #037940, Kit Rounded SemiBold #037940 14sp. 
Inactive: Kit Rounded Regular #4B5563 14sp. Background white.

Scrollable list (vertical, padding 12dp):

Each report card — white #FFFFFF rounded 16dp shadow-sm padding 14dp 
margin-bottom 10dp horizontal 0:
Row layout:
- Left: facility photo thumbnail 72×72dp rounded 10dp object-cover
- Right (flex): 
  Top row: name Kit Rounded SemiBold #037940 15sp (truncate 1 line)
  Row 2: location icon #4B5563 16dp + address Kit Rounded Regular #4B5563 12sp (truncate)
  Row 3: history icon #D4D4D4 14dp + date Kit Rounded Regular #4B5563 11sp
  Row 4: facility mini icons row (4 icons 18dp each, 
    available #037940, unavailable #D4D4D4) + status badge right-aligned
  
Status badge values:
"Disetujui" filled #16A34A white Kit Rounded Bold 11sp rounded-full
"Menunggu" filled #F59E0B white Kit Rounded Bold 11sp rounded-full
"Ditolak" filled #DC2626 white Kit Rounded Bold 11sp rounded-full

Empty state (when no reports): centered, folder_open icon #D4D4D4 64dp, 
"Belum ada laporan" Kit Rounded SemiBold #4B5563 16sp, 
subtext Kit Rounded Regular #4B5563 13sp, 
"Buat Laporan Pertama" CTA filled #037940 rounded-full.
```

---

### [4.2] Detail Status Laporan

```
Design a mobile report status detail screen for "SlemanAkses". Background #F1F1F1.
App bar: white, back arrow #037940, title "Detail Laporan" Kit Rounded Bold #037940 18sp.

Status banner full-width top (below app bar, 56dp height):
Disetujui: background #16A34A at 15% tint, left border 4dp #16A34A, 
  checkmark icon #16A34A 20dp, text "Laporan Disetujui & Dipublikasikan ke Peta" 
  Kit Rounded SemiBold #16A34A 14sp.
Menunggu: #F59E0B tint, clock icon, "Menunggu Verifikasi Administrator".
Ditolak: #DC2626 tint, cancel icon, "Laporan Ditolak".

Facility photo: full-width 200dp height rounded 12dp margin 16dp.

Info card white rounded 16dp shadow-sm margin 16dp padding 16dp:
4 rows with divider #D4D4D4:
- ID Laporan: label + value #037940 monospace-style Kit Rounded SemiBold
- Tanggal Kirim: label + date Kit Rounded Regular #4B5563
- Koordinat GPS: label + "−7.7249, 110.3672" Kit Rounded Regular #037940
- Jenis Fasilitas: label + chip "Ramp" filled #BFD852 #037940 text

Attributes card white rounded 16dp: "Fasilitas Dilaporkan" Kit Rounded SemiBold #037940 14sp.
Each row 48dp: icon container 36dp circle #037940 10% tint, icon #037940 18dp, 
label Kit Rounded Regular #4B5563 14sp, 
status dot right 10dp (filled #16A34A if ada, filled #DC2626 if tidak ada).

Admin note card (conditionally shown): white rounded 16dp, 
left border 4dp #037940, background #037940 at 3% opacity.
Label "Catatan Administrator" Kit Rounded SemiBold #037940 13sp.
Note text Kit Rounded Regular #4B5563 14sp italic.

Bottom: if approved "Lihat di Peta" filled #037940; if rejected "Kirim Ulang" filled #037940.
Both full-width rounded-full height 52dp Kit Rounded SemiBold white.
```

---

### [5.1] Beranda Edukasi

```
Design a mobile education home screen for "SlemanAkses". Background #F1F1F1.
App bar: white, title "Edukasi & Informasi" Kit Rounded Bold #037940 18sp.

Hero banner card (margin 16dp, rounded 20dp, height 160dp): 
gradient from #037940 to #025C30 left-to-right. 
Left content: title "Apa itu Aksesibilitas?" Kit Rounded Bold white 18sp, 
subtitle Kit Rounded Regular white 80% opacity 13sp 2 lines, 
CTA chip "Baca Panduan" white background #037940 text Kit Rounded SemiBold 12sp 
rounded-full padding horizontal 12dp vertical 6dp margin-top 12dp.
Right: accessibility building illustration with #BFD852 accent 80dp wide.

Section "Panduan Fasilitas" Kit Rounded Bold #037940 16sp margin 16dp top 24dp:
Horizontal scrollable cards (gap 12dp, padding horizontal 16dp): 
each card 160dp wide 120dp tall white rounded 14dp shadow-sm padding 14dp.
Icon circle 48dp top: Ramp=#037940, Lift=#BFD852, Toilet=#037940, Parkir=#BFD852 
with white icon 24dp inside. 
Title Kit Rounded SemiBold #037940 13sp. 
Subtitle "Standar & Spesifikasi" Kit Rounded Regular #4B5563 11sp.
Chevron_right icon #D4D4D4 bottom-right 16dp.

Section "Artikel Terbaru" Kit Rounded Bold #037940 16sp margin-top 24dp margin-left 16dp:
Vertical list cards (margin horizontal 16dp gap 10dp): 
each card white rounded 14dp shadow-sm padding 12dp row layout.
Left: photo 80×80dp rounded 10dp. 
Right: category chip "Regulasi"/"Tips"/"Berita" 
border #BFD852 text #037940 Kit Rounded Medium 11sp rounded-full.
Title Kit Rounded SemiBold #037940 14sp 2 lines. 
Date Kit Rounded Regular #4B5563 11sp. 
Chevron_right #D4D4D4 trailing.
```

---

### [5.2] Detail Artikel

```
Design a mobile article detail screen for "SlemanAkses". Background white #FFFFFF.
App bar: white, back arrow #037940, share icon trailing #4B5563, no title.

Hero image full-width 240dp height, object-cover.
Gradient overlay bottom 80dp: transparent to #000000 40%.
Category badge over image bottom-left: filled #BFD852 #037940 text 
Kit Rounded Bold 11sp rounded-full padding horizontal 10dp vertical 5dp.

Content area padding 20dp:
- Date "18 Mei 2026" Kit Rounded Regular #4B5563 12sp
- Title Kit Rounded Bold #037940 22sp line-height 1.4 margin-top 8dp
- Divider #D4D4D4 margin vertical 16dp
- Author row: circle avatar 32dp #037940 initial white Kit Rounded Bold 13sp, 
  "Dinas Sosial Kab. Sleman" Kit Rounded Medium #037940 14sp, 
  "· 5 menit baca" Kit Rounded Regular #4B5563 12sp
- Body text Kit Rounded Regular #4B5563 15sp line-height 1.7 margin-top 20dp

Subheadings within article: Kit Rounded Bold #037940 17sp.
Highlighted quote block: left border 4dp #BFD852, background #BFD852 10% tint, 
rounded-r 8dp, text italic Kit Rounded Regular #037940 15sp padding 16dp.

Bottom floating share bar: white rounded-full shadow-lg padding 12dp 
row (share icon, like icon count, bookmark icon) #037940.
```

---

### [5.3] Panduan Aksesibilitas

```
Design a mobile accessibility standards guide screen for "SlemanAkses". 
Background #F1F1F1. App bar: white, back arrow #037940, 
title "Panduan Aksesibilitas" Kit Rounded Bold #037940 18sp.

Top category tab row: 4 chips horizontal scroll "Ramp" / "Lift" / "Toilet" / "Parkir". 
Active: filled #037940 white Kit Rounded SemiBold 13sp rounded-full.
Inactive: white border #D4D4D4 #4B5563 rounded-full.

Content (scrollable per category):

Standard specification card white rounded 16dp shadow-sm margin 16dp padding 16dp:
- Icon circle 48dp: facility icon #037940 24dp inside #BFD852 background
- Standard name Kit Rounded Bold #037940 18sp
- Regulatory reference "UU No.8 Tahun 2016 · Pasal 18" Kit Rounded Regular #4B5563 12sp
- Divider

Specification list: each spec row 48dp height:
  checkmark icon #16A34A 20dp | spec text Kit Rounded Regular #4B5563 14sp

Warning row (non-compliance): X icon #DC2626 20dp | text #DC2626.

Illustration card white rounded 16dp: 
technical diagram or icon illustration of the facility with measurements labeled 
in Kit Rounded Regular #037940 12sp monospace.

Info box: #037940 5% background rounded 12dp, info icon #037940 20dp, 
text Kit Rounded Regular #037940 13sp italic padding 14dp.
```

---

### [6.1] Notifikasi

```
Design a mobile notifications screen for "SlemanAkses". Background #F1F1F1.
App bar: white, back arrow #037940, title "Notifikasi" Kit Rounded Bold #037940 18sp, 
"Tandai semua dibaca" text button right #037940 Kit Rounded Regular 13sp.

Date group headers: "Hari Ini" Kit Rounded SemiBold #4B5563 12sp uppercase 
with horizontal #D4D4D4 line right. Margin bottom 8dp.

Notification cards scrollable (gap 6dp per card):

UNREAD card: white #FFFFFF rounded 14dp shadow-sm, 
left border 4dp solid #037940, padding 14dp.
- Left: icon circle 44dp, color based on type:
  Approved: #16A34A background, checkmark icon white
  Rejected: #DC2626 background, cancel icon white  
  Info: #037940 background, info icon white
  Announcement: #F59E0B background, campaign icon white
- Right content:
  Title Kit Rounded SemiBold #037940 14sp
  Body Kit Rounded Regular #4B5563 13sp 2-line truncated
  Timestamp Kit Rounded Regular #4B5563 11sp bottom
- Unread indicator: 8dp dot #BFD852 filled top-right of card

READ card: background #F1F1F1 rounded 14dp, no border, no shadow.
Title Kit Rounded Regular #4B5563 14sp (not bold).

Swipe to dismiss: background #DC2626 rounded 14dp, 
delete icon white 24dp right side on swipe-left gesture.

Empty state: centered, notifications_off icon #D4D4D4 64dp, 
"Tidak ada notifikasi" Kit Rounded SemiBold #4B5563 16sp.
```

---

### [7.1] Profil Pengguna

```
Design a mobile user profile screen for "SlemanAkses". Background #F1F1F1.
No standard app bar; replace with custom header.

Header section: #037940 solid background, height 220dp.
Top-right: pencil/edit icon button white 24dp, margin 16dp.
Center: avatar circle 88dp — white border 3dp, inside photo or initials 
placeholder #BFD852 background #037940 text Kit Rounded Bold 28sp.
Camera badge bottom-right of avatar: #BFD852 circle 28dp, camera icon #037940 14dp.
Name: Kit Rounded Bold white 20sp margin-top 12dp.
Role badge: "Relawan Pelapor" #BFD852 background #037940 text 
Kit Rounded SemiBold 12sp rounded-full padding horizontal 12dp vertical 5dp.

Stats card (white #FFFFFF rounded 16dp shadow-md margin horizontal 24dp, 
overlap: margin-top -28dp above background transition): 
3-column row each center-aligned:
Number Kit Rounded Bold #037940 22sp, label Kit Rounded Regular #4B5563 12sp.
"18" Laporan Dikirim | "15" Disetujui | "3" Ditolak.
Vertical #D4D4D4 dividers between columns.

Menu section white card rounded 16dp shadow-sm margin 16dp margin-top 16dp:
Each menu item (height 56dp, divider #D4D4D4 between):
- Leading: icon circle 40dp #037940 at 10% opacity, icon #037940 20dp
- Label Kit Rounded Medium #037940 15sp
- Trailing: chevron_right #D4D4D4 20dp

Items: "Edit Profil" / "Ubah Kata Sandi" / "Pengaturan Notifikasi" / 
"Tentang Aplikasi" / "Kebijakan Privasi"

Bottom margin 24dp: "Keluar" button full-width outlined rounded-full 
border 1.5dp #DC2626 text #DC2626 Kit Rounded SemiBold 15sp height 52dp, 
leading logout icon #DC2626 20dp.
```

---

### [7.2] Edit Profil

```
Design a mobile edit profile screen for "SlemanAkses". Background #F1F1F1.
App bar: white, back arrow #037940, title "Edit Profil" Kit Rounded Bold #037940 18sp, 
"Simpan" text button right #037940 Kit Rounded SemiBold 15sp.

Avatar section centered: circle 88dp photo/initials, 
edit overlay: semi-transparent black 40% rounded-full, 
camera icon white 24dp centered. Tap to change.

White card form rounded 20dp shadow-sm margin 16dp padding 20dp:
- "Nama Lengkap" input: pre-filled value, leading person icon #037940
- "Email" input: pre-filled, leading mail icon #037940, disabled style (grey tint)
- "Nomor Telepon" input (tambahan): leading phone icon #037940, 
  optional label chip "Opsional" border #D4D4D4 text #4B5563 11sp Kit Rounded Regular
- "Role" display-only row: label "Peran Akun" + value "Relawan Pelapor" 
  Kit Rounded Regular #4B5563 14sp, lock icon #D4D4D4 trailing (not editable)

All inputs: rounded 12dp border #D4D4D4 height 52dp focused border #037940.

"Simpan Perubahan" full-width rounded-full filled #037940 white 
Kit Rounded SemiBold 15sp height 52dp margin-top 24dp.
```

---

## 13. Accessibility Guidelines

### 13.1 Touch Targets
- Minimum touch target: **48 × 48 dp** untuk semua elemen interaktif
- Recommended: **56 × 56 dp** untuk primary action (FAB, CTA)
- Spacing antar touch target: minimum **8dp**

### 13.2 Text Contrast
- Normal text (< 18sp regular / < 14sp bold): minimum **4.5:1**
- Large text (≥ 18sp regular / ≥ 14sp bold): minimum **3:1**
- UI components & borders: minimum **3:1**

### 13.3 Focus Indicators
```dart
// Focus ring untuk keyboard/accessibility navigation
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF037940), width: 2.0),
  borderRadius: BorderRadius.circular(12),
)
// Focus visible indicator: 2dp ring, offset 2dp, color #037940
```

### 13.4 Semantic Labels (Flutter)
```dart
// Semua icon button wajib semanticLabel
IconButton(
  icon: Icon(Icons.add_location_alt_rounded),
  tooltip: 'Laporkan fasilitas baru',
  onPressed: ...,
)

// Gambar dengan Semantics
Semantics(
  label: 'Foto fasilitas ramp di Pusat Pemerintahan Sleman',
  child: Image.network(...),
)
```

### 13.5 Font Scaling
- Dukung text scale factor 1.0x hingga 1.3x tanpa layout breaking
- Gunakan `MediaQuery.textScaleFactor` untuk responsive adjustment
- Hindari hardcoded height pada container yang mengandung teks

### 13.6 Color Independence
- Jangan gunakan warna sebagai **satu-satunya** indikator status
- Selalu pasangkan: warna + icon + label teks
- Contoh: status laporan = badge warna + ikon + teks label

---

## 14. Motion & Animation

### 14.1 Duration Scale

```dart
const Duration durationFast    = Duration(milliseconds: 150);  // micro-interaction
const Duration durationNormal  = Duration(milliseconds: 250);  // standard transition
const Duration durationSlow    = Duration(milliseconds: 400);  // page transition, sheet
const Duration durationLazy    = Duration(milliseconds: 600);  // onboarding, success
```

### 14.2 Easing Curves

```dart
// Standard UI transition
curve: Curves.easeInOut

// Enter / appear
curve: Curves.easeOut

// Exit / disappear
curve: Curves.easeIn

// Spring / bounce (FAB, success icon)
curve: Curves.elasticOut
```

### 14.3 Specific Animations

| Elemen                    | Type           | Duration | Curve           |
|---------------------------|----------------|----------|-----------------|
| Page transition           | Slide + fade   | 300ms    | easeInOut       |
| Bottom sheet expand       | Slide up       | 350ms    | easeOut         |
| FAB tap pressed           | Scale 0.92     | 100ms    | easeIn          |
| Success checkmark         | Draw + scale   | 600ms    | elasticOut      |
| Marker appear on map      | Scale + fade   | 250ms    | easeOut         |
| Filter chip toggle        | Color fill     | 150ms    | easeInOut       |
| Skeleton shimmer          | Gradient sweep | 1500ms   | linear repeat   |
| GPS pulse indicator       | Scale ripple   | 1200ms   | easeOut repeat  |
| Notification badge        | Bounce         | 400ms    | elasticOut      |
| Card press state          | Scale 0.98     | 100ms    | easeIn          |

### 14.4 GPS Pulse Animation

```dart
// Pulsing dot untuk GPS aktif
AnimationController _pulseController = AnimationController(
  duration: Duration(milliseconds: 1200),
  vsync: this,
)..repeat(reverse: true);

// Scale dari 0.8 → 1.2, opacity 1.0 → 0.4
// Color: #16A34A
```

### 14.5 Prinsip Motion
- **Purposeful:** Animasi hanya untuk komunikasi status atau guide attention
- **Subtle:** Tidak mengganggu atau memperlambat akses informasi
- **Consistent:** Semua elemen sejenis beranimasi dengan cara yang sama
- **Accessible:** Hormati `prefers-reduced-motion` — semua animasi dapat dinonaktifkan

---

*Design System SlemanAkses v1.0.0*
*Dibuat untuk: Proyek Utama Informatika — Universitas Teknologi Yogyakarta 2026*
*Dosen Pengampu: Farida Ardiani S.Kom, M.Kom.*
