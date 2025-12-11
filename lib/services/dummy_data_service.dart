import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/kelas.dart';

class DummyDataService {
  Future<void> generateDummyData() async {
    final userBox = Hive.box<User>('users');
    final siswaBox = Hive.box<Siswa>('siswa');
    final guruBox = Hive.box<Guru>('guru');
    final kelasBox = Hive.box<Kelas>('kelas');

    // Clear existing data
    await userBox.clear();
    await siswaBox.clear();
    await guruBox.clear();
    await kelasBox.clear();

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


    // 3. Generate 30 Siswa data
    final List<Siswa> dummySiswa = [];
    final List<String> studentNames = [
      'Ahmad Rizki', 'Siti Nurhaliza', 'Abbiyi QS', 'Budi Santoso', 'Dewi Lestari',
      'Faisal Rahman', 'Gita Putri', 'Hadi Wijaya', 'Indah Permata', 'Joko Susilo',
      'Kartika Sari', 'Lukman Hakim', 'Maya Indah', 'Nia Ramadhani', 'Oki Setiana',
      'Putri Ayu', 'Qori Akbar', 'Rina Fitri', 'Santi Dewi', 'Taufik Hidayat',
      'Umar Said', 'Vina Amelia', 'Wira Negara', 'Xena Putri', 'Yanti Susanti',
      'Zainal Arifin', 'Ani Suryani', 'Doni Pratama', 'Eka Fitriani', 'Gatot Subroto'
    ];

    for (int i = 0; i < 30; i++) {
      final nis = '2024${(i + 1).toString().padLeft(3, '0')}';
      final name = studentNames[i];
      final email = '${name.toLowerCase().replaceAll(' ', '.')}${i + 1}@example.com';
      final dob = DateTime(2007 - (i % 2), (i % 12) + 1, (i % 28) + 1);
      final pob = placesOfBirth[i % placesOfBirth.length];
      final father = 'Ayah ${name.split(' ')[0]}';
      final mother = 'Ibu ${name.split(' ')[0]}';
      
      // Assign to a class cyclically
      final assignedClass = dummyKelas[i % dummyKelas.length];

      dummySiswa.add(Siswa(
        nis: nis,
        nama: name,
        email: email,
        tanggalLahir: dob,
        tempatLahir: pob,
        namaAyah: father,
        namaIbu: mother,
        kelas: assignedClass.tingkat, // Legacy field
        jurusan: assignedClass.jurusan, // Legacy field
        kelasId: assignedClass.id, // New field
      ));
    }

    // Add dummy siswa to box
    await siswaBox.addAll(dummySiswa);

    // 4. Generate User data from Siswa and Guru
    await userBox.add(User(nomorInduk: 'admin', password: 'admin123', role: 'Admin', email: 'admin@example.com', isPasswordSet: true)); // Admin user

    for (var siswa in dummySiswa) {
      await userBox.add(User(
        nomorInduk: siswa.nis,
        password: '', // Password will be set via forgot password
        role: 'Siswa',
        email: siswa.email,
        isPasswordSet: false,
      ));
    }

    for (var guru in dummyGuru) {
      await userBox.add(User(
        nomorInduk: guru.nip,
        password: '', // Password will be set via forgot password
        role: 'Siswa', // Initial role is Siswa, requires admin approval for Guru role
        requestedRole: 'Guru',
        requestStatus: 'pending',
        email: guru.email,
        isPasswordSet: false,
      ));
    }
  }
}