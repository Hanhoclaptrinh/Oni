import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/presentation/providers/DioProvider.dart';

final authServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});
