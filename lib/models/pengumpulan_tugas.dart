import 'package:hive/hive.dart';

part 'pengumpulan_tugas.g.dart';

@HiveType(typeId: 12)
class PengumpulanTugas extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String tugasId;

  @HiveField(2)
  late String siswaNis;

  @HiveField(3)
  late String? content; // Text answer

  @HiveField(4)
  late String? fileUrl; // File link

  @HiveField(5)
  late double? nilai; // Null if not graded

  @HiveField(6)
  late String? feedback; // Teacher feedback

  @HiveField(7)
  late DateTime submittedAt;

  PengumpulanTugas({
    required this.id,
    required this.tugasId,
    required this.siswaNis,
    this.content,
    this.fileUrl,
    this.nilai,
    this.feedback,
    required this.submittedAt,
  });
}
