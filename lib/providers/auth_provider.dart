import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _currentRole;
  String? _currentUsername;
  String? _currentUserId; // NIS untuk siswa, NIP untuk guru

  String? get currentRole => _currentRole;
  String? get currentUsername => _currentUsername;
  String? get currentUserId => _currentUserId;

  bool get isLoggedIn => _currentRole != null;

  // Dummy credentials
  final Map<String, Map<String, String>> _credentials = {
    'admin': {'password': 'admin123', 'role': 'Admin', 'id': 'admin'},
    'guru': {'password': 'guru123', 'role': 'Guru', 'id': '198501012010011001'},
    'Ahmad Rizki': {'password': 'siswa123', 'role': 'Siswa', 'id': '2024001'},
    'Siti Nurhaliza': {'password': 'siswa123', 'role': 'Siswa', 'id': '2024002'},
    'Abbiyi QS': {'password': 'siswa123', 'role': 'Siswa', 'id': '2024003'},
  };

  bool login(String username, String password) {
    if (_credentials.containsKey(username)) {
      if (_credentials[username]!['password'] == password) {
        _currentUsername = username;
        _currentRole = _credentials[username]!['role'];
        _currentUserId = _credentials[username]!['id'];
        notifyListeners();
        return true;
      }
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
