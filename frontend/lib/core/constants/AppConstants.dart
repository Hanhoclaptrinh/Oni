import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // server config
  static String get host => dotenv.env['HOST'] ?? 'localhost';
  static String get port => dotenv.env['PORT'] ?? '5000';
  static String get baseHost => 'http://$host:$port';
  static const String baseEndpoint = "/api/v1";
  static String get baseUrl => "$baseHost$baseEndpoint";

  // cloudinary config
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_NAME'] ?? '';
  static String get cloudinaryUploadPreset =>
      dotenv.env['UPLOAD_PRESET_NAME'] ?? '';
}
