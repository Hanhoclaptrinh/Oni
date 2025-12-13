import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/MessageService.dart';
import 'package:frontend/presentation/providers/DioProvider.dart';

final msgServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return MessageService(dio);
});

final msgProvider =
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

      if (!mounted) return;

      state = AsyncValue.data(msgs);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  void addMessage(Message msg) {
    final current = state.value ?? [];
    state = AsyncValue.data([msg, ...current]);
  }

  void markSeenBy(String userId) {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((msg) {
        if (msg.senderId != userId && !msg.seenBy.contains(userId)) {
          return msg.copyWith(seenBy: [...msg.seenBy, userId]);
        }
        return msg;
      }).toList(),
    );
  }
}
