import 'package:hive/hive.dart';

part 'guru.g.dart';

@HiveType(typeId: 1)
class Guru extends HiveObject {
  @HiveField(0)
  late String nip;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String email; // New field for email

  @HiveField(3)
  late DateTime tanggalLahir; // New field for date of birth

  @HiveField(4)
  late String tempatLahir; // New field for place of birth

  @HiveField(5)
  late String gelar; // Replaced mataPelajaran with gelar

  Guru({
    required this.nip,
    required this.nama,
    required this.email,
    required this.tanggalLahir,
    required this.tempatLahir,
    required this.gelar,
  });
}
