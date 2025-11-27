import 'package:hive/hive.dart';
import '../models/jadwal.dart';

class JadwalService {
  static const String boxName = 'jadwal';

  Box<Jadwal> get _box => Hive.box<Jadwal>(boxName);

  List<Jadwal> getAllJadwal() {
    return _box.values.toList();
  }

  List<Jadwal> getJadwalByKelas(String kelas) {
    return _box.values.where((jadwal) => jadwal.kelas == kelas).toList();
  }

  Future<void> addJadwal(Jadwal jadwal) async {
    await _box.add(jadwal);
  }

  Future<void> updateJadwal(int index, Jadwal jadwal) async {
    await _box.putAt(index, jadwal);
  }

  Future<void> deleteJadwal(int index) async {
    await _box.deleteAt(index);
  }

  Jadwal? getJadwalAt(int index) {
    if (index >= 0 && index < _box.length) {
      return _box.getAt(index);
    }
    return null;
  }
}
