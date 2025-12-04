import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const String AT_KEY = "access_token";
  static const String RT_KEY = "refresh_token";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await storage.write(key: AT_KEY, value: access);
    await storage.write(key: RT_KEY, value: refresh);
  }

  Future<String?> getAccessToken() => storage.read(key: AT_KEY);
  Future<String?> getRefreshToken() => storage.read(key: RT_KEY);

  Future<void> clear() async => storage.deleteAll();
}
