import 'package:hive/hive.dart';
import '../models/guru.dart';

class GuruService {
  static const String boxName = 'guru';

  Box<Guru> get _box => Hive.box<Guru>(boxName);

  List<Guru> getAllGuru() {
    return _box.values.toList();
  }

  Guru? getGuruByNip(String nip) {
    return _box.values.firstWhere(
      (guru) => guru.nip == nip,
      orElse: () => Guru(nip: '', nama: '', mataPelajaran: ''),
    );
  }

  Future<void> addGuru(Guru guru) async {
    await _box.add(guru);
  }

  Future<void> updateGuru(int index, Guru guru) async {
    await _box.putAt(index, guru);
  }

  Future<void> deleteGuru(int index) async {
    await _box.deleteAt(index);
  }

  Guru? getGuruAt(int index) {
    if (index >= 0 && index < _box.length) {
      return _box.getAt(index);
    }
    return null;
  }

  int getGuruIndex(Guru guru) {
    for (int i = 0; i < _box.length; i++) {
      if (_box.getAt(i)?.nip == guru.nip) {
        return i;
      }
    }
    return -1;
  }
}
