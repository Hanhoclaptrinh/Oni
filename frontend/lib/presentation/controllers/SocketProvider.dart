import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/services/SocketService.dart';

final presenceProvider = StateProvider<Map<String, bool>>((ref) => {});

final presenceListenerProvider = Provider<void>((ref) {
  final socket = SocketService();

  // online
  final sub1 = socket.friendOnline.stream.listen((uid) {
    final current = ref.read(presenceProvider);
    final updated = {...current, uid: true};
    ref.read(presenceProvider.notifier).state = updated;
  });

  // offline
  final sub2 = socket.friendOffline.stream.listen((uid) {
    final current = ref.read(presenceProvider);
    final updated = {...current, uid: false};
    ref.read(presenceProvider.notifier).state = updated;
  });

  // dispose
  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
  });
});
