import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/kelas.dart';
import '../models/materi.dart';
import '../models/tugas.dart';
import '../models/pengumpulan_tugas.dart';
import '../models/jadwal.dart'; // Import Jadwal model
import '../models/nilai.dart'; // Import Nilai model
import '../models/pengumuman.dart'; // Import Pengumuman model
import 'dart:math'; // Import for Random

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
    final nilaiBox = Hive.box<Nilai>('nilai'); // Access Nilai box
    final pengumumanBox = Hive.box<Pengumuman>('pengumuman'); // Access Pengumuman box

    // Clear existing data
    await userBox.clear();
    await siswaBox.clear();
    await guruBox.clear();
    await kelasBox.clear();
    await materiBox.clear();
    await tugasBox.clear();
    await submissionBox.clear();
    await jadwalBox.clear(); // Clear Jadwal box
    await nilaiBox.clear(); // Clear Nilai box
    await pengumumanBox.clear(); // Clear Pengumuman box

    // 0. Generate Dummy Pengumuman
    final List<Pengumuman> dummyPengumuman = [
      Pengumuman(
        judul: 'Libur Semester Ganjil',
        isi: 'Diberitahukan kepada seluruh siswa bahwa libur semester ganjil akan dimulai pada tanggal 20 Desember 2024 sampai dengan 5 Januari 2025. Selamat berlibur!',
        tanggal: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Pengumuman(
        judul: 'Jadwal UAS Semester Genap',
        isi: 'Ujian Akhir Semester Genap akan dilaksanakan mulai tanggal 10 Juni 2025. Harap mempersiapkan diri dengan baik.',
        tanggal: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Pengumuman(
        judul: 'Kegiatan Porseni Sekolah',
        isi: 'Pekan Olahraga dan Seni (Porseni) akan diadakan setelah UAS selesai. Segera daftarkan tim kelas kalian!',
        tanggal: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Pengumuman(
        judul: 'Pengambilan Kartu Rencana Studi',
        isi: 'Pengambilan KRS untuk semester depan dapat dilakukan mulai hari Senin di ruang Tata Usaha.',
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    await pengumumanBox.addAll(dummyPengumuman);

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

    // 2. Define Semester Subjects Mapping
    // 2 Subjects per Semester, No repeats.
    // X: Sem 1, 2
    // XI: Sem 3, 4
    // XII: Sem 5, 6
    final Map<int, List<String>> semesterSubjects = {
      1: ['Matematika X-1', 'Bahasa Indonesia X-1', 'Fisika X-1', 'Biologi X-1'],
      2: ['Matematika X-2', 'Bahasa Inggris X-2', 'Kimia X-2', 'Sejarah X-2'],
      3: ['Matematika XI-1', 'Bahasa Indonesia XI-1', 'Fisika XI-1', 'Ekonomi XI-1'],
      4: ['Matematika XI-2', 'Bahasa Inggris XI-2', 'Kimia XI-2', 'Sosiologi XI-2'],
      5: ['Matematika XII-1', 'Bahasa Indonesia XII-1', 'Fisika XII-1', 'Geografi XII-1'],
      6: ['Matematika XII-2', 'Bahasa Inggris XII-2', 'Kimia XII-2', 'Seni Budaya XII-2'],
    };

    // Helper to get random teacher
    Guru getRandomGuru() => dummyGuru[DateTime.now().microsecond % dummyGuru.length];

    // 3. Generate Classes (Kelas)
    // Classes contain subjects relevant to their level (e.g. X contains Sem 1 & 2 subjects)
    final List<Kelas> dummyKelas = [];
    final levels = ['X', 'XI', 'XII'];
    final majors = ['IPA', 'IPS'];
    
    int classIdCounter = 1;
    for (var level in levels) {
      for (var major in majors) {
        final className = '$level $major 1';
        final subjects = <MataPelajaran>[];
        
        // Determine semesters for this level
        List<int> semesters = [];
        if (level == 'X') semesters = [1, 2];
        else if (level == 'XI') semesters = [3, 4];
        else if (level == 'XII') semesters = [5, 6];

        // Add subjects from these semesters to the class
        for (var sem in semesters) {
          final semSubjects = semesterSubjects[sem] ?? [];
          for (int i = 0; i < semSubjects.length; i++) {
             final subjName = semSubjects[i];
             
             // Force specific teacher for demonstration purposes
             // For Kelas 3 (XI IPA 1), Subject in Sem 3 (Matematika XI-1), assign to Dr. Rina (1985...)
             Guru teacher;
             if (classIdCounter == 3 && sem == 3 && i == 0) {
               teacher = dummyGuru[0]; // 198501012010011001
             } else {
               teacher = getRandomGuru();
             }

             subjects.add(MataPelajaran(
               id: 'mapel_${classIdCounter}_${subjName.replaceAll(' ', '_')}',
               nama: subjName,
               guruNip: teacher.nip,
               guruNama: teacher.nama,
             ));
          }
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


    // 4. Generate Siswa data (at least 10 per class)
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
    final placesOfBirthSiswa = ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar'];

    int studentCount = 0;
    for (var kelas in dummyKelas) {
      for (int i = 0; i < 15; i++) { // 15 students per class
        String nis;
        // Place Ahmad Rizki (2024001) in Kelas 3 (XI IPA 1) as the first student
        if (kelas.id == 'kelas_3' && i == 0) {
          nis = '2024001';
        } else {
          // Generate other NIS, ensuring we don't duplicate 2024001
          // We can just increment from a base, skipping 2024001 effectively if we start elsewhere or handle it.
          // Simple approach: Use counter but mapping 0->2024001 handled above.
          // Just ensure uniqueness.
          nis = '2024${(studentCount + 2).toString().padLeft(3, '0')}'; 
        }

        final name = '${studentFirstNames[studentCount % studentFirstNames.length]} ${studentLastNames[studentCount % studentLastNames.length]}';
        final email = '${name.toLowerCase().replaceAll(' ', '.')}${studentCount + 1}@example.com';
        final dob = DateTime(2007 - (i % 2), (i % 12) + 1, (i % 28) + 1);
        final pob = placesOfBirthSiswa[i % placesOfBirthSiswa.length];
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

    // 5. Generate User data from Siswa and Guru
    await userBox.add(User(nomorInduk: 'admin', password: 'admin123', role: 'Admin', email: 'admin@example.com', isPasswordSet: true, name: 'Administrator')); // Admin user

    for (var siswa in dummySiswa) {
      await userBox.add(User(
        nomorInduk: siswa.nis,
        password: 'password', // Set a default password for easier login
        role: 'Siswa',
        email: siswa.email,
        isPasswordSet: true, // Mark as set
        name: siswa.nama, // Use siswa's name
      ));
    }

    for (var guru in dummyGuru) {
      await userBox.add(User(
        nomorInduk: guru.nip,
        password: 'password', // Set a default password for easier login
        role: 'Guru', // Changed to Guru directly for dummy
        email: guru.email,
        isPasswordSet: true, // Mark as set
        name: guru.nama, // Use guru's name
      ));
    }

    // 6. Generate Dummy Jadwal
    final List<Jadwal> dummyJadwal = [];
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
    final timeSlots = ['07:00-08:30', '08:30-10:00', '10:00-11:30', '13:00-14:30'];
    
    for (var kelas in dummyKelas) {
      // Create schedule only for subjects in the "current" semester (e.g., odd semester for simplicity: 1, 3, 5)
      // To simulate active classes
      // Also maybe Sem 2, 4, 6 if we assume full year schedule? 
      // Let's just schedule ALL subjects in the class for now to ensure populated dashboard
      
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


    // 7. Generate Dummy Nilai (Grades)
    final List<Nilai> dummyNilai = [];
    final random = Random();

    // Iterate through students
    for (var siswa in dummySiswa) {
      final kelas = dummyKelas.firstWhere((k) => k.id == siswa.kelasId);
      
      // Determine max semester based on level
      int maxSemester = 0;
      if (kelas.tingkat == 'X') maxSemester = 2; // Has data for Sem 1 and 2
      else if (kelas.tingkat == 'XI') maxSemester = 4; // Has data for Sem 1, 2, 3, 4
      else if (kelas.tingkat == 'XII') maxSemester = 6; // Has data for Sem 1, 2, 3, 4, 5, 6

      // Generate grades for ALL previous semesters and current
      for (int sem = 1; sem <= maxSemester; sem++) {
        final subjectsForSem = semesterSubjects[sem] ?? [];
        
        for (var subjectName in subjectsForSem) {
          // Find the subject object to check the teacher
          final mapel = kelas.mataPelajaranList.firstWhere(
            (m) => m.nama == subjectName,
            orElse: () => MataPelajaran(id: 'dummy', nama: subjectName, guruNip: '', guruNama: ''),
          );

          double? nilaiTugas;
          double? nilaiUTS;
          double? nilaiUAS;
          double? nilaiKehadiran;

          // Scenario: Student 2024001 has NOT been graded for the subject taught by 1985... in Semester 3
          if (siswa.nis == '2024001' && sem == 3 && mapel.guruNip == '198501012010011001') {
             // Leave as null
          } else {
            // Generate grade
            nilaiTugas = (70 + random.nextInt(30)).toDouble(); // 70-99
            nilaiUTS = (70 + random.nextInt(30)).toDouble();
            nilaiUAS = (70 + random.nextInt(30)).toDouble();
            nilaiKehadiran = (80 + random.nextInt(20)).toDouble(); // Better attendance usually
          }

          dummyNilai.add(Nilai(
            nis: siswa.nis,
            namaSiswa: siswa.nama,
            mataPelajaran: subjectName,
            semester: 'Semester $sem', // Format: "Semester 1"
            nilaiTugas: nilaiTugas,
            nilaiUTS: nilaiUTS,
            nilaiUAS: nilaiUAS,
            nilaiKehadiran: nilaiKehadiran,
          ));
        }
      }
    }
    await nilaiBox.addAll(dummyNilai);
  }
}
