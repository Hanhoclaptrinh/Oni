import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:logger/logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  final friendOnline = StreamController<String>.broadcast();
  final friendOffline = StreamController<String>.broadcast();

  factory SocketService() => _instance;

  SocketService._internal();

  void connect(String token) {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
    }

    socket = IO.io(
      AppConstants.baseHost,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .setAuth({"token": token})
          .build(),
    );

    socket!.onConnect((_) {
      Logger().i("Socket connected");
    });

    socket!.on("user_online", (uid) {
      Logger().i("FE RECEIVED user_online: $uid");
      friendOnline.add(uid.toString());
    });

    socket!.on("user_offline", (uid) {
      Logger().i("FE RECEIVED user_offline: $uid");
      friendOffline.add(uid.toString());
    });

    socket!.onDisconnect((_) {
      Logger().i("Socket disconnected");
    });

    socket!.connect();
  }
}
