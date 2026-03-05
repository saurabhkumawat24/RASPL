// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:signalr_netcore/signalr_client.dart';
//
// class WhatsAppChatPage extends StatefulWidget {
//   const WhatsAppChatPage({super.key});
//
//   @override
//   State<WhatsAppChatPage> createState() => _WhatsAppChatPageState();
// }
//
// class _WhatsAppChatPageState extends State<WhatsAppChatPage> {
//   final TextEditingController controller = TextEditingController();
//   final List<Map<String, dynamic>> chats = [];
//
//   late HubConnection hubConnection;
//   bool isConnected = false;
//
//   // 🔴 CHANGE THESE URLs
//   final String hubUrl = "https://partnersras.com/signalr";
//   final String uploadUrl = "https://yourdomain.com/api/upload";
//
//   @override
//   void initState() {
//     super.initState();
//     _connectSignalR();
//   }
//
//   // ================= SIGNALR =================
//
//   Future<void> _connectSignalR() async {
//     hubConnection = HubConnectionBuilder()
//         .withUrl(
//       hubUrl,
//       options: HttpConnectionOptions(
//         transport: HttpTransportType.WebSockets,
//       ),
//     )
//         .withAutomaticReconnect()
//         .build();
//
//     hubConnection.on("ReceiveMessage", (data) {
//       if (data == null || data.isEmpty) return;
//
//       chats.add({
//         "type": data.length > 1 ? data[1] : "text",
//         "msg": data[0],
//         "isMe": false,
//         "time": DateTime.now(),
//       });
//
//       setState(() {});
//     });
//
//     try {
//       await hubConnection.start();
//       isConnected = true;
//       debugPrint("✅ SignalR Connected");
//     } catch (e) {
//       debugPrint("❌ SignalR Error: $e");
//     }
//   }
//
//   // ================= SEND TEXT =================
//
//   Future<void> sendText() async {
//     if (controller.text.trim().isEmpty) return;
//
//     final msg = controller.text.trim();
//
//     chats.add({
//       "type": "text",
//       "msg": msg,
//       "isMe": true,
//       "time": DateTime.now(),
//     });
//
//     controller.clear();
//     setState(() {});
//
//     if (isConnected) {
//       await hubConnection.invoke(
//         "SendMessage",
//         args: [msg, "text"],
//       );
//     }
//   }
//
//   // ================= IMAGE PICK =================
//
//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//
//     await uploadFile(File(image.path), "image");
//   }
//
//   // ================= FILE UPLOAD =================
//
//   Future<void> uploadFile(File file, String type) async {
//     final request = http.MultipartRequest(
//       "POST",
//       Uri.parse(uploadUrl),
//     );
//
//     request.files.add(
//       await http.MultipartFile.fromPath("file", file.path),
//     );
//
//     final response = await request.send();
//
//     if (response.statusCode == 200) {
//       final res = await response.stream.bytesToString();
//       final url = jsonDecode(res)["url"];
//
//       _sendFileMessage(url, type);
//     }
//   }
//
//   // ================= SEND FILE URL =================
//
//   Future<void> _sendFileMessage(String url, String type) async {
//     chats.add({
//       "type": type,
//       "msg": url,
//       "isMe": true,
//       "time": DateTime.now(),
//     });
//
//     setState(() {});
//
//     if (isConnected) {
//       await hubConnection.invoke(
//         "SendMessage",
//         args: [url, type],
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     if (isConnected) hubConnection.stop();
//     super.dispose();
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("SignalR Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: chats.length,
//               itemBuilder: (_, i) {
//                 final chat = chats[i];
//                 return Align(
//                   alignment: chat["isMe"]
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: _chatBubble(chat),
//                 );
//               },
//             ),
//           ),
//           _inputBar(),
//         ],
//       ),
//     );
//   }
//
//   Widget _chatBubble(Map chat) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.all(10),
//       constraints: const BoxConstraints(maxWidth: 250),
//       decoration: BoxDecoration(
//         color: chat["isMe"] ? Colors.green[100] : Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: chat["type"] == "image"
//           ? ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Image.network(chat["msg"]),
//       )
//           : Text(chat["msg"]),
//     );
//   }
//
//   Widget _inputBar() {
//     return SafeArea(
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.image),
//             onPressed: pickImage,
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 hintText: "Message",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: sendText,
//           ),
//         ],
//       ),
//     );
//   }
// }
