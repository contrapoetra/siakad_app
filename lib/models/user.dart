import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 5)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  @HiveField(2)
  String role; // 'admin', 'guru', 'siswa'
  @HiveField(3)
  String? requestedRole; // Stores the role requested by the user
  @HiveField(4)
  String? requestStatus; // 'pending', 'approved', 'rejected'

  User({
    required this.username,
    required this.password,
    required this.role,
    this.requestedRole,
    this.requestStatus,
  });
}
