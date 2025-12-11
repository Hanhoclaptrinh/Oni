import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/User.dart';
import 'package:frontend/data/services/UserService.dart';
import 'package:frontend/presentation/controllers/DioProvider.dart';

final userServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

final userProvider = FutureProvider<User>((ref) async {
  final svc = ref.watch(userServiceProvider);
  return svc.getProfile();
});
