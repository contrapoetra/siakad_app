import 'package:hive/hive.dart';

part 'siswa.g.dart';

@HiveType(typeId: 6)
class Siswa extends HiveObject {
  @HiveField(0)
  late String nis;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String email; // New field for email

  @HiveField(3)
  late DateTime tanggalLahir; // New field for date of birth

  @HiveField(4)
  late String tempatLahir; // New field for place of birth

  @HiveField(5)
  late String namaAyah; // New field for father's name

  @HiveField(6)
  late String namaIbu; // New field for mother's name

  @HiveField(7)
  late String kelas;

  @HiveField(8)
  late String jurusan;

  @HiveField(9)
  late String? kelasId;

  Siswa({
    required this.nis,
    required this.nama,
    required this.email,
    required this.tanggalLahir,
    required this.tempatLahir,
    required this.namaAyah,
    required this.namaIbu,
    required this.kelas,
    required this.jurusan,
    this.kelasId,
  });
}
