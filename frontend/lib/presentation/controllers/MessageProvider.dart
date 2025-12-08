import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/MessageService.dart';

final msgServiceProvider = Provider((ref) => MessageService());

final messagesProvider =
    StateNotifierProvider.family<
      MessageNotifier,
      AsyncValue<List<Message>>,
      String
    >((ref, conversationId) {
      return MessageNotifier(ref, conversationId);
    });

class MessageNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref;
  final String conversationId;

  MessageNotifier(this.ref, this.conversationId)
    : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final svc = ref.read(msgServiceProvider);
      final msgs = await svc.getMessages(conversationId);
      state = AsyncValue.data(msgs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addMessage(Message msg) {
    final current = state.value ?? [];
    state = AsyncValue.data([msg, ...current]);
  }
}
