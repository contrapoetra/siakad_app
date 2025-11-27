import 'package:flutter/material.dart';
import '../models/nilai.dart';
import '../services/nilai_service.dart';

class NilaiProvider with ChangeNotifier {
  final NilaiService _service = NilaiService();
  List<Nilai> _nilaiList = [];

  List<Nilai> get nilaiList => _nilaiList;

  void loadNilai() {
    _nilaiList = _service.getAllNilai();
    notifyListeners();
  }

  List<Nilai> getNilaiByNis(String nis) {
    return _service.getNilaiByNis(nis);
  }

  List<Nilai> getNilaiByMataPelajaran(String mataPelajaran) {
    return _service.getNilaiByMataPelajaran(mataPelajaran);
  }

  Future<void> addNilai(Nilai nilai) async {
    await _service.addNilai(nilai);
    loadNilai();
  }

  Future<void> updateNilai(int index, Nilai nilai) async {
    await _service.updateNilai(index, nilai);
    loadNilai();
  }

  Future<void> deleteNilai(int index) async {
    await _service.deleteNilai(index);
    loadNilai();
  }

  Nilai? getNilaiAt(int index) {
    return _service.getNilaiAt(index);
  }

  int? getNilaiIndex(String nis, String mataPelajaran) {
    return _service.getNilaiIndex(nis, mataPelajaran);
  }
}
