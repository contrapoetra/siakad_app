import 'package:hive/hive.dart';

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
  late double nilaiTugas;

  @HiveField(4)
  late double nilaiUTS;

  @HiveField(5)
  late double nilaiUAS;

  Nilai({
    required this.nis,
    required this.namaSiswa,
    required this.mataPelajaran,
    required this.nilaiTugas,
    required this.nilaiUTS,
    required this.nilaiUAS,
  });

  // Hitung nilai akhir
  double get nilaiAkhir {
    return (nilaiTugas * 0.3) + (nilaiUTS * 0.3) + (nilaiUAS * 0.4);
  }

  // Konversi ke predikat
  String get predikat {
    final akhir = nilaiAkhir;
    if (akhir >= 85) return 'A';
    if (akhir >= 75) return 'B';
    if (akhir >= 65) return 'C';
    return 'D';
  }
}
