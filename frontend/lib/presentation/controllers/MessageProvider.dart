import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/MessageService.dart';

final msgServiceProvider = Provider((ref) => MessageService());

final messagesProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final service = ref.watch(msgServiceProvider);
  return service.getMessages(conversationId);
});
