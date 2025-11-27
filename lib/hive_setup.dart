import 'package:hive_flutter/hive_flutter.dart';
import 'models/siswa.dart';
import 'models/guru.dart';
import 'models/jadwal.dart';
import 'models/nilai.dart';
import 'models/pengumuman.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(SiswaAdapter());
  Hive.registerAdapter(GuruAdapter());
  Hive.registerAdapter(JadwalAdapter());
  Hive.registerAdapter(NilaiAdapter());
  Hive.registerAdapter(PengumumanAdapter());
  
  // Open Boxes
  await Hive.openBox<Siswa>('siswa');
  await Hive.openBox<Guru>('guru');
  await Hive.openBox<Jadwal>('jadwal');
  await Hive.openBox<Nilai>('nilai');
  await Hive.openBox<Pengumuman>('pengumuman');
  
  // Initialize dummy data
  await _initializeDummyData();
}

Future<void> _initializeDummyData() async {
  final siswaBox = Hive.box<Siswa>('siswa');
  final guruBox = Hive.box<Guru>('guru');
  final jadwalBox = Hive.box<Jadwal>('jadwal');
  final pengumumanBox = Hive.box<Pengumuman>('pengumuman');
  
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
}
