import 'package:flutter/material.dart';
import '../models/tugas.dart';
import '../services/tugas_service.dart';

class TugasProvider with ChangeNotifier {
  final TugasService _service = TugasService();
  List<Tugas> _tugasList = [];

  List<Tugas> get tugasList => _tugasList;

  void loadTugas() {
    _tugasList = _service.getAllTugas();
    notifyListeners();
  }

  Future<void> addTugas(Tugas tugas) async {
    await _service.addTugas(tugas);
    loadTugas();
  }

  Future<void> deleteTugas(dynamic key) async {
    await _service.deleteTugas(key);
    loadTugas();
  }

  List<Tugas> getTugasByKelas(String kelasId) {
    return _service.getTugasByKelas(kelasId);
  }
  
  List<Tugas> getTugasByGuru(String guruId) {
    return _service.getTugasByGuru(guruId);
  }
}
