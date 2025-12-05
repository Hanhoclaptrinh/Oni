import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/ConversationService.dart';

final cvsServiceProvider = Provider((ref) => ConversationService());

final conversationProvider = FutureProvider((ref) async {
  final service = ref.watch(cvsServiceProvider);
  return service.getMyConversations();
});