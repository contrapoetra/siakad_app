import 'package:hive/hive.dart';
import '../models/materi.dart';

class MateriService {
  static const String boxName = 'materi';

  Box<Materi> get _box => Hive.box<Materi>(boxName);

  List<Materi> getAllMateri() {
    return _box.values.toList();
  }

  List<Materi> getMateriByKelasAndMapel(String kelasId, String mapelId) {
    return _box.values.where((m) => m.kelasId == kelasId && m.mataPelajaranId == mapelId).toList();
  }

  Future<void> addMateri(Materi materi) async {
    await _box.add(materi);
  }

  Future<void> deleteMateri(dynamic key) async {
    await _box.delete(key);
  }
}
