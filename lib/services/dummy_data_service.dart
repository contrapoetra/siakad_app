import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart';
import '../models/guru.dart';

class DummyDataService {
  Future<void> generateDummyData() async {
    final userBox = Hive.box<User>('users');
    final siswaBox = Hive.box<Siswa>('siswa');
    final guruBox = Hive.box<Guru>('guru');

    // Clear existing data
    await userBox.clear();
    await siswaBox.clear();
    await guruBox.clear();

    // Generate 30 Siswa data
    final List<Siswa> dummySiswa = [];
    final List<String> studentNames = [
      'Ahmad Rizki', 'Siti Nurhaliza', 'Abbiyi QS', 'Budi Santoso', 'Dewi Lestari',
      'Faisal Rahman', 'Gita Putri', 'Hadi Wijaya', 'Indah Permata', 'Joko Susilo',
      'Kartika Sari', 'Lukman Hakim', 'Maya Indah', 'Nia Ramadhani', 'Oki Setiana',
      'Putri Ayu', 'Qori Akbar', 'Rina Fitri', 'Santi Dewi', 'Taufik Hidayat',
      'Umar Said', 'Vina Amelia', 'Wira Negara', 'Xena Putri', 'Yanti Susanti',
      'Zainal Arifin', 'Ani Suryani', 'Doni Pratama', 'Eka Fitriani', 'Gatot Subroto'
    ];
    final List<String> classes = ['X', 'XI', 'XII'];
    final List<String> majors = ['IPA', 'IPS', 'Bahasa'];
    final List<String> placesOfBirth = ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar'];

    for (int i = 0; i < 30; i++) {
      final nis = '2024${(i + 1).toString().padLeft(3, '0')}';
      final name = studentNames[i];
      final email = '${name.toLowerCase().replaceAll(' ', '.')}${i + 1}@example.com';
      final dob = DateTime(2007 - (i % 2), (i % 12) + 1, (i % 28) + 1);
      final pob = placesOfBirth[i % placesOfBirth.length];
      final father = 'Ayah ${name.split(' ')[0]}';
      final mother = 'Ibu ${name.split(' ')[0]}';
      final studentClass = classes[i % classes.length];
      final major = majors[i % majors.length];

      dummySiswa.add(Siswa(
        nis: nis,
        nama: name,
        email: email,
        tanggalLahir: dob,
        tempatLahir: pob,
        namaAyah: father,
        namaIbu: mother,
        kelas: studentClass,
        jurusan: major,
      ));
    }

    // Generate 5 Guru data
    final List<Guru> dummyGuru = [];
    final List<String> teacherNames = [
      'Dr. Rina Wati', 'Prof. Joko Santoso', 'Dra. Ani Suryani', 'M.Pd. Budi Cahyono', 'S.Pd. Siti Aisyah'
    ];
    final List<String> degrees = [
      'Dr., M.Pd.', 'Prof. Dr.', 'S.Pd., M.Sc.', 'M.Pd.', 'S.Pd.'
    ];

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

    // Add dummy siswa to box
    await siswaBox.addAll(dummySiswa);

    // Add dummy guru to box
    await guruBox.addAll(dummyGuru);

    // Generate User data from Siswa and Guru
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
