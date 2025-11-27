import 'package:hive/hive.dart';

part 'guru.g.dart';

@HiveType(typeId: 1)
class Guru extends HiveObject {
  @HiveField(0)
  late String nip;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  late String mataPelajaran;

  Guru({
    required this.nip,
    required this.nama,
    required this.mataPelajaran,
  });
}
