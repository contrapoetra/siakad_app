import 'package:hive/hive.dart';
import '../models/absensi.dart';

class AbsensiService {
  static const String boxName = 'absensi';

  Box<Absensi> get _box => Hive.box<Absensi>(boxName);

  List<Absensi> getAllAbsensi() {
    return _box.values.toList();
  }

  Absensi? getAbsensi({
    required String kelasId,
    required String mataPelajaranId,
    required DateTime tanggal,
  }) {
    // Normalize the date for consistent lookup
    final normalizedTanggal = DateTime(tanggal.year, tanggal.month, tanggal.day);
    try {
      return _box.values.firstWhere(
        (absensi) =>
            absensi.kelasId == kelasId &&
            absensi.mataPelajaranId == mataPelajaranId &&
            absensi.tanggal.year == normalizedTanggal.year &&
            absensi.tanggal.month == normalizedTanggal.month &&
            absensi.tanggal.day == normalizedTanggal.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Method to add a new Absensi record or update an existing one using its ID as key
  Future<void> addOrUpdateAbsensi(Absensi absensi) async {
    await _box.put(absensi.id, absensi);
  }

  // Method to delete an Absensi record by its ID
  Future<void> deleteAbsensi(String id) async {
    await _box.delete(id);
  }
}