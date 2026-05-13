import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/constants.dart';

class ChatService {
  late IO.Socket _socket;
  final String socketUrl = AppConstants.socketUrl;

  void connect(String token) {
    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'Authorization': 'Bearer $token',
      }).build(),
    );

    _socket.onConnect((_) {
      print('Connected to Chat Server');
    });

    _socket.onDisconnect((_) => print('Disconnected from Chat Server'));
  }

  void joinRoom(String appointmentId) {
    _socket.emit('joinRoom', appointmentId);
  }

  void sendMessage(
    String appointmentId,
    String senderId,
    String content, {
    String type = 'TEXT',
    String? fileUrl,
  }) {
    _socket.emit('sendMessage', {
      'appointmentId': appointmentId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'fileUrl': fileUrl,
    });
  }

  void onNewMessage(Function(dynamic) callback) {
    _socket.on('newMessage', callback);
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}
