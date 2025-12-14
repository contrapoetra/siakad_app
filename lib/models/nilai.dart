import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Add this import

part 'nilai.g.dart';

@HiveType(typeId: 3)
class Nilai extends HiveObject {
  @HiveField(0)
  late String nis;

  @HiveField(1)
  late String namaSiswa;

  @HiveField(2)
  late String mataPelajaran;

  @HiveField(3)
  late String semester; // New field for semester

  @HiveField(4)
  late double? nilaiTugas;

  @HiveField(5)
  late double? nilaiUTS;

  @HiveField(6)
  late double? nilaiUAS;

  @HiveField(7) // Update HiveField index
  late String id; // Unique ID

  @HiveField(8)
  late double? nilaiKehadiran;

  Nilai({
    String? id, // Make id optional in constructor
    required this.nis,
    required this.namaSiswa,
    required this.mataPelajaran,
    required this.semester, // Add semester to constructor
    this.nilaiTugas,
    this.nilaiUTS,
    this.nilaiUAS,
    this.nilaiKehadiran,
  }) : id = id ?? const Uuid().v4(); // Initialize id in constructor

  // Hitung nilai akhir
  double? get nilaiAkhir {
    if (nilaiTugas == null || nilaiUTS == null || nilaiUAS == null || nilaiKehadiran == null) {
      return null;
    }
    return (nilaiKehadiran! * 0.1) + (nilaiTugas! * 0.2) + (nilaiUTS! * 0.3) + (nilaiUAS! * 0.4);
  }

  // Konversi ke predikat
  String get predikat {
    final akhir = nilaiAkhir;
    if (akhir == null) return '-';
    if (akhir >= 85) return 'A';
    if (akhir >= 75) return 'B';
    if (akhir >= 65) return 'C';
    return 'D';
  }
}