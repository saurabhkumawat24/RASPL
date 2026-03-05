// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//
//   SocketService._internal();
//
//   late IO.Socket socket;
//
//   void connect() {
//     socket = IO.io(
//       "http://YOUR_SERVER_IP:3000", // change this
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .build(),
//     );
//
//     socket.connect();
//
//     socket.onConnect((_) {
//       print("✅ Connected");
//     });
//
//     socket.onDisconnect((_) {
//       print("❌ Disconnected");
//     });
//
//     socket.onConnectError((err) {
//       print("Connect Error: $err");
//     });
//   }
//
//   void sendMessage(String msg) {
//     socket.emit("send_message", msg);
//   }
//
//   void listenMessage(Function(dynamic) callback) {
//     socket.on("receive_message", callback);
//   }
//
//   void dispose() {
//     socket.dispose();
//   }
// }
