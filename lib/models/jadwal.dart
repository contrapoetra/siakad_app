import 'package:hive/hive.dart';

part 'jadwal.g.dart';

@HiveType(typeId: 2)
class Jadwal extends HiveObject {
  @HiveField(0)
  late String id; // Add ID field

  @HiveField(1)
  late String hari;

  @HiveField(2)
  late String jam;

  @HiveField(3)
  late String mataPelajaran;

  @HiveField(4)
  late String guruPengampu;

  @HiveField(5)
  late String kelas;

  @HiveField(6)
  late String kelasId; // Add kelasId
  
  @HiveField(7)
  late String mapelId; // Add mapelId

  Jadwal({
    required this.id, // Update constructor
    required this.hari,
    required this.jam,
    required this.mataPelajaran,
    required this.guruPengampu,
    required this.kelas,
    required this.kelasId, // Update constructor
    required this.mapelId, // Update constructor
  });
}
