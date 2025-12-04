import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/UserService.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final meProvider = FutureProvider((ref) {
  final service = ref.watch(userServiceProvider);
  return service.getProfile();
});
