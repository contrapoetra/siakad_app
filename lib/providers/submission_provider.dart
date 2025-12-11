import 'package:flutter/material.dart';
import '../models/pengumpulan_tugas.dart';
import '../services/submission_service.dart';

class SubmissionProvider with ChangeNotifier {
  final SubmissionService _service = SubmissionService();

  List<PengumpulanTugas> getSubmissionsByTugas(String tugasId) {
    return _service.getSubmissionsByTugas(tugasId);
  }

  PengumpulanTugas? getSubmissionByTugasAndSiswa(String tugasId, String siswaNis) {
    return _service.getSubmissionByTugasAndSiswa(tugasId, siswaNis);
  }

  Future<void> submitAssignment(PengumpulanTugas submission) async {
    await _service.addSubmission(submission);
    notifyListeners();
  }

  Future<void> gradeSubmission(String tugasId, String siswaNis, double nilai, String feedback) async {
    await _service.gradeSubmission(tugasId, siswaNis, nilai, feedback);
    notifyListeners();
  }
}
