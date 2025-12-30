import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/core/utils/Enums.dart';
import 'package:frontend/data/models/Media.dart';
import 'package:logger/logger.dart';

class CloudinaryService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<Media> uploadFile(File file, MediaType mediaType) async {
    try {
      final cloudName = AppConstants.cloudinaryCloudName;
      final uploadPreset = AppConstants.cloudinaryUploadPreset;

      if (cloudName.isEmpty || uploadPreset.isEmpty) {
        throw Exception('Cloudinary credentials not configured');
      }

      String resourceType;
      switch (mediaType) {
        case MediaType.image:
          resourceType = 'image';
          break;
        case MediaType.video:
          resourceType = 'video';
          break;
        case MediaType.audio:
        case MediaType.file:
          resourceType = 'raw';
          break;
      }

      final url =
          'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_preset': uploadPreset,
      });

      _logger.i('Uploading file to Cloudinary: ${file.path}');

      // upload len cloudinary
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.i('File uploaded successfully: ${data['secure_url']}');

        final fileName = file.path.split('/').last;
        final format = fileName.contains('.') ? fileName.split('.').last : null;

        return Media(
          url: data['secure_url'],
          type: mediaType,
          size: data['bytes'],
          width: data['width'],
          height: data['height'],
          duration: data['duration']?.toDouble(),
          format: format ?? data['format'],
        );
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Cloudinary upload error: ${e.message}');
      if (e.response != null) {
        _logger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Failed to upload file: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error during upload: $e');
      throw Exception('Failed to upload file: $e');
    }
  }
}
