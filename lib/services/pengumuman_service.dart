import 'package:hive/hive.dart';
import '../models/pengumuman.dart';

class PengumumanService {
  static const String boxName = 'pengumuman';

  Box<Pengumuman> get _box => Hive.box<Pengumuman>(boxName);

  List<Pengumuman> getAllPengumuman() {
    final list = _box.values.toList();
    // Sort by date descending (newest first)
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  Future<void> addPengumuman(Pengumuman pengumuman) async {
    await _box.add(pengumuman);
  }

  Future<void> updatePengumuman(int index, Pengumuman pengumuman) async {
    await _box.putAt(index, pengumuman);
  }

  Future<void> deletePengumuman(int index) async {
    await _box.deleteAt(index);
  }

  Pengumuman? getPengumumanAt(int index) {
    if (index >= 0 && index < _box.length) {
      return _box.getAt(index);
    }
    return null;
  }
}
