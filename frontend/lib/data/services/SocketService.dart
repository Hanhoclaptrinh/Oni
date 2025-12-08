import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:logger/logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  factory SocketService() => _instance;

  SocketService._internal();

  bool get isConnected => socket != null && socket!.connected;

  // kết nối socket server
  void connect(String token) {
    // ngắt connect nếu có connect từ trước
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }

    // setup socket connection
    socket = IO.io(
      AppConstants.baseHost,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .enableAutoConnect()
          .setAuth({"token": token})
          .build(),
    );

    socket!.onConnect((_) {
      Logger().i("Connect thành công");
    });

    socket!.onDisconnect((_) {
      Logger().i("Socket disconnected");
    });

    socket!.onConnectError((e) {
      Logger().e("Connect thất bại $e");
    });

    socket!.onError((e) {
      Logger().e("Socket error $e");
    });

    // connect socket
    socket!.connect();
  }
}
