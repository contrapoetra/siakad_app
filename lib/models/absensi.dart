import 'package:hive/hive.dart';

part 'absensi.g.dart';

@HiveType(typeId: 10)
class Absensi extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kelasId;

  @HiveField(2)
  late String mataPelajaranId;

  @HiveField(3)
  late DateTime tanggal;

  @HiveField(4)
  late Map<String, String> dataKehadiran; // Key: NIS, Value: Status (Hadir, Sakit, Izin, Alpha)

  Absensi({
    required this.id,
    required this.kelasId,
    required this.mataPelajaranId,
    required this.tanggal,
    required this.dataKehadiran,
  });
}
