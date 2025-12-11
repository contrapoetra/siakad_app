import 'package:hive/hive.dart';

part 'materi.g.dart';

@HiveType(typeId: 11)
class Materi extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String judul;

  @HiveField(2)
  late String deskripsi; // Text content or link description

  @HiveField(3)
  late String? fileUrl; // Optional URL for file/link

  @HiveField(4)
  late String kelasId;

  @HiveField(5)
  late String mataPelajaranId;

  @HiveField(6)
  late String guruId;

  @HiveField(7)
  late DateTime createdAt;

  Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.fileUrl,
    required this.kelasId,
    required this.mataPelajaranId,
    required this.guruId,
    required this.createdAt,
  });
}
