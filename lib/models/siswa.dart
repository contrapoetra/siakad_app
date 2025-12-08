import 'package:hive/hive.dart';

part 'siswa.g.dart';

@HiveType(typeId: 6)
class Siswa extends HiveObject {
  @HiveField(0)
  late String nis;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String kelas;

  @HiveField(3)
  late String jurusan;

  Siswa({
    required this.nis,
    required this.nama,
    required this.kelas,
    required this.jurusan,
  });
}
