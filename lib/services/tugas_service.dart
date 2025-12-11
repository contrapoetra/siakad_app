import 'package:hive/hive.dart';
import '../models/tugas.dart';

class TugasService {
  static const String boxName = 'tugas';

  Box<Tugas> get _box => Hive.box<Tugas>(boxName);

  List<Tugas> getAllTugas() {
    return _box.values.toList();
  }

  List<Tugas> getTugasByKelas(String kelasId) {
    return _box.values.where((tugas) => tugas.kelasId == kelasId).toList();
  }
  
  List<Tugas> getTugasByGuru(String guruId) {
    return _box.values.where((tugas) => tugas.guruId == guruId).toList();
  }

  Future<void> addTugas(Tugas tugas) async {
    await _box.add(tugas);
  }

  Future<void> deleteTugas(dynamic key) async {
     await _box.delete(key);
  }
}
