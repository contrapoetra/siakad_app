import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/kelas.dart';
import '../models/siswa.dart';
import '../models/nilai.dart';
import '../providers/siswa_provider.dart';
import '../providers/guru_provider.dart';
import '../providers/nilai_provider.dart';
import '../widgets/custom_input.dart';

class ClassroomPageArgs {
  final Kelas kelas;
  final MataPelajaran mataPelajaran;

  ClassroomPageArgs({required this.kelas, required this.mataPelajaran});
}

class ClassroomPage extends StatefulWidget {
  final Kelas kelas;
  final MataPelajaran mataPelajaran;

  const ClassroomPage({
    super.key,
    required this.kelas,
    required this.mataPelajaran,
  });

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
      Provider.of<NilaiProvider>(context, listen: false).loadNilai();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentRole;
    final isTeacher = userRole == 'Guru';

    return DefaultTabController(
      length: isTeacher ? 2 : 1, // People, Input Nilai (Teacher only)
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.mataPelajaran.nama} - ${widget.kelas.nama}'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Daftar Siswa', icon: Icon(Icons.people)),
              if (isTeacher) const Tab(text: 'Input Nilai', icon: Icon(Icons.edit_note)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPeopleTab(),
            if (isTeacher) _buildInputNilaiTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTab() {
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final guruProvider = Provider.of<GuruProvider>(context);

    final studentsInClass = siswaProvider.siswaList
        .where((s) => s.kelasId == widget.kelas.id)
        .toList();

    final teacherForSubject = guruProvider.guruList
        .where((g) => g.nip == widget.mataPelajaran.guruNip)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (teacherForSubject != null) ...[
          const Text('Guru Pengampu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(teacherForSubject.nama),
              subtitle: Text(teacherForSubject.email),
            ),
          ),
          const Divider(height: 32),
        ],
        const Text('Daftar Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (studentsInClass.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Belum ada siswa di kelas ini.'),
          ),
        ...studentsInClass.map((siswa) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(siswa.nama),
            subtitle: Text(siswa.nis),
          ),
        )),
      ],
    );
  }

  Widget _buildInputNilaiTab() {
    return InputNilaiView(
      kelas: widget.kelas,
      mataPelajaran: widget.mataPelajaran,
    );
  }
}

class InputNilaiView extends StatefulWidget {
  final Kelas kelas;
  final MataPelajaran mataPelajaran;

  const InputNilaiView({
    super.key,
    required this.kelas,
    required this.mataPelajaran,
  });

  @override
  State<InputNilaiView> createState() => _InputNilaiViewState();
}

class _InputNilaiViewState extends State<InputNilaiView> {
  late String _semester;

  @override
  void initState() {
    super.initState();
    _semester = _deriveSemester(widget.mataPelajaran.nama);
  }

  String _deriveSemester(String subjectName) {
    if (subjectName.contains('X-1')) return 'Semester 1';
    if (subjectName.contains('X-2')) return 'Semester 2';
    if (subjectName.contains('XI-1')) return 'Semester 3';
    if (subjectName.contains('XI-2')) return 'Semester 4';
    if (subjectName.contains('XII-1')) return 'Semester 5';
    if (subjectName.contains('XII-2')) return 'Semester 6';
    return 'Semester 1'; // Default
  }

  @override
  Widget build(BuildContext context) {
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);

    final studentsInClass = siswaProvider.siswaList
        .where((s) => s.kelasId == widget.kelas.id)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Input Nilai - $_semester',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: studentsInClass.length,
            itemBuilder: (context, index) {
              final siswa = studentsInClass[index];
              // Find existing nilai
              final existingNilai = nilaiProvider.nilaiList.firstWhere(
                (n) => n.nis == siswa.nis && 
                       n.mataPelajaran == widget.mataPelajaran.nama && 
                       n.semester == _semester,
                orElse: () => Nilai(
                  nis: siswa.nis,
                  namaSiswa: siswa.nama,
                  mataPelajaran: widget.mataPelajaran.nama,
                  semester: _semester,
                  nilaiTugas: null,
                  nilaiUTS: null,
                  nilaiUAS: null,
                  nilaiKehadiran: null,
                ),
              );

              return NilaiInputCard(
                siswa: siswa,
                initialNilai: existingNilai,
                mataPelajaran: widget.mataPelajaran,
                semester: _semester,
              );
            },
          ),
        ),
      ],
    );
  }
}

class NilaiInputCard extends StatefulWidget {
  final Siswa siswa;
  final Nilai initialNilai;
  final MataPelajaran mataPelajaran;
  final String semester;

  const NilaiInputCard({
    super.key,
    required this.siswa,
    required this.initialNilai,
    required this.mataPelajaran,
    required this.semester,
  });

  @override
  State<NilaiInputCard> createState() => _NilaiInputCardState();
}

class _NilaiInputCardState extends State<NilaiInputCard> {
  late TextEditingController _tugasController;
  late TextEditingController _utsController;
  late TextEditingController _uasController;
  late TextEditingController _kehadiranController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant NilaiInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNilai != widget.initialNilai || oldWidget.semester != widget.semester) {
      _initControllers();
    }
  }

  void _initControllers() {
    _tugasController = TextEditingController(text: widget.initialNilai.nilaiTugas?.toStringAsFixed(0) ?? '');
    _utsController = TextEditingController(text: widget.initialNilai.nilaiUTS?.toStringAsFixed(0) ?? '');
    _uasController = TextEditingController(text: widget.initialNilai.nilaiUAS?.toStringAsFixed(0) ?? '');
    _kehadiranController = TextEditingController(text: widget.initialNilai.nilaiKehadiran?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _tugasController.dispose();
    _utsController.dispose();
    _uasController.dispose();
    _kehadiranController.dispose();
    super.dispose();
  }

  void _saveNilai() async {
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    
    double? parseInput(String text) {
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }

    final tugas = parseInput(_tugasController.text);
    final uts = parseInput(_utsController.text);
    final uas = parseInput(_uasController.text);
    final kehadiran = parseInput(_kehadiranController.text);

    final newNilai = Nilai(
      id: widget.initialNilai.id, // Keep ID if updating
      nis: widget.siswa.nis,
      namaSiswa: widget.siswa.nama,
      mataPelajaran: widget.mataPelajaran.nama,
      semester: widget.semester,
      nilaiTugas: tugas,
      nilaiUTS: uts,
      nilaiUAS: uas,
      nilaiKehadiran: kehadiran,
    );

    // Check if it exists to decide add or update
    final index = nilaiProvider.getNilaiIndex(widget.siswa.nis, widget.mataPelajaran.nama, widget.semester);
    
    try {
      if (index != null) {
        await nilaiProvider.updateNilai(index, newNilai);
      } else {
        await nilaiProvider.addNilai(newNilai);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai tersimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate preview of final score
    double? parseInput(String text) {
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }

    final tugas = parseInput(_tugasController.text);
    final uts = parseInput(_utsController.text);
    final uas = parseInput(_uasController.text);
    final kehadiran = parseInput(_kehadiranController.text);
    
    // 10% Kehadiran, 20% Tugas, 30% UTS, 40% UAS
    String predikat = '-';
    double? finalScore;
    
    if (tugas != null && uts != null && uas != null && kehadiran != null) {
      finalScore = (kehadiran * 0.1) + (tugas * 0.2) + (uts * 0.3) + (uas * 0.4);
      if (finalScore >= 85) predikat = 'A';
      else if (finalScore >= 75) predikat = 'B';
      else if (finalScore >= 65) predikat = 'C';
      else predikat = 'D';
    }

    Color scoreColor = Colors.grey;
    if (predikat == 'A') scoreColor = Colors.green;
    else if (predikat == 'B') scoreColor = Colors.blue;
    else if (predikat == 'C') scoreColor = Colors.orange;
    else if (predikat == 'D') scoreColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (val) => setState(() => _isExpanded = val),
        leading: CircleAvatar(
          backgroundColor: scoreColor,
          child: Text(predikat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(widget.siswa.nama),
        subtitle: Text('Akhir: ${finalScore?.toStringAsFixed(1) ?? '-'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: 'Kehadiran (10%)',
                        controller: _kehadiranController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomInput(
                        label: 'Tugas (20%)',
                        controller: _tugasController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: 'UTS (30%)',
                        controller: _utsController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomInput(
                        label: 'UAS (40%)',
                        controller: _uasController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNilai,
                    child: const Text('Simpan Nilai'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
