# Penggabungan & Koneksi Backend - FoodieSpot

## Ringkasan

Terdapat dua Flutter project terpisah:
- **`foodiespot/`** (root) — Frontend dengan UI Admin & Owner (menggunakan **dummy data**), belum connect ke backend
- **`foodiespot/FoodieSpot/`** — Flutter app lengkap dengan UI User yang **sudah connect ke backend Laravel** + folder `foodiespot_backend/` (Laravel API)

Tujuan:
1. **Gabungkan** kedua project menjadi satu project Flutter di `foodiespot/`
2. **Koneksikan** UI Admin & Owner yang ada di project root ke backend Laravel (dari services yang sudah ada di `FoodieSpot/`)
3. UI User **tidak disentuh** — langsung pakai yang sudah ada di `FoodieSpot/`

---

## User Review Required

> [!IMPORTANT]
> Project `foodiespot/` (root) menggunakan `dummy data` untuk login dan semua data. Semua logika dummy akan **diganti total** dengan API calls ke backend Laravel.

> [!WARNING]
> Setelah penggabungan, folder `FoodieSpot/` di dalam root akan **dihapus** karena sudah dipindahkan. Pastikan backup sudah dilakukan atau sudah di-commit ke git sebelum saya jalankan.

> [!IMPORTANT]
> **Pertanyaan untuk kamu**: Backend Laravel (`foodiespot_backend`) dijalankan di mana? 
> - Emulator Android → gunakan `http://10.0.2.2:8000/api` ✅ (sudah benar di constants FoodieSpot)
> - HP Fisik → perlu IP lokal laptop (misal `http://192.168.x.x:8000/api`)
> - Sudah di-deploy online → perlu URL produksi

---

## Open Questions

> [!IMPORTANT]
> **Q1**: Apakah kamu mau project digabungkan dengan **mempertahankan UI yang ada di `foodiespot/` (root)** sebagai base, lalu menambahkan services dari `FoodieSpot/`? Atau ingin menggunakan `FoodieSpot/` sebagai base utama?
> 
> **Rekomendasi saya**: Gunakan `foodiespot/` (root) sebagai base, karena UI Admin & Owner di sana lebih lengkap (7 file masing-masing), lalu kita copy service & model dari `FoodieSpot/` ke dalamnya, dan tambahkan UI User dari `FoodieSpot/`.

> [!IMPORTANT]  
> **Q2**: Apakah UI User dari `FoodieSpot/lib/ui/` (yang sudah connect backend) mau digabungkan ke dalam `foodiespot/lib/screens/user/`? Atau biarkan UI user yang lama saja? 
> 
> **Rekomendasi**: Ambil UI User dari `FoodieSpot/` karena sudah connect backend dan lebih lengkap.

---

## Rencana Perubahan

### Arsitektur Akhir (Setelah Penggabungan)
```
foodiespot/                    ← Project utama (SATU folder)
├── foodiespot_backend/        ← Backend Laravel (dipindahkan dari FoodieSpot/)
├── lib/
│   ├── main.dart              ← Update: tambah HttpOverrides + routing lengkap
│   ├── models/                ← Replace: pakai models dari FoodieSpot
│   ├── services/              ← NEW: copy semua services dari FoodieSpot
│   ├── utils/                 ← NEW: constants.dart (API URL)
│   ├── theme/                 ← Tetap pakai app_theme.dart yang ada
│   ├── screens/
│   │   ├── splash_screen.dart ← Update: cek token → route ke role yang benar
│   │   ├── auth/
│   │   │   └── login_screen.dart  ← REPLACE: hapus dummy, pakai AuthService
│   │   ├── admin/             ← UPDATE: koneksi ke AdminService
│   │   ├── owner/             ← UPDATE: koneksi ke OwnerService & TempatMakanService
│   │   └── user/              ← REPLACE: ambil dari FoodieSpot/lib/ui/
│   └── widgets/
└── pubspec.yaml               ← Update: tambah http, shared_preferences, dll.
```

---

### Tahap 1 — Persiapan & Struktur

#### [MODIFY] pubspec.yaml
Tambahkan dependency yang dibutuhkan services:
- `http: ^1.2.1`
- `shared_preferences: ^2.2.3`
- `flutter_map: ^8.1.1`
- `latlong2: ^0.9.1`
- `geolocator: ^13.0.4`
- `url_launcher: ^6.3.1`

---

### Tahap 2 — Copy Services & Models dari FoodieSpot

#### [NEW] lib/utils/constants.dart
Copy dari `FoodieSpot/lib/utils/constants.dart` — berisi `ApiConfig.baseUrl`

#### [NEW] lib/services/auth_service.dart
Copy dari `FoodieSpot/lib/services/auth_service.dart`

#### [NEW] lib/services/admin_service.dart
Copy dari `FoodieSpot/lib/services/admin_service.dart`

#### [NEW] lib/services/owner_service.dart
Copy dari `FoodieSpot/lib/services/owner_service.dart`

#### [NEW] lib/services/tempat_makan_service.dart
Copy dari `FoodieSpot/lib/services/tempat_makan_service.dart`

#### [NEW] lib/services/review_service.dart
Copy dari `FoodieSpot/lib/services/review_service.dart`

#### [NEW] lib/services/photo_service.dart
Copy dari `FoodieSpot/lib/services/photo_service.dart`

#### [NEW] lib/services/pengajuan_owner.dart
Copy dari `FoodieSpot/lib/services/pengajuan_owner.dart`

#### [NEW] lib/models/ (semua model)
Copy semua model dari `FoodieSpot/lib/models/`:
- `user_model.dart` (replace yang lama)
- `tempat_makan_model.dart`
- `review_model.dart` (replace yang lama)
- `photo_model.dart`
- `pengajuan_owner_model.dart`
- `notification_model.dart`

---

### Tahap 3 — Update Core App

#### [MODIFY] lib/main.dart
- Tambah `HttpOverrides` untuk bypass SSL development
- Tambah routing lengkap (login, admin, owner, user pages)
- Cek session saat startup

#### [MODIFY] lib/screens/splash_screen.dart
- Hapus navigasi langsung ke `LoginScreen`
- Tambah logika cek token dari SharedPreferences
- Route ke halaman sesuai role (admin/owner/user) jika sudah login

#### [MODIFY] lib/screens/auth/login_screen.dart
- **Hapus** semua logika dummy data
- **Tambah** `AuthService` untuk login ke API
- Setelah login, cek `role` dari response dan route ke screen yang sesuai

---

### Tahap 4 — Update Admin Screens (Koneksi Backend)

#### [MODIFY] lib/screens/admin/admin_home_screen.dart
- Inject `AdminService` dan `AuthService`
- Tambah fungsi logout yang memanggil `AuthService.signOut()`

#### [MODIFY] lib/screens/admin/admin_dashboard_tab.dart
- Hapus dummy data
- Gunakan `AdminService.getDashboard()` untuk statistik real

#### [MODIFY] lib/screens/admin/admin_applications_tab.dart
- Hapus dummy data
- Gunakan `AdminService.getPendingPengajuan()`, `approvePengajuan()`, `rejectPengajuan()`

#### [MODIFY] lib/screens/admin/admin_users_tab.dart
- Hapus dummy data
- Gunakan `AdminService.getAllUsers()`, `deleteUser()`

#### [MODIFY] lib/screens/admin/admin_reviews_tab.dart
- Hapus dummy data
- Gunakan `AdminService.getAllReviews()`, `deleteReview()`

#### [MODIFY] lib/screens/admin/admin_photos_tab.dart
- Hapus dummy data
- Gunakan `AdminService.getAllPhotos()`, `deletePhoto()`

#### [MODIFY] lib/screens/admin/admin_restaurants_tab.dart
- Hapus dummy data
- Gunakan `TempatMakanService` untuk list semua restoran

---

### Tahap 5 — Update Owner Screens (Koneksi Backend)

#### [MODIFY] lib/screens/owner/owner_home_screen.dart
- Hapus dummy data
- Gunakan `OwnerService.getDashboard()` untuk dashboard stats
- Gunakan `AuthService.signOut()` untuk logout

#### [MODIFY] lib/screens/owner/owner_restaurant_list_screen.dart
- Hapus dummy data
- Gunakan `TempatMakanService.getMyTempatMakan()`

#### [MODIFY] lib/screens/owner/owner_add_restaurant_screen.dart
- Gunakan `TempatMakanService.createTempatMakan()`

#### [MODIFY] lib/screens/owner/owner_edit_restaurant_screen.dart
- Gunakan `TempatMakanService.updateTempatMakan()`

#### [MODIFY] lib/screens/owner/owner_review_screen.dart
- Gunakan `ReviewService.getReviews()`, `ReviewService.reply()`

---

### Tahap 6 — Copy & Integrasikan UI User

#### [NEW] lib/screens/user/ (dari FoodieSpot/lib/ui/)
Copy semua UI user dari `FoodieSpot/lib/ui/` ke `lib/screens/user/`:
- Semua file dari `dashboards/user_page.dart`
- Semua file dari `tempat_makan/`
- Semua file dari `profile/`
- `auth/` pages (login, register, forgot password)

---

### Tahap 7 — Pindahkan Backend

#### Backend Laravel
Copy/move folder `FoodieSpot/foodiespot_backend/` → `foodiespot_backend/` (di root project)

---

## Rencana Verifikasi

### Automated
```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

### Manual
1. Jalankan backend: `cd foodiespot_backend && php artisan serve`
2. Jalankan Flutter: `flutter run`
3. Test login sebagai admin → verifikasi data dari database muncul
4. Test login sebagai owner → verifikasi data warung dari database muncul
5. Test logout → verifikasi session terhapus

---

## Estimasi Pekerjaan
| Tahap | Deskripsi | Kompleksitas |
|-------|-----------|--------------|
| 1 | Update pubspec.yaml | Rendah |
| 2 | Copy services & models | Rendah |
| 3 | Update main.dart & splash | Sedang |
| 4 | Connect Admin screens | Tinggi |
| 5 | Connect Owner screens | Tinggi |
| 6 | Copy UI User | Sedang |
| 7 | Pindahkan backend | Rendah |
