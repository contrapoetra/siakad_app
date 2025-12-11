import 'package:flutter/material.dart';
import '../models/kelas.dart';
import '../services/kelas_service.dart';

class KelasProvider with ChangeNotifier {
  final KelasService _kelasService = KelasService();
  List<Kelas> _kelasList = [];

  List<Kelas> get kelasList => _kelasList;

  KelasProvider() {
    fetchKelas();
  }

  void fetchKelas() {
    _kelasList = _kelasService.getAllKelas();
    notifyListeners();
  }

  Future<void> addKelas(Kelas kelas) async {
    await _kelasService.addKelas(kelas);
    fetchKelas();
  }

  Future<void> updateKelas(Kelas kelas) async {
    await _kelasService.updateKelas(kelas);
    fetchKelas();
  }

  Future<void> deleteKelas(String id) async {
    await _kelasService.deleteKelas(id);
    fetchKelas();
  }
  
  Kelas? getKelasById(String id) {
    return _kelasService.getKelasById(id);
  }
}
