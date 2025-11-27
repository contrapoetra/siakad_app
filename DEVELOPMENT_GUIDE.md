# Panduan Pengembangan SIAKAD

## Arsitektur Aplikasi

### Layer Architecture

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Pages, Widgets, UI Components)    │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      State Management Layer         │
│         (Providers)                 │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│       Business Logic Layer          │
│         (Services)                  │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│        Data Persistence Layer       │
│     (Hive Local Database)           │
└─────────────────────────────────────┘
```

## Alur Data

### 1. Create/Update Data
```
UI (Page) → Provider → Service → Hive Box → Storage
```

### 2. Read Data
```
Storage → Hive Box → Service → Provider → UI (Page)
```

## File Struktur Detail

### Models (`lib/models/`)
Berisi data models dengan Hive type adapters untuk serialization.

**Contoh: siswa.dart**
```dart
@HiveType(typeId: 0)
class Siswa extends HiveObject {
  @HiveField(0) late String nis;
  @HiveField(1) late String nama;
  // ... fields lainnya
}
```

### Services (`lib/services/`)
Menangani CRUD operations langsung dengan Hive boxes.

**Fungsi Utama:**
- `getAll()` - Ambil semua data
- `getByKey()` - Ambil data berdasarkan key
- `add()` - Tambah data baru
- `update()` - Update data existing
- `delete()` - Hapus data

### Providers (`lib/providers/`)
State management menggunakan Provider pattern.

**Fungsi Utama:**
- Load data dari service
- Notify listeners saat data berubah
- Bridge antara UI dan business logic

### Pages (`lib/pages/`)
UI screens untuk setiap fitur.

**Kategori Pages:**
1. **Authentication**: `login_page.dart`
2. **Dashboards**: `admin_dashboard.dart`, `guru_dashboard.dart`, `siswa_dashboard.dart`
3. **CRUD Pages**: `siswa_crud.dart`, `guru_crud.dart`, `jadwal_crud.dart`
4. **Functional Pages**: `nilai_input.dart`, `pengumuman_page.dart`

### Widgets (`lib/widgets/`)
Reusable UI components.

## Menambah Fitur Baru

### Langkah 1: Buat Model
```dart
// lib/models/new_model.dart
import 'package:hive/hive.dart';

part 'new_model.g.dart';

@HiveType(typeId: 5) // gunakan typeId unik
class NewModel extends HiveObject {
  @HiveField(0)
  late String field1;
  
  NewModel({required this.field1});
}
```

### Langkah 2: Generate Adapter
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Langkah 3: Register di hive_setup.dart
```dart
Hive.registerAdapter(NewModelAdapter());
await Hive.openBox<NewModel>('newmodel');
```

### Langkah 4: Buat Service
```dart
// lib/services/new_service.dart
class NewService {
  Box<NewModel> get _box => Hive.box<NewModel>('newmodel');
  
  List<NewModel> getAll() => _box.values.toList();
  // ... CRUD methods
}
```

### Langkah 5: Buat Provider
```dart
// lib/providers/new_provider.dart
class NewProvider with ChangeNotifier {
  final NewService _service = NewService();
  List<NewModel> _list = [];
  
  List<NewModel> get list => _list;
  
  void loadData() {
    _list = _service.getAll();
    notifyListeners();
  }
}
```

### Langkah 6: Register Provider di main.dart
```dart
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => NewProvider()),
  ],
)
```

### Langkah 7: Buat UI Page
```dart
// lib/pages/new_page.dart
class NewPage extends StatefulWidget {
  // implement UI dengan Consumer<NewProvider>
}
```

## Best Practices

### 1. State Management
- Selalu gunakan `Provider.of<T>(context, listen: false)` untuk operasi write
- Gunakan `Consumer<T>` atau `context.watch<T>()` untuk listen changes
- Load data di `initState()` dengan `addPostFrameCallback`

### 2. Form Validation
- Gunakan `GlobalKey<FormState>` untuk form validation
- Validate sebelum save data
- Tampilkan error message yang jelas

### 3. Error Handling
- Wrap async operations dengan try-catch
- Tampilkan SnackBar untuk user feedback
- Check `mounted` sebelum Navigator operations

### 4. Code Organization
- Satu file = satu class/widget
- Pisahkan business logic dari UI
- Gunakan custom widgets untuk reusability

### 5. Naming Conventions
- Classes: PascalCase (`SiswaProvider`)
- Files: snake_case (`siswa_provider.dart`)
- Variables: camelCase (`siswaList`)
- Constants: SCREAMING_SNAKE_CASE (`MAX_LENGTH`)

## Testing

### Manual Testing Checklist
- ✅ Login dengan semua role
- ✅ CRUD operations untuk setiap entity
- ✅ Navigation antar pages
- ✅ Form validation
- ✅ PDF export
- ✅ Data persistence (restart app)

### Role Access Testing
**Admin:**
- ✅ Can access all CRUD pages
- ✅ Can create announcements
- ✅ Cannot input grades

**Guru:**
- ✅ Can input grades
- ✅ Can view schedule
- ✅ Cannot manage students

**Siswa:**
- ✅ Can view grades
- ✅ Can export PDF
- ✅ Cannot modify data

## Troubleshooting

### Build Errors
```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive Errors
```bash
# Hapus data Hive untuk reset
# Android: adb shell rm -rf /data/data/com.example.siakad_projek/app_flutter/
# iOS: Delete app dari simulator
```

### Hot Reload Issues
- Restart app jika ada perubahan di model
- Hot reload tidak work untuk Hive changes
- Full restart diperlukan setelah code generation

## Performance Tips

1. **Lazy Loading**: Load data hanya saat diperlukan
2. **Pagination**: Untuk list besar, implementasikan pagination
3. **Caching**: Provider sudah cache data di memory
4. **Dispose Controllers**: Jangan lupa dispose TextEditingController
5. **Optimize Rebuilds**: Gunakan `const` constructor dimana memungkinkan

## Security Considerations

⚠️ **PENTING untuk Production:**

1. Implementasikan proper authentication (JWT, OAuth)
2. Gunakan backend API, bukan local storage saja
3. Encrypt sensitive data
4. Implement proper authorization checks
5. Validate semua input di backend
6. Use HTTPS untuk API calls
7. Implement rate limiting
8. Add audit logging

## Next Steps

Untuk meningkatkan aplikasi:

1. **Backend Integration**
   - REST API atau GraphQL
   - Real-time updates dengan WebSocket
   - Cloud storage

2. **Advanced Features**
   - Push notifications
   - Attendance tracking
   - Grade analytics
   - Parent portal

3. **UI/UX Improvements**
   - Dark mode
   - Animations
   - Better charts
   - Accessibility

4. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests

## Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Hive Database](https://docs.hivedb.dev/)
- [PDF Package](https://pub.dev/packages/pdf)
