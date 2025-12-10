import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/services/SocketService.dart';

final presenceProvider = StateProvider<Map<String, bool>>((ref) => {});

final presenceListenerProvider = Provider<void>((ref) {
  final socket = SocketService();

  final subOnline = socket.friendOnline.listen((uid) {
    final current = ref.read(presenceProvider);
    ref.read(presenceProvider.notifier).state = {...current, uid: true};
  });

  final subOffline = socket.friendOffline.listen((uid) {
    final current = ref.read(presenceProvider);
    ref.read(presenceProvider.notifier).state = {...current, uid: false};
  });

  final subInitialPresence = socket.initialPresence.listen((onlineUserIds) {
    final current = ref.read(presenceProvider);
    final updatedPresence = Map<String, bool>.from(current);

    // cập nhật trạng thái online cho tất cả user trong danh sách
    for (final uid in onlineUserIds) {
      updatedPresence[uid] = true;
    }

    ref.read(presenceProvider.notifier).state = updatedPresence;
  });

  ref.onDispose(() {
    subOnline.cancel();
    subOffline.cancel();
    subInitialPresence.cancel();
  });
});
