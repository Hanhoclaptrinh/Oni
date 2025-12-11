import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/ConversationService.dart';
import 'package:frontend/presentation/controllers/DioProvider.dart';

final cvsServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ConversationService(dio);
});

final cvsProvider = FutureProvider((ref) async {
  final service = ref.watch(cvsServiceProvider);
  return service.getMyConversations();
});
