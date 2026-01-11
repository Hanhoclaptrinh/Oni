import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/PostService.dart';
import 'package:frontend/providers/DioProvider.dart';

final postServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PostService(dio);
});
