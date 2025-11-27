import 'package:flutter/material.dart';
import '../models/guru.dart';
import '../services/guru_service.dart';

class GuruProvider with ChangeNotifier {
  final GuruService _service = GuruService();
  List<Guru> _guruList = [];

  List<Guru> get guruList => _guruList;

  void loadGuru() {
    _guruList = _service.getAllGuru();
    notifyListeners();
  }

  Future<void> addGuru(Guru guru) async {
    await _service.addGuru(guru);
    loadGuru();
  }

  Future<void> updateGuru(int index, Guru guru) async {
    await _service.updateGuru(index, guru);
    loadGuru();
  }

  Future<void> deleteGuru(int index) async {
    await _service.deleteGuru(index);
    loadGuru();
  }

  Guru? getGuruAt(int index) {
    return _service.getGuruAt(index);
  }

  Guru? getGuruByNip(String nip) {
    return _service.getGuruByNip(nip);
  }

  int getGuruIndex(Guru guru) {
    return _service.getGuruIndex(guru);
  }
}
