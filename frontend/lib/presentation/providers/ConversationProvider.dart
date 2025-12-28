import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/models/LatestMessage.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/ConversationService.dart';
import 'package:frontend/presentation/providers/DioProvider.dart';

final cvsServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ConversationService(dio);
});

final cvsProvider =
    StateNotifierProvider<ConversationNotifier, AsyncValue<List<Conversation>>>(
      (ref) {
        return ConversationNotifier(ref);
      },
    );

class ConversationNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  final Ref ref;

  ConversationNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final service = ref.read(cvsServiceProvider);
      final conversations = await service.getMyConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void onConversationUpdate({
    required String conversationId,
    required LatestMessage latestMessage,
    required String myUserId,
  }) {
    state = state.whenData((list) {
      final idx = list.indexWhere((c) => c.id == conversationId);
      if (idx == -1) return list;

      final conv = list[idx];
      final updated = conv.copyWith(
        latestMessage: latestMessage,
        hasUnread: latestMessage.senderId != myUserId,
      );

      return [updated, ...list.where((c) => c.id != conversationId)];
    });
  }

  void onNewGlobalMessage(Message msg, String myUserId) {
    final current = state.value ?? [];

    final idx = current.indexWhere((c) => c.id == msg.conversationId);
    if (idx == -1) return;

    final conv = current[idx];
    final isMine = msg.senderId == myUserId;

    final updated = conv.copyWith(
      latestMessage: LatestMessage.fromMessage(msg, isMine),
      hasUnread: !isMine,
    );

    state = AsyncValue.data([
      updated,
      ...current.where((c) => c.id != conv.id),
    ]);
  }

  void markAsRead(String conversationId) {
    state = state.whenData((list) {
      return list.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(hasUnread: false);
        }
        return c;
      }).toList();
    });
  }
}
