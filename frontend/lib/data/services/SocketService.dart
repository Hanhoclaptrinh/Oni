import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:logger/logger.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  factory SocketService() => _instance;

  SocketService._internal();

  final _friendOnlineController = StreamController<String>.broadcast();
  final _friendOfflineController = StreamController<String>.broadcast();
  final _initialPresenceController = StreamController<List<String>>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<String> get friendOnline => _friendOnlineController.stream;
  Stream<String> get friendOffline => _friendOfflineController.stream;
  Stream<List<String>> get initialPresence => _initialPresenceController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect(String token, {String? myId}) {
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

      if (myId != null) {
        socket!.emit("join_user_room", myId);
        Logger().i("joined user room: $myId");
      }

      socket!.on("user_online", (uid) {
        Logger().i("user_online event: $uid");
        _friendOnlineController.add(uid.toString());
      });

      socket!.on("user_offline", (uid) {
        Logger().i("user_offline event: $uid");
        _friendOfflineController.add(uid.toString());
      });

      socket!.on("initial_presence", (data) {
        Logger().i("initial_presence event: $data");
        if (data is List) {
          final onlineUserIds = data.map((uid) => uid.toString()).toList();
          _initialPresenceController.add(onlineUserIds);
        }
      });
    });

    socket!.connect();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }

  void dispose() {
    disconnect();
    _friendOnlineController.close();
    _friendOfflineController.close();
    _initialPresenceController.close();
  }

  void reconnect(String accessToken) {
    if (socket == null) {
      connect(accessToken);
      return;
    }

    socket!.disconnect();

    socket!.auth = {'token': accessToken};
    socket!.connect();
  }
}
