import 'package:hive/hive.dart';
import '../models/siswa.dart';

class SiswaService {
  static const String boxName = 'siswa';

  Box<Siswa> get _box => Hive.box<Siswa>(boxName);

  List<Siswa> getAllSiswa() {
    return _box.values.toList();
  }

  Siswa? getSiswaByNis(String nis) {
    return _box.values.firstWhere(
      (siswa) => siswa.nis == nis,
      orElse: () => Siswa(nis: '', nama: '', kelas: '', jurusan: ''),
    );
  }

  Future<void> addSiswa(Siswa siswa) async {
    await _box.add(siswa);
  }

  Future<void> updateSiswa(int index, Siswa siswa) async {
    await _box.putAt(index, siswa);
  }

  Future<void> deleteSiswa(int index) async {
    await _box.deleteAt(index);
  }

  Siswa? getSiswaAt(int index) {
    if (index >= 0 && index < _box.length) {
      return _box.getAt(index);
    }
    return null;
  }

  int getSiswaIndex(Siswa siswa) {
    for (int i = 0; i < _box.length; i++) {
      if (_box.getAt(i)?.nis == siswa.nis) {
        return i;
      }
    }
    return -1;
  }
}
