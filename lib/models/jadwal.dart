import 'package:hive/hive.dart';

part 'jadwal.g.dart';

@HiveType(typeId: 2)
class Jadwal extends HiveObject {
  @HiveField(0)
  late String hari;

  @HiveField(1)
  late String jam;

  @HiveField(2)
  late String mataPelajaran;

  @HiveField(3)
  late String guruPengampu;

  @HiveField(4)
  late String kelas;

  Jadwal({
    required this.hari,
    required this.jam,
    required this.mataPelajaran,
    required this.guruPengampu,
    required this.kelas,
  });
}
