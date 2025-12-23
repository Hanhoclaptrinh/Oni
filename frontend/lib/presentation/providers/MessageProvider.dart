import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/MessageService.dart';
import 'package:frontend/presentation/providers/DioProvider.dart';

final editingMessageProvider = StateProvider<Message?>((ref) => null);
final replyToMessageProvider = StateProvider<Message?>((ref) => null);

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
  bool _isLoadingMore = false;
  bool _isNoMore = false;

  MessageNotifier(this.ref, this.conversationId)
    : super(const AsyncValue.loading()) {
    _loadInit();
  }

  // load tin nhan len truoc - chi 1 lan
  Future<void> _loadInit() async {
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

  // load them tin nhan
  Future<void> loadMore() async {
    if (_isLoadingMore || _isNoMore) return; // kh con gi de load

    final current = state.value ?? [];
    if (current.isEmpty) return;

    _isLoadingMore = true;

    try {
      final oldestId = current.last.id;
      final svc = ref.read(msgServiceProvider);

      final oldestMsg = await svc.getMessages(
        conversationId,
        beforeMsgId: oldestId,
      );

      if (!mounted) return;

      if (oldestMsg.isEmpty) {
        _isNoMore = true;
      } else {
        state = AsyncData([...current, ...oldestMsg]);
      }
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  // tin nhan moi - socket
  void addMessage(Message msg) {
    final current = state.value ?? [];
    state = AsyncValue.data([msg, ...current]);
  }

  // seen
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

  // delete msg
  void deleteMessage(String msgId) async {
    // update
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((m) => m.id != msgId).toList());

    try {
      final svc = ref.read(msgServiceProvider);
      await svc.deleteMessageForMe(msgId);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  // lang nghe tin nhan bi revoke tu socket
  void onMessageRevoked(String msgId) {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((m) {
        if (m.id == msgId) {
          return m.copyWith(status: "revoked", content: null, fileUrl: null);
        }
        return m;
      }).toList(),
    );
  }

  // lang nghe tin nhan duoc chinh sua tu socket
  void onMessageEdited({
    required String msgId,
    required String content,
    DateTime? editedAt,
  }) {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((m) {
        if (m.id == msgId) {
          return m.copyWith(content: content, editedAt: editedAt);
        }
        return m;
      }).toList(),
    );
  }
}
