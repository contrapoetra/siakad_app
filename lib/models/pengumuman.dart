import 'package:hive/hive.dart';

part 'pengumuman.g.dart';

@HiveType(typeId: 4)
class Pengumuman extends HiveObject {
  @HiveField(0)
  late String judul;

  @HiveField(1)
  late String isi;

  @HiveField(2)
  late DateTime tanggal;

  Pengumuman({
    required this.judul,
    required this.isi,
    required this.tanggal,
  });
}
