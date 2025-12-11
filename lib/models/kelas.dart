import 'package:hive/hive.dart';

part 'kelas.g.dart';

@HiveType(typeId: 8)
class MataPelajaran extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String guruNip;

  @HiveField(3)
  late String guruNama;

  MataPelajaran({
    required this.id,
    required this.nama,
    required this.guruNip,
    required this.guruNama,
  });
}

@HiveType(typeId: 7)
class Kelas extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String tingkat; // X, XI, XII

  @HiveField(3)
  late String jurusan; // IPA, IPS

  @HiveField(4)
  late List<MataPelajaran> mataPelajaranList;

  Kelas({
    required this.id,
    required this.nama,
    required this.tingkat,
    required this.jurusan,
    required this.mataPelajaranList,
  });
}
