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
    // LMS features scrapped. We clear the box but do not generate data.
    // await materiBox.addAll(dummyMateri);


    // 7. Generate Dummy Tugas and Submissions
    // LMS features scrapped. We clear the box but do not generate data.
    // await tugasBox.addAll(dummyTugas);
    // await submissionBox.addAll(dummySubmissions);

    // 8. Generate Dummy Nilai (Grades)
    final List<Nilai> dummyNilai = [];
    final random = Random();
    final List<String> semesterOptions = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6'];

    // Iterate through a subset of students and subjects to create grades
    for (var siswa in dummySiswa) {
      // Find the class the student belongs to
      final kelas = dummyKelas.firstWhere((k) => k.id == siswa.kelasId);

      // Assign grades for some of the subjects in their class
      for (var mapel in kelas.mataPelajaranList) {
        // Only generate grades for 60% of subjects for a bit of realism
        // if (random.nextDouble() < 0.6) { // <--- This is the key condition
          final nilaiTugas = (60 + random.nextInt(40)).toDouble(); // 60-99
          final nilaiUTS = (60 + random.nextInt(40)).toDouble();
          final nilaiUAS = (60 + random.nextInt(40)).toDouble();
          final nilaiKehadiran = (60 + random.nextInt(40)).toDouble();
          final semester = semesterOptions[random.nextInt(semesterOptions.length)]; // Random semester

          dummyNilai.add(Nilai(
            nis: siswa.nis,
            namaSiswa: siswa.nama,
            mataPelajaran: mapel.nama,
            semester: semester, // New: Add semester
            nilaiTugas: nilaiTugas,
            nilaiUTS: nilaiUTS,
            nilaiUAS: nilaiUAS,
            nilaiKehadiran: nilaiKehadiran,
          ));
        // }
      }
    }
    await nilaiBox.addAll(dummyNilai);  }
}