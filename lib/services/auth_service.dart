import 'package:hive/hive.dart';

class AuthService {
  static const String _sessionBoxName = 'sessionBox';
  static const String _userIdKey = 'userId';
  static const String _roleKey = 'role';

  Future<Box<dynamic>> _openSessionBox() async {
    return await Hive.openBox(_sessionBoxName);
  }

  Future<void> saveSession(String userId, String role) async {
    final box = await _openSessionBox();
    await box.put(_userIdKey, userId);
    await box.put(_roleKey, role);
  }

  Future<Map<String, String?>> loadSession() async {
    final box = await _openSessionBox();
    final userId = box.get(_userIdKey) as String?;
    final role = box.get(_roleKey) as String?;
    return {_userIdKey: userId, _roleKey: role};
  }

  Future<void> clearSession() async {
    final box = await _openSessionBox();
    await box.delete(_userIdKey);
    await box.delete(_roleKey);
  }
}
