import 'package:hive/hive.dart';
import '../models/kelas.dart';

class KelasService {
  final Box<Kelas> _kelasBox = Hive.box<Kelas>('kelas');

  List<Kelas> getAllKelas() {
    return _kelasBox.values.toList();
  }

  Future<void> addKelas(Kelas kelas) async {
    await _kelasBox.add(kelas);
  }

  Future<void> updateKelas(Kelas kelas) async {
    // HiveObjects have a save() method, but if we replaced the object in the box logic:
    // Ideally we should modify the object in place and call .save()
    // Or finding the key.
    // Here assuming the UI passes the object that is already in the box or we find it.
    // If 'kelas' is already a HiveObject managed by the box, kelas.save() works.
    // But if we constructed a new object, we need to find the key.
    
    // For simplicity, let's assume we replace based on ID if we can find it, 
    // or we expect the UI to pass the managed object. 
    // Best practice with Hive list updates: find the index/key.
    
    final key = _kelasBox.keys.firstWhere((k) => _kelasBox.get(k)?.id == kelas.id, orElse: () => null);
    if (key != null) {
      await _kelasBox.put(key, kelas);
    } else {
      await _kelasBox.add(kelas);
    }
  }

  Future<void> deleteKelas(String id) async {
    final key = _kelasBox.keys.firstWhere((k) => _kelasBox.get(k)?.id == id, orElse: () => null);
    if (key != null) {
      await _kelasBox.delete(key);
    }
  }
  
  Kelas? getKelasById(String id) {
     try {
       return _kelasBox.values.firstWhere((element) => element.id == id);
     } catch (e) {
       return null;
     }
  }
}
