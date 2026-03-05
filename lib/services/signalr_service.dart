import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SignalRService {
  late WebSocket _socket;
  late String _connectionToken;

  final String baseUrl = "https://partnersras.com";
  final String hubName = "chatHub"; // ⚠ CHANGE THIS TO YOUR REAL HUB NAME

  /// 1️⃣ NEGOTIATE
  Future<void> _negotiate() async {
    final response = await http.get(
      Uri.parse("$baseUrl/signalr/negotiate?clientProtocol=1.5"),
    );

    final data = jsonDecode(response.body);
    _connectionToken = data["ConnectionToken"];

    print("Negotiated ✅");
  }

  /// 2️⃣ CONNECT WEBSOCKET
  Future<void> _connectSocket() async {
    final encodedToken = Uri.encodeComponent(_connectionToken);

    final connectionData =
    Uri.encodeComponent('[{"name":"$hubName"}]');

    final wsUrl =
        "wss://partnersras.com/signalr/connect"
        "?transport=webSockets"
        "&clientProtocol=1.5"
        "&connectionToken=$encodedToken"
        "&connectionData=$connectionData"
        "&tid=8";

    _socket = await WebSocket.connect(wsUrl);

    _socket.listen(
          (data) {
        print("Received: $data");
      },
      onDone: () {
        print("Connection closed");
      },
      onError: (error) {
        print("Socket Error: $error");
      },
    );

    print("WebSocket Connected ✅");
  }

  /// 3️⃣ START CONNECTION (VERY IMPORTANT)
  Future<void> _start() async {
    final encodedToken = Uri.encodeComponent(_connectionToken);

    final startUrl =
        "$baseUrl/signalr/start"
        "?transport=webSockets"
        "&clientProtocol=1.5"
        "&connectionToken=$encodedToken"
        "&connectionData=${Uri.encodeComponent('[{\"name\":\"$hubName\"}]')}";

    await http.get(Uri.parse(startUrl));

    print("SignalR Started 🚀");
  }

  /// 4️⃣ PUBLIC CONNECT METHOD
  Future<void> connect() async {
    await _negotiate();
    await _connectSocket();
    await _start();
  }

  /// 5️⃣ CALL SERVER METHOD
  void invoke(String methodName, List arguments) {
    final data = {
      "H": hubName,
      "M": methodName,
      "A": arguments,
      "I": 1
    };

    _socket.add(jsonEncode(data));
  }

  /// CLOSE
  void disconnect() {
    _socket.close();
  }
}
