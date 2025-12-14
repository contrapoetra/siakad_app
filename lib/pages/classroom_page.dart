import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/kelas.dart';
import '../models/siswa.dart';
import '../models/materi.dart';
import '../models/tugas.dart';
import '../models/pengumpulan_tugas.dart';
import '../models/absensi.dart'; // Add this import
import '../providers/materi_provider.dart';
import '../providers/tugas_provider.dart';
import '../providers/submission_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/guru_provider.dart';
import '../providers/absensi_provider.dart'; // Add this import
import 'package:intl/intl.dart';

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
    // Load all relevant data
    Provider.of<MateriProvider>(context, listen: false); // Just to ensure provider is alive
    Provider.of<TugasProvider>(context, listen: false).loadTugas();
    Provider.of<SubmissionProvider>(context, listen: false); // Just to ensure provider is alive
    Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
    Provider.of<GuruProvider>(context, listen: false).loadGuru();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentRole;
    final isTeacher = userRole == 'Guru';
    
    return DefaultTabController(
      length: isTeacher ? 5 : 4, // Stream, Classwork, People, Grades (Teacher), Absensi
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.mataPelajaran.nama} - ${widget.kelas.nama}'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Stream', icon: Icon(Icons.dashboard, color: Theme.of(context).colorScheme.onSurface)),
              Tab(text: 'Classwork', icon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.onSurface)),
              Tab(text: 'People', icon: Icon(Icons.people, color: Theme.of(context).colorScheme.onSurface)),
              if (isTeacher) Tab(text: 'Grades', icon: Icon(Icons.grade, color: Theme.of(context).colorScheme.onSurface)),
              Tab(text: 'Absensi', icon: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onSurface)), // New Absensi tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStreamTab(isTeacher),
            _buildClassworkTab(isTeacher),
            _buildPeopleTab(),
            if (isTeacher) _buildGradesTab(),
            _buildAbsensiTab(isTeacher), // New tab view
          ],
        ),
      ),
    );
  }

  Widget _buildStreamTab(bool isTeacher) {
    // In a real app, this would show announcements specific to this class/subject
    // For now, it's a placeholder.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Stream untuk ${widget.mataPelajaran.nama} - ${widget.kelas.nama}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isTeacher ? 'Posting pengumuman baru di sini.' : 'Lihat pengumuman dari guru Anda di sini.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassworkTab(bool isTeacher) {
    final materiProvider = Provider.of<MateriProvider>(context);
    final tugasProvider = Provider.of<TugasProvider>(context);
    
    final materiList = materiProvider.getMateriByKelasAndMapel(widget.kelas.id, widget.mataPelajaran.id);
    final tugasList = tugasProvider.getTugasByKelas(widget.kelas.id)
        .where((t) => t.mataPelajaranId == widget.mataPelajaran.id)
        .toList();

    return ListView(
      children: [
        if (isTeacher)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddMaterialDialog(context),
                  icon: const Icon(Icons.post_add),
                  label: const Text('Tambah Materi'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAssignmentDialog(context),
                  icon: const Icon(Icons.assignment_add),
                  label: const Text('Tambah Tugas'),
                ),
              ],
            ),
          ),
        const Divider(),
        ...materiList.map((materi) => MateriCard(materi: materi, isTeacher: isTeacher)),
        ...tugasList.map((tugas) => TugasCard(tugas: tugas, isTeacher: isTeacher, siswaNis: Provider.of<AuthProvider>(context).currentUserId!)),
      ],
    );
  }

  Widget _buildPeopleTab() {
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final guruProvider = Provider.of<GuruProvider>(context);

    final studentsInClass = siswaProvider.siswaList
        .where((s) => s.kelasId == widget.kelas.id)
        .toList();
    
    final teacherForSubject = guruProvider.guruList
        .firstWhere((g) => g.nip == widget.mataPelajaran.guruNip);

    return ListView(
      children: [
        ListTile(
          title: const Text('Guru', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(teacherForSubject.nama),
          subtitle: Text(teacherForSubject.email),
        ),
        const Divider(),
        ListTile(
          title: const Text('Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...studentsInClass.map((siswa) => ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(siswa.nama),
          subtitle: Text(siswa.nis),
        )),
      ],
    );
  }

  Widget _buildGradesTab() {
    final tugasProvider = Provider.of<TugasProvider>(context);
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final siswaProvider = Provider.of<SiswaProvider>(context);

    final tugasList = tugasProvider.getTugasByKelas(widget.kelas.id)
        .where((t) => t.mataPelajaranId == widget.mataPelajaran.id)
        .toList();
    
    final studentsInClass = siswaProvider.siswaList
        .where((s) => s.kelasId == widget.kelas.id)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Nama Siswa')),
          ...tugasList.map((t) => DataColumn(label: Text(t.judul))),
        ],
        rows: studentsInClass.map((siswa) {
          return DataRow(
            cells: [
              DataCell(Text(siswa.nama)),
              ...tugasList.map((tugas) {
                final submission = submissionProvider.getSubmissionByTugasAndSiswa(tugas.id, siswa.nis);
                return DataCell(
                  Text(submission?.nilai?.toStringAsFixed(0) ?? '-'),
                  onTap: () {
                    // Show grading dialog
                    _showGradeSubmissionDialog(context, tugas, siswa, submission);
                  },
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Materi Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Materi'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL File/Link (Opsional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                final guruId = Provider.of<AuthProvider>(context, listen: false).currentUserId!;
                final newMateri = Materi(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  judul: titleController.text,
                  deskripsi: descController.text,
                  fileUrl: urlController.text.isEmpty ? null : urlController.text,
                  kelasId: widget.kelas.id,
                  mataPelajaranId: widget.mataPelajaran.id,
                  guruId: guruId,
                  createdAt: DateTime.now(),
                );
                Provider.of<MateriProvider>(context, listen: false).addMateri(newMateri);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAssignmentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Tugas Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul Tugas'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                  ),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => selectedDeadline = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Deadline'),
                      child: Text(DateFormat('dd MMM yyyy').format(selectedDeadline)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    final guruId = Provider.of<AuthProvider>(context, listen: false).currentUserId!;
                    final newTugas = Tugas(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: titleController.text,
                      deskripsi: descController.text,
                      kelasId: widget.kelas.id,
                      mataPelajaranId: widget.mataPelajaran.id,
                      guruId: guruId,
                      deadline: selectedDeadline,
                      createdAt: DateTime.now(),
                    );
                    Provider.of<TugasProvider>(context, listen: false).addTugas(newTugas);
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGradeSubmissionDialog(BuildContext context, Tugas tugas, Siswa siswa, PengumpulanTugas? submission) {
    final gradeController = TextEditingController(text: submission?.nilai?.toString() ?? '');
    final feedbackController = TextEditingController(text: submission?.feedback ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nilai Tugas: ${tugas.judul}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Siswa: ${siswa.nama} (${siswa.nis})'),
              Text('Submitted: ${submission == null ? 'Belum mengumpulkan' : DateFormat('dd MMM yyyy HH:mm').format(submission.submittedAt)}'),
              if (submission?.content != null) Text('Konten: ${submission!.content}'),
              if (submission?.fileUrl != null) Text('File: ${submission!.fileUrl}'),
              const SizedBox(height: 16),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Nilai'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(labelText: 'Feedback'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final double? nilai = double.tryParse(gradeController.text);
                if (nilai != null) {
                  Provider.of<SubmissionProvider>(context, listen: false).gradeSubmission(
                    tugas.id,
                    siswa.nis,
                    nilai,
                    feedbackController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan Nilai'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAbsensiTab(bool isTeacher) {
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final absensiProvider = Provider.of<AbsensiProvider>(context);

    final studentsInClass = siswaProvider.siswaList
        .where((s) => s.kelasId == widget.kelas.id)
        .toList();

    return isTeacher
        ? TeacherAbsensiView(
            kelasId: widget.kelas.id,
            mataPelajaranId: widget.mataPelajaran.id,
            studentsInClass: studentsInClass,
            absensiProvider: absensiProvider,
          )
        : StudentAbsensiView(
            siswaNis: Provider.of<AuthProvider>(context, listen: false).currentUserId!,
            kelasId: widget.kelas.id,
            mataPelajaranId: widget.mataPelajaran.id,
            absensiProvider: absensiProvider,
          );
  }
}

class MateriCard extends StatelessWidget {
  final Materi materi;
  final bool isTeacher;

  const MateriCard({super.key, required this.materi, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(materi.judul),
        subtitle: Text(materi.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: isTeacher
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<MateriProvider>(context, listen: false).deleteMateri(materi.key);
                },
              )
            : null,
        onTap: () {
          // Open material (e.g., launch URL or show full content)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(materi.judul),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(materi.deskripsi),
                  if (materi.fileUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton.icon(
                        onPressed: () {
                          // Implement URL launcher here
                          // launchUrl(Uri.parse(materi.fileUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Membuka link: ${materi.fileUrl}')),
                          );
                        },
                        icon: const Icon(Icons.link),
                        label: Text(materi.fileUrl!),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TugasCard extends StatelessWidget {
  final Tugas tugas;
  final bool isTeacher;
  final String siswaNis;

  const TugasCard({super.key, required this.tugas, required this.isTeacher, required this.siswaNis});

  @override
  Widget build(BuildContext context) {
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final currentSubmission = submissionProvider.getSubmissionByTugasAndSiswa(tugas.id, siswaNis);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined),
        title: Text(tugas.judul),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tugas.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('Deadline: ${DateFormat('dd MMM yyyy').format(tugas.deadline)}',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
            if (!isTeacher)
              Text(
                currentSubmission == null
                    ? 'Status: Belum Dikumpulkan'
                    : 'Status: Sudah Dikumpulkan (${DateFormat('dd MMM yyyy').format(currentSubmission.submittedAt)})',
                style: TextStyle(
                  color: currentSubmission == null ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isTeacher && currentSubmission?.nilai != null)
              Text(
                'Nilai: ${currentSubmission!.nilai}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (!isTeacher && currentSubmission?.feedback != null)
              Text('Feedback: ${currentSubmission!.feedback}'),
          ],
        ),
        isThreeLine: true,
        trailing: isTeacher
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<TugasProvider>(context, listen: false).deleteTugas(tugas.key);
                },
              )
            : (currentSubmission == null
                ? ElevatedButton(
                    onPressed: () => _showSubmitAssignmentDialog(context, tugas, siswaNis),
                    child: const Text('Kumpulkan'),
                  )
                : null),
        onTap: () {
          // Show assignment details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(tugas.judul),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tugas.deskripsi),
                  const SizedBox(height: 8),
                  Text('Deadline: ${DateFormat('dd MMM yyyy HH:mm').format(tugas.deadline)}'),
                  if (!isTeacher && currentSubmission != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text('Dikumpulkan: ${DateFormat('dd MMM yyyy HH:mm').format(currentSubmission.submittedAt)}'),
                        if (currentSubmission.content != null) Text('Konten Anda: ${currentSubmission.content}'),
                        if (currentSubmission.fileUrl != null) Text('File Anda: ${currentSubmission.fileUrl}'),
                        if (currentSubmission.nilai != null) Text('Nilai: ${currentSubmission.nilai}'),
                        if (currentSubmission.feedback != null) Text('Feedback: ${currentSubmission.feedback}'),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSubmitAssignmentDialog(BuildContext context, Tugas tugas, String siswaNis) {
    final contentController = TextEditingController();
    final fileUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kumpulkan Tugas: ${tugas.judul}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Teks Jawaban (Opsional)'),
                maxLines: 3,
              ),
              TextField(
                controller: fileUrlController,
                decoration: const InputDecoration(labelText: 'Link File (Opsional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isEmpty && fileUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Setidaknya isi teks jawaban atau link file.')),
                  );
                  return;
                }
                final newSubmission = PengumpulanTugas(
                  id: '${tugas.id}_$siswaNis',
                  tugasId: tugas.id,
                  siswaNis: siswaNis,
                  content: contentController.text.isEmpty ? null : contentController.text,
                  fileUrl: fileUrlController.text.isEmpty ? null : fileUrlController.text,
                  submittedAt: DateTime.now(),
                );
                Provider.of<SubmissionProvider>(context, listen: false).submitAssignment(newSubmission);
                Navigator.pop(context);
              },
              child: const Text('Kumpulkan'),
            ),
          ],
        );
      },
    );
  }
}

class TeacherAbsensiView extends StatefulWidget {
  final String kelasId;
  final String mataPelajaranId;
  final List<Siswa> studentsInClass;
  final AbsensiProvider absensiProvider;

  const TeacherAbsensiView({
    super.key,
    required this.kelasId,
    required this.mataPelajaranId,
    required this.studentsInClass,
    required this.absensiProvider,
  });

  @override
  State<TeacherAbsensiView> createState() => _TeacherAbsensiViewState();
}

class _TeacherAbsensiViewState extends State<TeacherAbsensiView> {
  DateTime _selectedDate = DateTime.now();
  Map<String, String> _attendanceStatus = {}; // Map<siswaNis, status>

  @override
  void initState() {
    super.initState();
    _loadAttendanceForDate();
  }





  Future<void> _loadAttendanceForDate() async {
    final normalizedSelectedDate = _normalizeDate(_selectedDate);
    final existingAbsensi = await widget.absensiProvider.getAbsensiForDate(
      widget.kelasId,
      widget.mataPelajaranId,
      normalizedSelectedDate,
    );

    setState(() {
      _attendanceStatus = existingAbsensi?.dataKehadiran ?? {};
      // Initialize with 'Hadir' if not present in existing data
      for (var student in widget.studentsInClass) {
        if (!_attendanceStatus.containsKey(student.nis)) {
          _attendanceStatus[student.nis] = 'Hadir';
        }
      }
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceForDate();
    }
  }

  Future<void> _saveAttendance() async {
    final normalizedSelectedDate = _normalizeDate(_selectedDate);
    
    // Create an ID for the Absensi record based on class, subject, and date
    final absensiId = '${widget.kelasId}-${widget.mataPelajaranId}-${normalizedSelectedDate.toIso8601String().split('T')[0]}';

    final existingAbsensi = await widget.absensiProvider.getAbsensiForDate(
      widget.kelasId,
      widget.mataPelajaranId,
      normalizedSelectedDate,
    );

    Absensi absensiToSave;
    if (existingAbsensi != null) {
      // Update existing record's dataKehadiran map
      existingAbsensi.dataKehadiran = Map.from(_attendanceStatus); // Ensure deep copy if map is mutable
      absensiToSave = existingAbsensi;
    } else {
      // Create new record
      absensiToSave = Absensi(
        id: absensiId,
        kelasId: widget.kelasId,
        mataPelajaranId: widget.mataPelajaranId,
        tanggal: normalizedSelectedDate,
        dataKehadiran: Map.from(_attendanceStatus), // Ensure deep copy
      );
    }
    await widget.absensiProvider.addOrUpdateAbsensi(absensiToSave);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absensi berhasil disimpan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Pilih Tanggal'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.studentsInClass.length,
            itemBuilder: (context, index) {
              final student = widget.studentsInClass[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.nama,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _attendanceStatus[student.nis] ?? 'Hadir',
                        items: ['Hadir', 'Sakit', 'Izin', 'Alpha'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _attendanceStatus[student.nis] = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _saveAttendance,
            child: const Text('Simpan Absensi'),
          ),
        ),
      ],
    );
  }
}

class StudentAbsensiView extends StatelessWidget {
  final String siswaNis;
  final String kelasId;
  final String mataPelajaranId;
  final AbsensiProvider absensiProvider;

  const StudentAbsensiView({
    super.key,
    required this.siswaNis,
    required this.kelasId,
    required this.mataPelajaranId,
    required this.absensiProvider,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Absensi>>(
      future: absensiProvider.getAbsensiForStudent(siswaNis, kelasId, mataPelajaranId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada data absensi.'));
        } else {
          final studentAbsensiRecords = snapshot.data!; // This is a list of Absensi objects, each representing attendance for a date for the whole class
          return ListView.builder(
            itemCount: studentAbsensiRecords.length,
            itemBuilder: (context, index) {
              final absensiRecord = studentAbsensiRecords[index];
              final status = absensiRecord.dataKehadiran[siswaNis]; // Get status for this student
              
              if (status == null) return const SizedBox.shrink(); // Student not in attendance record for this date

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(DateFormat('dd-MM-yyyy').format(absensiRecord.tanggal)),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'Hadir' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}