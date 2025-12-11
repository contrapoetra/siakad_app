import 'package:hive/hive.dart';
import '../models/pengumpulan_tugas.dart';

class SubmissionService {
  static const String boxName = 'submissions';

  Box<PengumpulanTugas> get _box => Hive.box<PengumpulanTugas>(boxName);

  List<PengumpulanTugas> getAllSubmissions() {
    return _box.values.toList();
  }

  List<PengumpulanTugas> getSubmissionsByTugas(String tugasId) {
    return _box.values.where((s) => s.tugasId == tugasId).toList();
  }

  PengumpulanTugas? getSubmissionByTugasAndSiswa(String tugasId, String siswaNis) {
    try {
      // Find by explicit ID if possible, otherwise iterate values
      return _box.values.firstWhere((s) => s.tugasId == tugasId && s.siswaNis == siswaNis);
    } catch (e) {
      return null;
    }
  }

  Future<void> addSubmission(PengumpulanTugas submission) async {
    // Check if exists, update if so
    final existing = getSubmissionByTugasAndSiswa(submission.tugasId, submission.siswaNis);
    if (existing != null) {
      existing.content = submission.content;
      existing.fileUrl = submission.fileUrl;
      existing.submittedAt = submission.submittedAt;
      existing.nilai = submission.nilai; // Preserve or update grade/feedback if submitted again
      existing.feedback = submission.feedback;
      await existing.save(); // Use save on the HiveObject to persist changes
    } else {
      await _box.put(submission.id, submission); // Use explicit ID for new submissions
    }
  }

  Future<void> gradeSubmission(String tugasId, String siswaNis, double nilai, String feedback) async {
    PengumpulanTugas? submission = getSubmissionByTugasAndSiswa(tugasId, siswaNis);

    if (submission == null) {
      // Create a new submission if one doesn't exist
      submission = PengumpulanTugas(
        id: '${tugasId}_$siswaNis', // Generate a unique ID for the submission
        tugasId: tugasId,
        siswaNis: siswaNis,
        submittedAt: DateTime.now(), // Assume now if graded without prior submission
        content: null, // No content if only graded
        fileUrl: null, // No file if only graded
      );
      submission.nilai = nilai;
      submission.feedback = feedback;
      await _box.put(submission.id, submission); // Use put to add with ID
    } else {
      // Update existing submission
      submission.nilai = nilai;
      submission.feedback = feedback;
      await submission.save(); // Save changes to existing object
    }
  }
}