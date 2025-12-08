import 'package:flutter/material.dart';
import '../models/pengumuman.dart';
import '../services/pengumuman_service.dart';
import '../services/notification_service.dart'; // Import NotificationService

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
    // Trigger local notification for new announcement
    NotificationService().showNotification(
      pengumuman.key ?? DateTime.now().millisecondsSinceEpoch, // Use key as ID or a unique timestamp
      'Pengumuman Baru: ${pengumuman.judul}',
      pengumuman.isi,
      'announcement_payload',
    );
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
