import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kelas.dart';
import '../services/kelas_service.dart';
import '../models/siswa.dart';
import '../models/guru.dart';
import '../providers/siswa_provider.dart';
import '../providers/guru_provider.dart';

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

  // This method will be called from the UI, likely KelasCrudPage
  Future<void> autoAssignStudentsAndTeachers({
    required BuildContext context, // Pass context to get other providers
  }) async {
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    // --- Student Assignment Logic ---
    List<Siswa> allSiswa = siswaProvider.siswaList;
    List<Kelas> allKelas = _kelasList; // Already have access to kelasList

    // 1. Identify unassigned students
    List<Siswa> unassignedSiswa = allSiswa
        .where((s) => s.kelasId == null || s.kelasId!.isEmpty)
        .toList();

    if (unassignedSiswa.isEmpty) {
      debugPrint('No unassigned students to process.');
    }
    if (allKelas.isEmpty) {
      debugPrint('No classes available for student assignment.');
      return;
    }

    // Prepare classes for assignment (e.g., student counts)
    Map<String, int> classStudentCounts = {};
    for (var kelas in allKelas) {
      classStudentCounts[kelas.id] = allSiswa.where((s) => s.kelasId == kelas.id).length;
    }

    // Sort classes by current student count to help with distribution
    allKelas.sort((a, b) => (classStudentCounts[a.id] ?? 0).compareTo(classStudentCounts[b.id] ?? 0));

    // First pass: Fill up to minimum 10 students per class
    int minStudentsPerClass = 10;
    List<Siswa> studentsToAssign = List.from(unassignedSiswa); // Copy to modify

    for (var kelas in allKelas) {
      while ((classStudentCounts[kelas.id] ?? 0) < minStudentsPerClass && studentsToAssign.isNotEmpty) {
        Siswa student = studentsToAssign.removeAt(0);
        student.kelasId = kelas.id;
        student.kelas = kelas.tingkat; // Update string representations
        student.jurusan = kelas.jurusan; // Update string representations
        await siswaProvider.updateSiswa(siswaProvider.getSiswaIndex(student), student);
        classStudentCounts[kelas.id] = (classStudentCounts[kelas.id] ?? 0) + 1;
      }
    }

    // Second pass: Distribute remaining students evenly
    int classIndex = 0;
    while (studentsToAssign.isNotEmpty) {
      if (allKelas.isEmpty) break; // Should not happen if checked above, but defensive
      Kelas kelas = allKelas[classIndex % allKelas.length];
      Siswa student = studentsToAssign.removeAt(0);
      student.kelasId = kelas.id;
      student.kelas = kelas.tingkat;
      student.jurusan = kelas.jurusan;
      await siswaProvider.updateSiswa(siswaProvider.getSiswaIndex(student), student);
      classStudentCounts[kelas.id] = (classStudentCounts[kelas.id] ?? 0) + 1;
      classIndex++;
    }

    // Refresh siswa list
    siswaProvider.loadSiswa();
    debugPrint('Student assignment complete.');

    // --- Teacher Assignment Logic ---
    List<Guru> allGuru = guruProvider.guruList;
    if (allGuru.isEmpty) {
      debugPrint('No teachers available for assignment.');
    } else {
      for (var kelas in _kelasList) { // Iterate through current kelasList
        bool classModified = false;
        for (var mapel in kelas.mataPelajaranList) {
          if (mapel.guruNip.isEmpty) {
            if (allGuru.isNotEmpty) {
              // Simple random assignment
              final randomGuru = allGuru[0]; // Assign first available guru for now
              mapel.guruNip = randomGuru.nip;
              mapel.guruNama = randomGuru.nama;
              classModified = true;
            }
          }
        }
        if (classModified) {
          await _kelasService.updateKelas(kelas); // Update the single class
        }
      }
      fetchKelas(); // Refresh kelas list
      debugPrint('Teacher assignment complete.');
    }
    notifyListeners(); // Notify listeners for KelasProvider changes
  }
}
