import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/siswa.dart'; // Import Siswa model
import '../models/guru.dart'; // Import Guru model

class AuthProvider with ChangeNotifier {
  String? _currentRole;
  String? _currentUsername;
  String? _currentUserId; // NIS untuk siswa, NIP untuk guru
  String? _currentUserRequestedRole;
  String? _currentUserRequestStatus;
  User? _currentUser; // Added to hold the current logged in user object

  String? get currentRole => _currentRole;
  String? get currentUsername => _currentUsername;
  String? get currentUserId => _currentUserId;
  String? get currentUserRequestedRole => _currentUserRequestedRole;
  String? get currentUserRequestStatus => _currentUserRequestStatus;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentRole != null;

  Future<bool> register(String username, String password, String desiredRole) async {
    final userBox = Hive.box<User>('users');
    // Check if username already exists
    if (userBox.values.any((user) => user.username == username)) {
      return false; // Username already taken
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
      username: username,
      password: password,
      role: initialRole,
      requestedRole: requestedRole,
      requestStatus: requestStatus,
    );

    await userBox.add(newUser);
    notifyListeners(); // Notify listeners that a new user has been added
    return true;
  }

  Future<bool> login(String username, String password) async {
    final userBox = Hive.box<User>('users');
    final user = userBox.values.firstWhere(
      (user) => user.username == username,
      orElse: () => User(username: '', password: '', role: '')
    );

    if (user.username.isNotEmpty && user.password == password) {
      _currentUsername = user.username;
      _currentRole = user.role;
      _currentUserRequestedRole = user.requestedRole;
      _currentUserRequestStatus = user.requestStatus;
      _currentUser = user; // Set the current user object
      
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
    _currentUserRequestedRole = null;
    _currentUserRequestStatus = null;
    _currentUser = null; // Clear the current user object
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
    final userIndex = userBox.values.toList().indexOf(user);
    if (userIndex != -1) {
      user.role = newRole;
      user.requestedRole = null; // Clear requested role after approval/rejection
      user.requestStatus = newStatus;
      await userBox.putAt(userIndex, user);
      notifyListeners();
    }
  }
}
