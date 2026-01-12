import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/providers/DioProvider.dart';

final authServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

final refreshDioProvider = Provider((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );
});

final authRefreshServiceProvider = Provider((ref) {
  final dio = ref.watch(refreshDioProvider);
  return AuthService(dio);
});
