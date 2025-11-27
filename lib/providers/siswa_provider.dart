import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../services/siswa_service.dart';

class SiswaProvider with ChangeNotifier {
  final SiswaService _service = SiswaService();
  List<Siswa> _siswaList = [];

  List<Siswa> get siswaList => _siswaList;

  void loadSiswa() {
    _siswaList = _service.getAllSiswa();
    notifyListeners();
  }

  Future<void> addSiswa(Siswa siswa) async {
    await _service.addSiswa(siswa);
    loadSiswa();
  }

  Future<void> updateSiswa(int index, Siswa siswa) async {
    await _service.updateSiswa(index, siswa);
    loadSiswa();
  }

  Future<void> deleteSiswa(int index) async {
    await _service.deleteSiswa(index);
    loadSiswa();
  }

  Siswa? getSiswaAt(int index) {
    return _service.getSiswaAt(index);
  }

  Siswa? getSiswaByNis(String nis) {
    return _service.getSiswaByNis(nis);
  }

  int getSiswaIndex(Siswa siswa) {
    return _service.getSiswaIndex(siswa);
  }
}
