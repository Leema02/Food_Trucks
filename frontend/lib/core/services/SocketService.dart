import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'notification_service.dart';

class SocketService {
  SocketService._();
  static final SocketService socketService = SocketService._();
  IO.Socket? socket;
  String? currentUserId;
  String server = 'http://10.0.2.2:5000';
  setId(String id) {
    currentUserId = id;
  }

  connectToServer() {
    log("======================================================================================");
    log("Connect to serverrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
    log("======================================================================================");
    socket?.disconnect();
    socket = IO.io(server, <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket.io/socket',
    });
    socket!.on('connect', (_) {
      log("message");
      socket!.emit('setId', {"id": currentUserId, "role": "user"});
    });
    socket!.on("Notification", (data) async {
      log("data");
      log(data.toString());
      await NotificationService.showNotification(
          title: data['title'], body: data['message']);
    });
  }
}
