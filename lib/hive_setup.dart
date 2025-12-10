import 'package:hive_flutter/hive_flutter.dart';
import 'models/siswa.dart';
import 'models/guru.dart';
import 'models/jadwal.dart';
import 'models/nilai.dart';
import 'models/pengumuman.dart';
import 'models/user.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  // await Hive.deleteFromDisk(); // Removed to ensure persistence

  // Register Adapters
  Hive.registerAdapter(SiswaAdapter());
  Hive.registerAdapter(GuruAdapter());
  Hive.registerAdapter(JadwalAdapter());
  Hive.registerAdapter(NilaiAdapter());
  Hive.registerAdapter(PengumumanAdapter());
  Hive.registerAdapter(UserAdapter());

  // Open Boxes
  await Hive.openBox<Siswa>('siswa');
  await Hive.openBox<Guru>('guru');
  await Hive.openBox<Jadwal>('jadwal');
  await Hive.openBox<Nilai>('nilai');
  await Hive.openBox<Pengumuman>('pengumuman');
  await Hive.openBox<User>('users'); // Open the users box
}
