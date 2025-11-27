# Changelog

## Version 1.0.0 - Initial Release (2025-11-21)

### ✨ Features

#### Authentication & Authorization
- ✅ Login system dengan 3 role (Admin, Guru, Siswa)
- ✅ Role-based access control
- ✅ Dummy credentials untuk demo
- ✅ Persistent session dengan Provider

#### Dashboard
- ✅ Admin Dashboard dengan 4 menu utama
- ✅ Guru Dashboard dengan fitur input nilai
- ✅ Siswa Dashboard dengan 3 tabs (Jadwal, Nilai, Pengumuman)

#### Data Master Management
- ✅ CRUD Data Siswa (NIS, Nama, Kelas, Jurusan)
- ✅ CRUD Data Guru (NIP, Nama, Mata Pelajaran)
- ✅ CRUD Jadwal Pelajaran (Hari, Jam, Mapel, Guru, Kelas)

#### Nilai Management
- ✅ Input nilai Tugas, UTS, UAS
- ✅ Perhitungan otomatis nilai akhir
- ✅ Konversi otomatis ke predikat (A/B/C/D)
- ✅ Filter nilai per siswa
- ✅ Filter nilai per mata pelajaran

#### Rapor Siswa
- ✅ Tampilan nilai dalam bentuk tabel
- ✅ Export rapor ke PDF
- ✅ Preview PDF sebelum save/print
- ✅ Detail nilai per mata pelajaran

#### Pengumuman
- ✅ Create pengumuman (Admin only)
- ✅ Edit/Delete pengumuman (Admin only)
- ✅ View pengumuman (All users)
- ✅ Sort by date (newest first)

### 🎨 UI/UX
- ✅ Material Design 3
- ✅ Responsive layout
- ✅ Custom widgets (Input, Button, Empty State)
- ✅ Color-coded predikat badges
- ✅ Empty state placeholders
- ✅ Loading indicators
- ✅ Success/Error snackbars

### 🔧 Technical
- ✅ Hive local database
- ✅ Provider state management
- ✅ Type-safe Hive adapters
- ✅ Clean architecture (Models, Services, Providers, Pages)
- ✅ Route management
- ✅ Form validation
- ✅ PDF generation

### 📦 Dependencies
- flutter (SDK: ^3.10.0)
- provider: ^6.1.1
- hive: ^2.2.3
- hive_flutter: ^1.1.0
- path_provider: ^2.1.1
- pdf: ^3.10.7
- printing: ^5.11.1
- intl: ^0.19.0
- hive_generator: ^2.0.1 (dev)
- build_runner: ^2.4.7 (dev)

### 📝 Documentation
- ✅ README.md dengan instruksi lengkap
- ✅ DEVELOPMENT_GUIDE.md untuk developer
- ✅ CHANGELOG.md
- ✅ Code comments
- ✅ Demo credentials

### 🧪 Testing Status
- ✅ Manual testing completed
- ✅ Role access verified
- ✅ CRUD operations tested
- ✅ PDF export tested
- ⬜ Unit tests (pending)
- ⬜ Widget tests (pending)
- ⬜ Integration tests (pending)

### 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### 🐛 Known Issues
- ⚠️ 22 info warnings dari flutter analyze (non-critical)
  - use_build_context_synchronously warnings (sudah di-guard dengan mounted check)
  - deprecated_member_use untuk DropdownButtonFormField value parameter

### 🔮 Future Enhancements
- [ ] Backend API integration
- [ ] Real authentication system
- [ ] Push notifications
- [ ] Attendance module
- [ ] Grade analytics & charts
- [ ] Parent portal
- [ ] Dark mode
- [ ] Localization (i18n)
- [ ] Unit & Integration tests
- [ ] Performance optimization
- [ ] Offline sync

---

## Release Notes

### What's Working
✅ Semua fitur core sudah berfungsi dengan baik
✅ Data persistence menggunakan Hive
✅ PDF export untuk rapor siswa
✅ Role-based access control
✅ CRUD operations untuk semua entities
✅ Perhitungan nilai otomatis

### Demo Data
Aplikasi sudah include dummy data:
- 2 Siswa (Ahmad Rizki, Siti Nurhaliza)
- 3 Guru (Budi Santoso, Siti Aminah, Andi Wijaya)
- 3 Jadwal pelajaran
- 2 Pengumuman

### Getting Started
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

### Demo Credentials
- Admin: admin / admin123
- Guru: guru / guru123
- Siswa: siswa / siswa123

---

**Built with ❤️ using Flutter & Hive**
