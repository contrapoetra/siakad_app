import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart'; // Import Siswa model
import '../models/guru.dart'; // Import Guru model

class AuthProvider with ChangeNotifier {
  String? _currentRole;
  String? _currentUsername;
  String? _currentUserId; // NIS untuk siswa, NIP untuk guru

  String? get currentRole => _currentRole;
  String? get currentUsername => _currentUsername;
  String? get currentUserId => _currentUserId;

  bool get isLoggedIn => _currentRole != null;

  Future<bool> login(String username, String password) async {
    final userBox = Hive.box<User>('users');
    final user = userBox.values.firstWhere(
      (user) => user.username == username,orElse: () => User(username: '', password: '', role: '')
    );

    if (user.username.isNotEmpty && user.password == password) {
      _currentUsername = user.username;
      _currentRole = user.role;
      
      // Set _currentUserId based on role or type of username used
      if (user.role == 'Siswa') {
        // Assuming username is nama in the dummy data, let's find by nama
        final siswaBox = Hive.box<Siswa>('siswa');
        _currentUserId = siswaBox.values.firstWhere((Siswa s) => s.nama == username, orElse: () => Siswa(nis: '', nama: '', kelas: '', jurusan: '')).nis; // Explicitly type s as Siswa
      } else if (user.role == 'Guru') {
        // Similar logic for Guru NIP
        final guruBox = Hive.box<Guru>('guru');
        _currentUserId = guruBox.values.firstWhere((Guru g) => g.nama == username, orElse: () => Guru(nip: '', nama: '', mataPelajaran: '')).nip; // Explicitly type g as Guru
      } else if (user.role == 'Admin') {
        _currentUserId = 'admin'; // Or a dedicated admin ID
      }
      
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentRole = null;
    _currentUsername = null;
    _currentUserId = null;
    notifyListeners();
  }
}
