import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppConstants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  factory SocketService() => _instance;

  SocketService._internal();

  bool get isConnected => socket != null && socket!.connected;

  void connect(String token, String userId) {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }

    socket = IO.io(
      AppConstants.baseHost,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .enableAutoConnect()
          .setExtraHeaders({"Authorization": "Bearer $token"})
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      socket!.emit("user_online", userId);
    });

    socket!.onDisconnect((_) {});

    socket!.onConnectError((e) {});
    socket!.onError((e) {});
  }
}
