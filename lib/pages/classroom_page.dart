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
  String _selectedSemester = 'Semester 1';
  final List<String> _semesterOptions = [
    'Semester 1', 'Semester 2', 'Semester 3', 
    'Semester 4', 'Semester 5', 'Semester 6'
  ];

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
          child: DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              labelText: 'Pilih Semester',
              border: OutlineInputBorder(),
            ),
            items: _semesterOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedSemester = value);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: studentsInClass.length,
            itemBuilder: (context, index) {
              final siswa = studentsInClass[index];
              // Find existing nilai
              // Note: getNilaiIndex uses (nis, mapelName, semester)
              // We need to retrieve the actual object.
              // Since provider only gives index or filtered list, let's use the list.
              final existingNilai = nilaiProvider.nilaiList.firstWhere(
                (n) => n.nis == siswa.nis && 
                       n.mataPelajaran == widget.mataPelajaran.nama && 
                       n.semester == _selectedSemester,
                orElse: () => Nilai(
                  nis: siswa.nis,
                  namaSiswa: siswa.nama,
                  mataPelajaran: widget.mataPelajaran.nama,
                  semester: _selectedSemester,
                  nilaiTugas: 0,
                  nilaiUTS: 0,
                  nilaiUAS: 0,
                  nilaiKehadiran: 0,
                ),
              );

              return NilaiInputCard(
                siswa: siswa,
                initialNilai: existingNilai,
                mataPelajaran: widget.mataPelajaran,
                semester: _selectedSemester,
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
    _tugasController = TextEditingController(text: widget.initialNilai.nilaiTugas == 0 ? '' : widget.initialNilai.nilaiTugas.toStringAsFixed(0));
    _utsController = TextEditingController(text: widget.initialNilai.nilaiUTS == 0 ? '' : widget.initialNilai.nilaiUTS.toStringAsFixed(0));
    _uasController = TextEditingController(text: widget.initialNilai.nilaiUAS == 0 ? '' : widget.initialNilai.nilaiUAS.toStringAsFixed(0));
    _kehadiranController = TextEditingController(text: widget.initialNilai.nilaiKehadiran == 0 ? '' : widget.initialNilai.nilaiKehadiran.toStringAsFixed(0));
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
    
    final tugas = double.tryParse(_tugasController.text) ?? 0;
    final uts = double.tryParse(_utsController.text) ?? 0;
    final uas = double.tryParse(_uasController.text) ?? 0;
    final kehadiran = double.tryParse(_kehadiranController.text) ?? 0;

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
    double tugas = double.tryParse(_tugasController.text) ?? 0;
    double uts = double.tryParse(_utsController.text) ?? 0;
    double uas = double.tryParse(_uasController.text) ?? 0;
    double kehadiran = double.tryParse(_kehadiranController.text) ?? 0;
    
    // 10% Kehadiran, 20% Tugas, 30% UTS, 40% UAS
    double finalScore = (kehadiran * 0.1) + (tugas * 0.2) + (uts * 0.3) + (uas * 0.4);
    String predikat = '';
    if (finalScore >= 85) predikat = 'A';
    else if (finalScore >= 75) predikat = 'B';
    else if (finalScore >= 65) predikat = 'C';
    else predikat = 'D';

    Color scoreColor = Colors.green;
    if (predikat == 'C') scoreColor = Colors.orange;
    if (predikat == 'D') scoreColor = Colors.red;

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
        subtitle: Text('Akhir: ${finalScore.toStringAsFixed(1)}'),
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
