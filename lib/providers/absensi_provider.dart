import 'package:flutter/material.dart';
import '../models/absensi.dart';
import '../services/absensi_service.dart';

class AbsensiProvider with ChangeNotifier {
  final AbsensiService _service = AbsensiService();

  // Get a single Absensi record for a specific class, subject, and date
  Future<Absensi?> getAbsensiForDate(String kelasId, String mataPelajaranId, DateTime tanggal) async {
    return _service.getAbsensi(
      kelasId: kelasId,
      mataPelajaranId: mataPelajaranId,
      tanggal: tanggal,
    );
  }

  // Add or Update an Absensi record
  Future<void> addOrUpdateAbsensi(Absensi absensi) async {
    await _service.addOrUpdateAbsensi(absensi);
    notifyListeners(); // Notify UI of changes
  }

  // Get all Absensi records for a specific student in a given class and subject
  Future<List<Absensi>> getAbsensiForStudent(String siswaNis, String kelasId, String mataPelajaranId) async {
    final allAbsensi = _service.getAllAbsensi();
    // Filter to relevant class and subject, and where student is present in dataKehadiran
    return allAbsensi.where((absensi) =>
        absensi.kelasId == kelasId &&
        absensi.mataPelajaranId == mataPelajaranId &&
        absensi.dataKehadiran.containsKey(siswaNis)
    ).toList();
  }
}