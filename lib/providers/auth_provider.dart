import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart'; // Import Siswa model
import '../models/guru.dart'; // Import Guru model
import '../services/auth_service.dart'; // Add this import

class AuthProvider with ChangeNotifier {
  String? _currentRole;
  String? _currentUsername;
  String? _currentUserId; // NIS untuk siswa, NIP untuk guru
  String? _currentUserRequestedRole;
  String? _currentUserRequestStatus;
  User? _currentUser; // Added to hold the current logged in user object

  final AuthService _authService = AuthService(); // Add instance of AuthService

  String? get currentRole => _currentRole;
  String? get currentUsername => _currentUsername;
  String? get currentUserId => _currentUserId;
  String? get currentUserRequestedRole => _currentUserRequestedRole;
  String? get currentUserRequestStatus => _currentUserRequestStatus;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentRole != null;

  AuthProvider() {
    _loadSession(); // Call method to load session on initialization
  }

  Future<void> _loadSession() async {
    final session = await _authService.loadSession();
    final userId = session['userId'];
    final role = session['role'];

    if (userId != null && role != null) {
      _currentUserId = userId;
      _currentRole = role;

      // Re-populate other details like username and currentUser from Hive if needed
      // This is a simplified approach, a full user object would be better stored/retrieved
      final userBox = Hive.box<User>('users');
      final user = userBox.values.firstWhere(
        (u) => u.nomorInduk == userId,
        orElse: () => User(nomorInduk: '', password: '', role: '') // Fallback
      );

      if (user.nomorInduk.isNotEmpty) {
        _currentUser = user;
        _currentUserRequestedRole = user.requestedRole;
        _currentUserRequestStatus = user.requestStatus;
        
        // Try to get actual name from Siswa/Guru models
        String? actualName;
        if (user.isSiswa) {
          final siswaBox = Hive.box<Siswa>('siswa');
          final siswa = siswaBox.values.firstWhere((s) => s.nis == user.nomorInduk, orElse: () => Siswa(nis: '', nama: '', kelas: '', jurusan: '', email: '', tanggalLahir: DateTime.now(), tempatLahir: '', namaAyah: '', namaIbu: ''));
          if (siswa.nis.isNotEmpty) {
            actualName = siswa.nama;
          }
        } else if (user.isGuru) {
          final guruBox = Hive.box<Guru>('guru');
          final guru = guruBox.values.firstWhere((g) => g.nip == user.nomorInduk, orElse: () => Guru(nip: '', nama: '', gelar: '', email: '', tanggalLahir: DateTime.now(), tempatLahir: ''));
          if (guru.nip.isNotEmpty) {
            actualName = guru.nama;
          }
        }
        _currentUsername = actualName ?? user.nomorInduk;
      }
      notifyListeners();
    }
  }

  Future<bool> register(String nomorInduk, String password, String desiredRole, {String? email}) async {
    final userBox = Hive.box<User>('users');
    // Check if nomorInduk already exists
    if (userBox.values.any((user) => user.nomorInduk == nomorInduk)) {
      return false; // Nomor Induk already taken
    }

    String initialRole = 'Siswa';
    String? requestedRole;
    String? requestStatus;

    if (desiredRole == 'Guru' || desiredRole == 'Admin') {
      requestedRole = desiredRole;
      requestStatus = 'pending';
    } else {
      initialRole = desiredRole; // Should be 'Siswa'
    }

    final newUser = User(
      nomorInduk: nomorInduk,
      password: password, // This will be the initial password set by admin or during registration
      role: initialRole,
      requestedRole: requestedRole,
      requestStatus: requestStatus,
      email: email,
      isPasswordSet: true, // For manual registration, password is set immediately
    );

    await userBox.add(newUser);
    notifyListeners(); // Notify listeners that a new user has been added
    return true;
  }

  Future<bool> login(String nomorInduk, String password) async {
    final userBox = Hive.box<User>('users');
    final user = userBox.values.firstWhere(
      (user) => user.nomorInduk == nomorInduk,
      orElse: () => User(nomorInduk: '', password: '', role: '')
    );

    if (user.nomorInduk.isNotEmpty && user.password == password) {
      if (!user.isPasswordSet) {
        // User needs to set a password first via forgot password flow
        return false;
      }

      _currentUserId = user.nomorInduk;
      _currentRole = user.role;
      _currentUserRequestedRole = user.requestedRole;
      _currentUserRequestStatus = user.requestStatus;
      _currentUser = user; // Set the current user object
      
      // Try to get actual name from Siswa/Guru models
      String? actualName;
      if (user.isSiswa) {
        final siswaBox = Hive.box<Siswa>('siswa');
        final siswa = siswaBox.values.firstWhere((s) => s.nis == user.nomorInduk, orElse: () => Siswa(nis: '', nama: '', kelas: '', jurusan: '', email: '', tanggalLahir: DateTime.now(), tempatLahir: '', namaAyah: '', namaIbu: ''));
        if (siswa.nis.isNotEmpty) {
          actualName = siswa.nama;
        }
      } else if (user.isGuru) {
        final guruBox = Hive.box<Guru>('guru');
        final guru = guruBox.values.firstWhere((g) => g.nip == user.nomorInduk, orElse: () => Guru(nip: '', nama: '', gelar: '', email: '', tanggalLahir: DateTime.now(), tempatLahir: ''));
        if (guru.nip.isNotEmpty) {
          actualName = guru.nama;
        }
      }

      _currentUsername = actualName ?? user.nomorInduk;
      
      await _authService.saveSession(_currentUserId!, _currentRole!); // Save session

      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _authService.clearSession(); // Clear session
    _currentRole = null;
    _currentUsername = null;
    _currentUserId = null;
    _currentUserRequestedRole = null;
    _currentUserRequestStatus = null;
    _currentUser = null;
    notifyListeners();
  }

  // New method to get all users with pending role requests
  List<User> getAllUsersWithPendingRoleRequests() {
    final userBox = Hive.box<User>('users');
    return userBox.values
        .where((user) => user.requestedRole != null && user.requestStatus == 'pending')
        .toList();
  }

  // New method to update a user's role and request status
  Future<void> updateUserRoleAndStatus(User user, String newRole, String newStatus) async {
    final userBox = Hive.box<User>('users');
    final userIndex = userBox.values.toList().indexWhere((u) => u.nomorInduk == user.nomorInduk);
    if (userIndex != -1) {
      user.role = newRole;
      user.requestedRole = null; // Clear requested role after approval/rejection
      user.requestStatus = newStatus;
      await userBox.putAt(userIndex, user);
      // If the current logged-in user's role was updated, reflect it
      if (_currentUser?.nomorInduk == user.nomorInduk) {
        _currentUser = user;
        _currentRole = user.role;
        _currentUserRequestedRole = user.requestedRole;
        _currentUserRequestStatus = user.requestStatus;
      }
      notifyListeners();
    }
  }

  // Forgot Password Flow Methods
  Future<bool> forgotPassword(String nomorInduk) async {
    final userBox = Hive.box<User>('users');
    final user = userBox.values.firstWhere(
      (user) => user.nomorInduk == nomorInduk,
      orElse: () => User(nomorInduk: '', password: '', role: '')
    );
    // For now, just check if user exists. Email sending is simulated.
    return user.nomorInduk.isNotEmpty;
  }

  bool verifyPin(String nomorInduk, String pin) {
    // Hardcoded PIN for now as per requirement
    return pin == '528491';
  }

  Future<bool> resetPassword(String nomorInduk, String newPassword) async {
    final userBox = Hive.box<User>('users');
    final userIndex = userBox.values.toList().indexWhere((u) => u.nomorInduk == nomorInduk);

    if (userIndex != -1) {
      final user = userBox.getAt(userIndex)!;
      user.password = newPassword;
      user.isPasswordSet = true;
      await userBox.putAt(userIndex, user);
      notifyListeners();
      return true;
    }
    return false;
  }
}
