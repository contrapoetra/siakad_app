import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 5)
class User extends HiveObject {
  @HiveField(0)
  String nomorInduk; // Replaced username with nomorInduk (NIS/NIP)

  @HiveField(1)
  String password;

  @HiveField(2)
  String role; // 'admin', 'guru', 'siswa'
  @HiveField(3)
  String? requestedRole; // Stores the role requested by the user
  @HiveField(4)
  String? requestStatus; // 'pending', 'approved', 'rejected'
  @HiveField(5)
  String? email; // New field for email
  @HiveField(6)
  bool isPasswordSet; // New field to track if password has been set by user

  User({
    required this.nomorInduk,
    required this.password,
    required this.role,
    this.requestedRole,
    this.requestStatus,
    this.email,
    this.isPasswordSet = false, // Default to false
  });

  // Method to check if the user is a Siswa
  bool get isSiswa => role == 'Siswa';

  // Method to check if the user is a Guru
  bool get isGuru => role == 'Guru';

  // Method to check if the user is an Admin
  bool get isAdmin => role == 'Admin';
}
