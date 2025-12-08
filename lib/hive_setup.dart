import 'package:hive_flutter/hive_flutter.dart';
import 'models/siswa.dart';
import 'models/guru.dart';
import 'models/jadwal.dart';
import 'models/nilai.dart';
import 'models/pengumuman.dart';
import 'models/user.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.deleteFromDisk(); // !!! TEMPORARY: Clear all Hive data to resolve TypeAdapter conflicts !!!

  // Register Adapters
  Hive.registerAdapter(SiswaAdapter());
  Hive.registerAdapter(GuruAdapter());
  Hive.registerAdapter(JadwalAdapter());
  Hive.registerAdapter(NilaiAdapter());
  Hive.registerAdapter(PengumumanAdapter());
  Hive.registerAdapter(UserAdapter());

  // Open Boxes
  await Hive.openBox<Siswa>('siswa');
  await Hive.openBox<Guru>('guru');
  await Hive.openBox<Jadwal>('jadwal');
  await Hive.openBox<Nilai>('nilai');
  await Hive.openBox<Pengumuman>('pengumuman');
  await Hive.openBox<User>('users'); // Open the users box

  // Initialize dummy data
  await _initializeDummyData();
}

Future<void> _initializeDummyData() async {
  final siswaBox = Hive.box<Siswa>('siswa');
  final guruBox = Hive.box<Guru>('guru');
  final jadwalBox = Hive.box<Jadwal>('jadwal');
  final pengumumanBox = Hive.box<Pengumuman>('pengumuman');
  final userBox = Hive.box<User>('users'); // Get the users box

  // Add dummy siswa if empty
  if (siswaBox.isEmpty) {
    await siswaBox.add(Siswa(
      nis: '2024001',
      nama: 'Ahmad Rizki',
      kelas: 'XII',
      jurusan: 'IPA',
    ));
    await siswaBox.add(Siswa(
      nis: '2024002',
      nama: 'Siti Nurhaliza',
      kelas: 'XII',
      jurusan: 'IPS',
    ));
    await siswaBox.add(Siswa(
      nis: '2024003',
      nama: 'Abbiyi QS',
      kelas: 'XII',
      jurusan: 'IPA',
    ));
  }

  // Add dummy guru if empty
  if (guruBox.isEmpty) {
    await guruBox.add(Guru(
      nip: '198501012010011001',
      nama: 'Dr. Budi Santoso',
      mataPelajaran: 'Matematika',
    ));
    await guruBox.add(Guru(
      nip: '198702022012012001',
      nama: 'Siti Aminah, S.Pd',
      mataPelajaran: 'Bahasa Indonesia',
    ));
    await guruBox.add(Guru(
      nip: '199003032015031001',
      nama: 'Andi Wijaya, M.Pd',
      mataPelajaran: 'Fisika',
    ));
  }

  // Add dummy jadwal if empty
  if (jadwalBox.isEmpty) {
    await jadwalBox.add(Jadwal(
      hari: 'Senin',
      jam: '07:00 - 08:30',
      mataPelajaran: 'Matematika',
      guruPengampu: 'Dr. Budi Santoso',
      kelas: 'XII IPA',
    ));
    await jadwalBox.add(Jadwal(
      hari: 'Senin',
      jam: '08:30 - 10:00',
      mataPelajaran: 'Fisika',
      guruPengampu: 'Andi Wijaya, M.Pd',
      kelas: 'XII IPA',
    ));
    await jadwalBox.add(Jadwal(
      hari: 'Selasa',
      jam: '07:00 - 08:30',
      mataPelajaran: 'Bahasa Indonesia',
      guruPengampu: 'Siti Aminah, S.Pd',
      kelas: 'XII IPA',
    ));
  }

  // Add dummy pengumuman if empty
  if (pengumumanBox.isEmpty) {
    await pengumumanBox.add(Pengumuman(
      judul: 'Selamat Datang di SIAKAD XYZ',
      isi: 'Sistem informasi akademik telah aktif. Silakan gunakan dengan bijak.',
      tanggal: DateTime.now(),
    ));
    await pengumumanBox.add(Pengumuman(
      judul: 'Jadwal UTS Semester Ganjil',
      isi: 'UTS akan dilaksanakan pada tanggal 1-5 Desember 2025. Harap mempersiapkan diri dengan baik.',
      tanggal: DateTime.now(),
    ));
  }

  // Add dummy users if empty
  if (userBox.isEmpty) {
    await userBox.add(User(username: 'admin', password: 'admin123', role: 'Admin'));
    await userBox.add(User(username: 'guru', password: 'guru123', role: 'Guru'));
    // Use NIS for siswa username for consistency, or nama if that's what's expected for login
    // For now, using nama as it's in the current AuthProvider
    await userBox.add(User(username: 'Ahmad Rizki', password: 'siswa123', role: 'Siswa'));
    await userBox.add(User(username: 'Siti Nurhaliza', password: 'siswa123', role: 'Siswa'));
    await userBox.add(User(username: 'Abbiyi QS', password: 'siswa123', role: 'Siswa'));
  }
}
