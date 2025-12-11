import 'package:flutter/material.dart';
import '../models/materi.dart';
import '../services/materi_service.dart';

class MateriProvider with ChangeNotifier {
  final MateriService _service = MateriService();
  
  List<Materi> getMateriByKelasAndMapel(String kelasId, String mapelId) {
    return _service.getMateriByKelasAndMapel(kelasId, mapelId);
  }

  Future<void> addMateri(Materi materi) async {
    await _service.addMateri(materi);
    notifyListeners();
  }

  Future<void> deleteMateri(dynamic key) async {
    await _service.deleteMateri(key);
    notifyListeners();
  }
}
