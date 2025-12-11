import 'package:hive/hive.dart';

part 'tugas.g.dart';

@HiveType(typeId: 9)
class Tugas extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String judul;

  @HiveField(2)
  late String deskripsi;

  @HiveField(3)
  late String kelasId;

  @HiveField(4)
  late String mataPelajaranId;

  @HiveField(5)
  late String guruId;

  @HiveField(6)
  late DateTime deadline;

  @HiveField(7)
  late DateTime createdAt;

  Tugas({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kelasId,
    required this.mataPelajaranId,
    required this.guruId,
    required this.deadline,
    required this.createdAt,
  });
}
