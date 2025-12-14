import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../services/jadwal_service.dart';

class JadwalProvider with ChangeNotifier {
  final JadwalService _service = JadwalService();
  List<Jadwal> _jadwalList = [];

  List<Jadwal> get jadwalList => _jadwalList;

  void loadJadwal() {
    _jadwalList = _service.getAllJadwal();
    notifyListeners();
  }

  List<Jadwal> getJadwalByKelas(String kelasId) {
    return _service.getJadwalByKelas(kelasId);
  }

  Future<void> addJadwal(Jadwal jadwal) async {
    await _service.addJadwal(jadwal);
    loadJadwal();
  }

  Future<void> updateJadwal(int index, Jadwal jadwal) async {
    await _service.updateJadwal(index, jadwal);
    loadJadwal();
  }

  Future<void> deleteJadwal(int index) async {
    await _service.deleteJadwal(index);
    loadJadwal();
  }

  Jadwal? getJadwalAt(int index) {
    return _service.getJadwalAt(index);
  }
}
