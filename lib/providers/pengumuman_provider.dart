import 'package:flutter/material.dart';
import '../models/pengumuman.dart';
import '../services/pengumuman_service.dart';

class PengumumanProvider with ChangeNotifier {
  final PengumumanService _service = PengumumanService();
  List<Pengumuman> _pengumumanList = [];

  List<Pengumuman> get pengumumanList => _pengumumanList;

  void loadPengumuman() {
    _pengumumanList = _service.getAllPengumuman();
    notifyListeners();
  }

  Future<void> addPengumuman(Pengumuman pengumuman) async {
    await _service.addPengumuman(pengumuman);
    loadPengumuman();
  }

  Future<void> updatePengumuman(int index, Pengumuman pengumuman) async {
    await _service.updatePengumuman(index, pengumuman);
    loadPengumuman();
  }

  Future<void> deletePengumuman(int index) async {
    await _service.deletePengumuman(index);
    loadPengumuman();
  }

  Pengumuman? getPengumumanAt(int index) {
    return _service.getPengumumanAt(index);
  }
}
