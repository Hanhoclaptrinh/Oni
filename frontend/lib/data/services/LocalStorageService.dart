import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const String RT_KEY = "refresh_token";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveToken(String refreshToken) async {
    await storage.write(key: RT_KEY, value: refreshToken);
  }

  Future<String?> getToken() async {
    return await storage.read(key: RT_KEY);
  }

  Future<void> clearToken() async {
    await storage.delete(key: RT_KEY);
  }
}
