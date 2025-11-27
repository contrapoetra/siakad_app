# SIAKAD XYZ - Sistem Informasi Akademik

Aplikasi Sistem Informasi Akademik berbasis Flutter untuk memudahkan siswa, guru, dan admin dalam mengelola data akademik.

## 📋 Fitur Utama

### 1. Login & Role Management
- **3 Role Pengguna**: Admin, Guru, Siswa
- Autentikasi dengan dummy credentials
- Role-based access control untuk setiap pengguna

### 2. Dashboard per Role

#### Admin Dashboard
- Kelola Data Siswa (CRUD)
- Kelola Data Guru (CRUD)
- Kelola Jadwal Pelajaran (CRUD)
- Kelola Pengumuman (CRUD)

#### Guru Dashboard
- Input dan kelola nilai siswa
- Lihat jadwal pelajaran
- Lihat pengumuman

#### Siswa Dashboard
- Lihat jadwal pelajaran per kelas
- Lihat nilai rapor
- Export rapor ke PDF
- Lihat pengumuman

### 3. Data Master
- **Data Siswa**: NIS, Nama, Kelas, Jurusan
- **Data Guru**: NIP, Nama, Mata Pelajaran
- **Jadwal Pelajaran**: Hari, Jam, Mata Pelajaran, Guru Pengampu, Kelas

### 4. Manajemen Nilai
- Input nilai: Tugas, UTS, UAS
- Perhitungan otomatis nilai akhir: `(Tugas × 30%) + (UTS × 30%) + (UAS × 40%)`
- Konversi predikat otomatis:
  - A = ≥ 85
  - B = 75 – 84
  - C = 65 – 74
  - D = < 65

### 5. Rapor Siswa
- Tampilan nilai per mata pelajaran dalam bentuk tabel
- Export rapor ke format PDF
- Nilai akhir dan predikat per mata pelajaran

### 6. Pengumuman
- Admin dapat membuat dan mengelola pengumuman
- Semua pengguna dapat melihat daftar pengumuman
- Detail pengumuman dengan tanggal publish

## 🏗️ Struktur Proyek

```
siakad_projek/
├── lib/
│   ├── models/                 # Data models dengan Hive
│   │   ├── siswa.dart
│   │   ├── guru.dart
│   │   ├── jadwal.dart
│   │   ├── nilai.dart
│   │   └── pengumuman.dart
│   │
│   ├── services/              # Business logic & Hive operations
│   │   ├── siswa_service.dart
│   │   ├── guru_service.dart
│   │   ├── jadwal_service.dart
│   │   ├── nilai_service.dart
│   │   └── pengumuman_service.dart
│   │
│   ├── providers/             # State management dengan Provider
│   │   ├── auth_provider.dart
│   │   ├── siswa_provider.dart
│   │   ├── guru_provider.dart
│   │   ├── jadwal_provider.dart
│   │   ├── nilai_provider.dart
│   │   └── pengumuman_provider.dart
│   │
│   ├── pages/                 # UI Screens
│   │   ├── login_page.dart
│   │   ├── admin_dashboard.dart
│   │   ├── guru_dashboard.dart
│   │   ├── siswa_dashboard.dart
│   │   ├── siswa_crud.dart
│   │   ├── guru_crud.dart
│   │   ├── jadwal_crud.dart
│   │   ├── nilai_input.dart
│   │   └── pengumuman_page.dart
│   │
│   ├── widgets/               # Reusable widgets
│   │   ├── custom_input.dart
│   │   ├── custom_button.dart
│   │   └── empty_state.dart
│   │
│   ├── main.dart              # Entry point
│   ├── routes.dart            # Route management
│   └── hive_setup.dart        # Hive initialization
│
└── pubspec.yaml
```

## 🚀 Instalasi dan Menjalankan Aplikasi

### Prasyarat
- Flutter SDK (>= 3.10.0)
- Dart SDK
- Android Studio / VS Code dengan Flutter plugin

### Langkah Instalasi

1. **Clone atau download project**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 🔑 Demo Credentials

### Admin
- Username: `admin`
- Password: `admin123`

### Guru
- Username: `guru`
- Password: `guru123`

### Siswa
- Username: `siswa`
- Password: `siswa123`

## 📦 Dependencies

- **flutter**: Framework utama
- **provider**: State management
- **hive**: Local database
- **hive_flutter**: Hive integration untuk Flutter
- **pdf**: Generate PDF documents
- **printing**: Print dan preview PDF
- **intl**: Internationalization dan formatting
- **path_provider**: Access ke file system

## 🎨 Fitur Teknis

### State Management
- Menggunakan Provider pattern untuk state management
- Clean separation of concerns

### Local Storage
- Hive untuk penyimpanan data lokal
- Type-safe dengan Hive adapters
- Persistent storage

### UI/UX
- Material Design 3
- Responsive layout
- Custom widgets untuk konsistensi UI
- Empty states untuk better UX

### PDF Export
- Generate rapor siswa dalam format PDF
- Preview sebelum save/print
- Professional layout

## 📝 Cara Penggunaan

### Sebagai Admin
1. Login dengan credentials admin
2. Kelola data siswa, guru, dan jadwal dari dashboard
3. Buat pengumuman untuk semua pengguna
4. CRUD operations untuk semua data master

### Sebagai Guru
1. Login dengan credentials guru
2. Input nilai siswa per mata pelajaran
3. Sistem otomatis menghitung nilai akhir dan predikat
4. Lihat jadwal mengajar

### Sebagai Siswa
1. Login dengan credentials siswa
2. Lihat jadwal pelajaran kelas
3. Lihat nilai rapor dengan predikat
4. Export rapor ke PDF
5. Lihat pengumuman terbaru

## 🔧 Development

### Generate Hive Adapters (jika ada perubahan model)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 👨‍💻 Author

Project SIAKAD - Sistem Informasi Akademik
Dibuat dengan Flutter & Hive

---

**Catatan**: Aplikasi ini menggunakan dummy data untuk demonstrasi. Untuk production, implementasikan authentication backend yang proper dan database server.
