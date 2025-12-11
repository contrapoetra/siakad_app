import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/kelas.dart';
import '../models/materi.dart';
import '../models/tugas.dart';
import '../models/pengumpulan_tugas.dart';
import '../models/jadwal.dart'; // Import Jadwal model

class DummyDataService {
  Future<void> generateDummyData() async {
    final userBox = Hive.box<User>('users');
    final siswaBox = Hive.box<Siswa>('siswa');
    final guruBox = Hive.box<Guru>('guru');
    final kelasBox = Hive.box<Kelas>('kelas');
    final materiBox = Hive.box<Materi>('materi');
    final tugasBox = Hive.box<Tugas>('tugas');
    final submissionBox = Hive.box<PengumpulanTugas>('submissions');
    final jadwalBox = Hive.box<Jadwal>('jadwal'); // Access Jadwal box

    // Clear existing data
    await userBox.clear();
    await siswaBox.clear();
    await guruBox.clear();
    await kelasBox.clear();
    await materiBox.clear();
    await tugasBox.clear();
    await submissionBox.clear();
    await jadwalBox.clear(); // Clear Jadwal box

    // 1. Generate 5 Guru data
    final List<Guru> dummyGuru = [];
    final List<String> teacherNames = [
      'Dr. Rina Wati', 'Prof. Joko Santoso', 'Dra. Ani Suryani', 'M.Pd. Budi Cahyono', 'S.Pd. Siti Aisyah'
    ];
    final List<String> degrees = [
      'Dr., M.Pd.', 'Prof. Dr.', 'S.Pd., M.Sc.', 'M.Pd.', 'S.Pd.'
    ];
    final List<String> placesOfBirth = ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar'];

    for (int i = 0; i < 5; i++) {
      final nip = '198${5 + i}0101201001100${1 + i}';
      final name = teacherNames[i];
      final email = '${name.toLowerCase().replaceAll(' ', '.')}${i + 1}@example.com';
      final dob = DateTime(1985 + i, (i % 12) + 1, (i % 28) + 1);
      final pob = placesOfBirth[i % placesOfBirth.length];
      final degree = degrees[i % degrees.length];

      dummyGuru.add(Guru(
        nip: nip,
        nama: name,
        email: email,
        tanggalLahir: dob,
        tempatLahir: pob,
        gelar: degree,
      ));
    }
    
    // Add dummy guru to box
    await guruBox.addAll(dummyGuru);

    // 2. Generate Classes (Kelas)
    // We will create 6 classes: X IPA 1, X IPS 1, XI IPA 1, XI IPS 1, XII IPA 1, XII IPS 1
    final List<Kelas> dummyKelas = [];
    final levels = ['X', 'XI', 'XII'];
    final majors = ['IPA', 'IPS'];
    
    // Helper to get random teacher
    Guru getRandomGuru() => dummyGuru[DateTime.now().microsecond % dummyGuru.length];

    int classIdCounter = 1;
    for (var level in levels) {
      for (var major in majors) {
        final className = '$level $major 1';
        final subjects = <MataPelajaran>[];
        
        // Add some subjects
        final subjectNames = ['Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', major == 'IPA' ? 'Fisika' : 'Ekonomi', major == 'IPA' ? 'Biologi' : 'Sosiologi'];
        
        for (var subjName in subjectNames) {
          final teacher = getRandomGuru();
          subjects.add(MataPelajaran(
            id: 'mapel_${classIdCounter}_${subjects.length}',
            nama: subjName,
            guruNip: teacher.nip,
            guruNama: teacher.nama,
          ));
        }

        dummyKelas.add(Kelas(
          id: 'kelas_$classIdCounter',
          nama: className,
          tingkat: level,
          jurusan: major,
          mataPelajaranList: subjects,
        ));
        classIdCounter++;
      }
    }

    // Add dummy kelas to box
    await kelasBox.addAll(dummyKelas);


    // 3. Generate Siswa data (at least 10 per class)
    final List<Siswa> dummySiswa = [];
    final List<String> studentFirstNames = [
      'Ahmad', 'Siti', 'Budi', 'Dewi', 'Faisal', 'Gita', 'Hadi', 'Indah', 'Joko', 'Kartika',
      'Lukman', 'Maya', 'Nia', 'Oki', 'Putri', 'Qori', 'Rina', 'Santi', 'Taufik', 'Umar',
      'Vina', 'Wira', 'Xena', 'Yanti', 'Zainal', 'Ani', 'Doni', 'Eka', 'Gatot', 'Fitri'
    ];
    final List<String> studentLastNames = [
      'Rizki', 'Nurhaliza', 'Santoso', 'Lestari', 'Rahman', 'Putri', 'Wijaya', 'Permata', 'Susilo', 'Sari',
      'Hakim', 'Indah', 'Ramadhani', 'Setiana', 'Ayu', 'Akbar', 'Fitri', 'Dewi', 'Hidayat', 'Said',
      'Amelia', 'Negara', 'Putri', 'Susanti', 'Arifin', 'Suryani', 'Pratama', 'Fitriani', 'Subroto', 'Ningsih'
    ];
    
    int studentCount = 0;
    for (var kelas in dummyKelas) {
      for (int i = 0; i < 15; i++) { // 15 students per class
        final nis = '2024${(studentCount + 1).toString().padLeft(3, '0')}';
        final name = '${studentFirstNames[studentCount % studentFirstNames.length]} ${studentLastNames[studentCount % studentLastNames.length]}';
        final email = '${name.toLowerCase().replaceAll(' ', '.')}${studentCount + 1}@example.com';
        final dob = DateTime(2007 - (i % 2), (i % 12) + 1, (i % 28) + 1);
        final pob = placesOfBirth[i % placesOfBirth.length];
        final father = 'Ayah ${name.split(' ')[0]}';
        final mother = 'Ibu ${name.split(' ')[0]}';
        
        dummySiswa.add(Siswa(
          nis: nis,
          nama: name,
          email: email,
          tanggalLahir: dob,
          tempatLahir: pob,
          namaAyah: father,
          namaIbu: mother,
          kelas: kelas.tingkat, // Legacy field
          jurusan: kelas.jurusan, // Legacy field
          kelasId: kelas.id, // New field
        ));
        studentCount++;
      }
    }

    // Add dummy siswa to box
    await siswaBox.addAll(dummySiswa);

    // 4. Generate User data from Siswa and Guru
    await userBox.add(User(nomorInduk: 'admin', password: 'admin123', role: 'Admin', email: 'admin@example.com', isPasswordSet: true)); // Admin user

    for (var siswa in dummySiswa) {
      await userBox.add(User(
        nomorInduk: siswa.nis,
        password: 'password', // Set a default password for easier login
        role: 'Siswa',
        email: siswa.email,
        isPasswordSet: true, // Mark as set
      ));
    }

    for (var guru in dummyGuru) {
      await userBox.add(User(
        nomorInduk: guru.nip,
        password: 'password', // Set a default password for easier login
        role: 'Guru', // Changed to Guru directly for dummy
        email: guru.email,
        isPasswordSet: true, // Mark as set
      ));
    }

    // 5. Generate Dummy Jadwal
    final List<Jadwal> dummyJadwal = [];
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
    final timeSlots = ['07:00-08:30', '08:30-10:00', '10:00-11:30', '13:00-14:30'];
    
    for (var kelas in dummyKelas) {
      for (var mapel in kelas.mataPelajaranList) {
        final day = days[kelas.id.hashCode % days.length]; // Simple hash to assign day
        final time = timeSlots[mapel.nama.hashCode % timeSlots.length]; // Simple hash to assign time
        dummyJadwal.add(Jadwal(
          id: 'jadwal_${kelas.id}_${mapel.id}', // Generate a unique ID
          hari: day,
          jam: time,
          mataPelajaran: mapel.nama,
          guruPengampu: mapel.guruNama,
          kelas: kelas.nama,
          kelasId: kelas.id, // Pass kelas.id
          mapelId: mapel.id, // Pass mapel.id
        ));
      }
    }
    await jadwalBox.addAll(dummyJadwal);


    // 6. Generate Dummy Materi
    final List<Materi> dummyMateri = [];
    for (var kelas in dummyKelas) {
      for (var mapel in kelas.mataPelajaranList) {
        final guru = dummyGuru.firstWhere((g) => g.nip == mapel.guruNip); // Get the teacher for the subject

        dummyMateri.add(Materi(
          id: 'materi_${kelas.id}_${mapel.id}_1',
          judul: 'Pendahuluan ${mapel.nama}',
          deskripsi: 'Materi pengantar untuk mata pelajaran ${mapel.nama}. Mencakup konsep dasar dan ruang lingkup.',
          fileUrl: 'https://example.com/materi_${mapel.id}_1.pdf',
          kelasId: kelas.id,
          mataPelajaranId: mapel.id,
          guruId: guru.nip,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ));

        dummyMateri.add(Materi(
          id: 'materi_${kelas.id}_${mapel.id}_2',
          judul: 'Modul ${mapel.nama} - Bab 1',
          deskripsi: 'Modul pembelajaran untuk Bab 1 mata pelajaran ${mapel.nama}.',
          fileUrl: 'https://example.com/modul_${mapel.id}_bab1.docx',
          kelasId: kelas.id,
          mataPelajaranId: mapel.id,
          guruId: guru.nip,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ));
      }
    }
    await materiBox.addAll(dummyMateri);


    // 7. Generate Dummy Tugas and Submissions
    final List<Tugas> dummyTugas = [];
    final List<PengumpulanTugas> dummySubmissions = [];

    for (var kelas in dummyKelas) {
      final studentsInClass = dummySiswa.where((s) => s.kelasId == kelas.id).toList();
      for (var mapel in kelas.mataPelajaranList) {
        final guru = dummyGuru.firstWhere((g) => g.nip == mapel.guruNip);

        // Create 2 assignments per subject
        for (int i = 0; i < 2; i++) {
          final tugasId = 'tugas_${kelas.id}_${mapel.id}_$i';
          final tugas = Tugas(
            id: tugasId,
            judul: 'Tugas ${mapel.nama} ${i + 1}',
            deskripsi: 'Kerjakan soal-soal di halaman ${10 * (i + 1)} buku cetak.',
            kelasId: kelas.id,
            mataPelajaranId: mapel.id,
            guruId: guru.nip,
            deadline: DateTime.now().add(Duration(days: 5 + (i * 7))),
            createdAt: DateTime.now().subtract(Duration(days: 15 - (i * 7))),
          );
          dummyTugas.add(tugas);

          // Simulate some submissions for the first assignment
          if (i == 0) {
            for (int j = 0; j < studentsInClass.length ~/ 2; j++) { // Half of students submit
              final siswa = studentsInClass[j];
              final submission = PengumpulanTugas(
                id: 'sub_${tugasId}_${siswa.nis}',
                tugasId: tugasId,
                siswaNis: siswa.nis,
                content: 'Jawaban saya untuk ${tugas.judul}.',
                submittedAt: DateTime.now().subtract(const Duration(days: 2)),
                nilai: (j % 2 == 0) ? 85.0 : 70.0, // Some graded, some not
                feedback: (j % 2 == 0) ? 'Bagus sekali!' : 'Perlu ditingkatkan.',
              );
              dummySubmissions.add(submission);
            }
          }
        }
      }
    }
    await tugasBox.addAll(dummyTugas);
    await submissionBox.addAll(dummySubmissions);
  }
}