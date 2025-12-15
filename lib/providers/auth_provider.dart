import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/guru.dart'; // Import Guru model
import '../services/auth_service.dart'; // Add this import
import 'package:collection/collection.dart'; // Import for firstOrNull

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
      final userBox = Hive.box<User>('users');
      final user = userBox.values.where((u) => u.nomorInduk == userId).firstOrNull;

      if (user != null && user.nomorInduk.isNotEmpty) {
        _currentUser = user;
        _currentUserRequestedRole = user.requestedRole;
        _currentUserRequestStatus = user.requestStatus;
        _currentUsername = user.name; // Use the new 'name' field from User object
      }
      notifyListeners();
    }
  }

  Future<bool> register(String nomorInduk, String password, String desiredRole, {String? email, required String name}) async {
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
      password: password,
      role: initialRole,
      requestedRole: requestedRole,
      requestStatus: requestStatus,
      email: email,
      isPasswordSet: true,
      name: name, // Pass the new name field
    );

    await userBox.add(newUser);
    notifyListeners();
    return true;
  }

  Future<bool> login(String identifier, String password) async {
      final userBox = Hive.box<User>('users');
      User? user;

      // Try to find user by nomorInduk (NIS/NIP)
      user = userBox.values.where((u) => u.nomorInduk == identifier).firstOrNull;

      // If not found by nomorInduk, try to find by email
      if (user == null) {
        user = userBox.values.where((u) => u.email == identifier).firstOrNull;
      }

      if (user != null && user.password == password) {
        final loggedInUser = user;

        if (!loggedInUser.isPasswordSet) {
          return false;
        }

        _currentUserId = loggedInUser.nomorInduk;
        _currentRole = loggedInUser.role;
        _currentUserRequestedRole = loggedInUser.requestedRole;
        _currentUserRequestStatus = loggedInUser.requestStatus;
        _currentUser = loggedInUser;
        _currentUsername = loggedInUser.name; // Use the name from the User object

        await _authService.saveSession(_currentUserId!, _currentRole!);

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
    final guruBox = Hive.box<Guru>('guru'); // Access Guru box
    final userIndex = userBox.values.toList().indexWhere((u) => u.nomorInduk == user.nomorInduk);

    if (userIndex != -1) {
      // If role is accepted and it's a Guru, generate NIP and create Guru entry
      if (newRole == 'Guru' && newStatus == 'approved') {
        final newNip = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);

        final newGuru = Guru(
          nip: newNip,
          nama: user.name, // Use the user's name from registration
          email: user.email.toString(),
          tanggalLahir: DateTime.now(), // Placeholder
          tempatLahir: 'Unknown', // Placeholder
          gelar: 'S.Pd.', // Placeholder
        );
        await guruBox.add(newGuru);

        // Update User's nomorInduk to the generated NIP
        user.nomorInduk = newNip;
      }

      user.role = newRole;
      user.requestedRole = null;
      user.requestStatus = newStatus;
      await userBox.putAt(userIndex, user);

      // If the current logged-in user's role was updated, reflect it
      if (_currentUser?.nomorInduk == user.nomorInduk) {
        _currentUserId = user.nomorInduk;
        _currentUser = user;
        _currentRole = user.role;
        _currentUserRequestedRole = user.requestedRole;
        _currentUserRequestStatus = user.requestStatus;
        _currentUsername = user.name; // Update currentUsername as well
        await _authService.saveSession(_currentUserId!, _currentRole!);
      }
      notifyListeners();
    }
  }

  // Forgot Password Flow Methods
  Future<bool> forgotPassword(String nomorInduk) async {
    final userBox = Hive.box<User>('users');
    final user = userBox.values.where((u) => u.nomorInduk == nomorInduk).firstOrNull;
    // For now, just check if user exists. Email sending is simulated.
    return user != null;
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

  // New method to update a user's nomorInduk (NIS/NIP)
  Future<void> updateUserNomorInduk(String oldNomorInduk, String newNomorInduk) async {
    final userBox = Hive.box<User>('users');
    final userIndex = userBox.values.toList().indexWhere((u) => u.nomorInduk == oldNomorInduk);

    if (userIndex != -1) {
      final user = userBox.getAt(userIndex)!;
      user.nomorInduk = newNomorInduk;
      await userBox.putAt(userIndex, user);

      // If the current logged-in user's nomorInduk was updated, reflect it
      if (_currentUserId == oldNomorInduk) {
        _currentUserId = newNomorInduk;
        _currentUser = user; // Update the current user object
        await _authService.saveSession(_currentUserId!, _currentRole!); // Update session
      }
      notifyListeners();
    }
  }

  // Role Request Method
  Future<void> requestRole(String newRole) async {
    if (_currentUser == null) return;
    final userBox = Hive.box<User>('users');
    final user = _currentUser!;
    
    user.requestedRole = newRole;
    user.requestStatus = 'pending';
    
    // Find and update in Hive
    final userIndex = userBox.values.toList().indexWhere((u) => u.nomorInduk == user.nomorInduk);
    if (userIndex != -1) {
      await userBox.putAt(userIndex, user);
      
      _currentUserRequestedRole = newRole;
      _currentUserRequestStatus = 'pending';
      notifyListeners();
    }
  }

  // Admin Management Methods
  List<User> getAllAdmins() {
    final userBox = Hive.box<User>('users');
    return userBox.values.where((user) => user.role == 'Admin').toList();
  }

  Future<bool> addAdmin(User newAdmin) async {
    final userBox = Hive.box<User>('users');
    // Check if nomorInduk already exists
    if (userBox.values.any((user) => user.nomorInduk == newAdmin.nomorInduk)) {
      return false;
    }
    await userBox.add(newAdmin);
    notifyListeners();
    return true;
  }

  Future<void> updateAdmin(String originalNomorInduk, User updatedAdmin) async {
    final userBox = Hive.box<User>('users');
    final index = userBox.values.toList().indexWhere((u) => u.nomorInduk == originalNomorInduk);
    if (index != -1) {
      await userBox.putAt(index, updatedAdmin);
      notifyListeners();
    }
  }

  Future<void> deleteAdmin(String nomorInduk) async {
    final userBox = Hive.box<User>('users');
    final index = userBox.values.toList().indexWhere((u) => u.nomorInduk == nomorInduk);
    if (index != -1) {
      await userBox.deleteAt(index);
      notifyListeners();
    }
  }
}
