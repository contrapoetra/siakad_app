import 'package:hive/hive.dart';
import '../models/nilai.dart';

class NilaiService {
  static const String boxName = 'nilai';

  Box<Nilai> get _box => Hive.box<Nilai>(boxName);

  List<Nilai> getAllNilai() {
    return _box.values.toList();
  }

  List<Nilai> getNilaiByNis(String nis) {
    return _box.values.where((nilai) => nilai.nis == nis).toList();
  }

  List<Nilai> getNilaiByMataPelajaran(String mataPelajaran) {
    return _box.values.where((nilai) => nilai.mataPelajaran == mataPelajaran).toList();
  }

  Future<void> addNilai(Nilai nilai) async {
    await _box.add(nilai);
  }

  Future<void> updateNilai(int index, Nilai nilai) async {
    await _box.putAt(index, nilai);
  }

  Future<void> deleteNilai(int index) async {
    await _box.deleteAt(index);
  }

  Nilai? getNilaiAt(int index) {
    if (index >= 0 && index < _box.length) {
      return _box.getAt(index);
    }
    return null;
  }

  // Cek apakah nilai sudah ada untuk siswa, mata pelajaran, dan semester tertentu
  int? getNilaiIndex(String nis, String mataPelajaran, String semester) {
    for (int i = 0; i < _box.length; i++) {
      final nilai = _box.getAt(i);
      if (nilai?.nis == nis && nilai?.mataPelajaran == mataPelajaran && nilai?.semester == semester) {
        return i;
      }
    }
    return null;
  }
}
