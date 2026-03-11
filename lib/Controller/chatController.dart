

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import '../Repo/chatRepo.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../api/api.dart';

class ChatController extends GetxController {
  final ChatRepo repo = ChatRepo();
  final ScrollController scrollCtrl = ScrollController();
  HubConnection? hubConnection;
  RxList<Map<String, dynamic>> messagess = <Map<String, dynamic>>[].obs;
  RxBool sendings = false.obs;
  //RxBool loading = false.obs;
  RxBool connected = false.obs;

  late int fkCompanyID;
  late int fkAgentID;
  late int fkProductID;
  late int fkLeadID;
  RxBool isSending = false.obs;
  RxString ticketId = "".obs;
  Timer? _reconnectTimer;
  WebSocket? _socket;

  late String _connectionToken;

  final String baseUrl = "https://partnersras.com";
  final String hubName = "chatHub";

  // ================= INIT =================
  Future<void> initChat({
    required int leadId,
    required int companyId,
    required int agentId,
    required int productId,
  })
  async {
    fkLeadID = leadId;
    fkCompanyID = companyId;
    fkAgentID = agentId;
    fkProductID = productId;

    loading.value = true;

    await fetchMessages(
      leadId: leadId,
      companyId: companyId,
    );

    await _connectSignalR();

    loading.value = false;
  }


  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  RxBool loading = false.obs;


  Future<void> fetchMessages({
    required int leadId,
    required int companyId,
  }) async {
    try {
      loading.value = true;

      final response =
      await repo.fetchMessages(leadId, companyId);

      if (response["Data"] != null &&
          response["Data"].isNotEmpty) {

        ticketId.value = response["Data"][0]["LeadID"]?.toString() ?? "";
      }

      final List messageList =
          response["MessageLogs"] ?? [];

      messages.clear();

      for (final item in messageList) {
        messages.add({
          "MsgText": item["MsgText"] ?? "",
          "FromUserType": item["FromUserType"] ?? "",
          "PKID": int.tryParse(item["PKID"]?.toString() ?? "0") ?? 0,
          "MsgType": item["MsgType"] ?? "TEXT",
          "MsgDate": item["MsgDate"] ?? "",
          "OriginalFileName": item["OriginalFileName"] ?? "",
          "SavedFileName": item["SavedFileName"] ?? "",
          "FileName": item["FileURL"] ?? "",
        });
      }

      messages.refresh();

      // 🔥 IMPORTANT
      if (connected.value && leadId != 0) {
        await joinTicketGroup(leadId);
        print("✅ Re-Joined Group: $leadId");
      }

    } catch (e) {
      print("❌ fetchMessages error: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> _negotiate() async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/signalr/negotiate?clientProtocol=1.5&userid=$fkAgentID&usertype=A",
      ),
    );

    final data = jsonDecode(response.body);
    _connectionToken = Uri.encodeComponent(data["ConnectionToken"]);
  }

  // ================= CONNECT SIGNALR =================
  Future<void> _connectSignalR() async {
    try {
      await _negotiate();

      final connectionData =
      Uri.encodeComponent('[{"name":"$hubName"}]');

      final wsUrl =
          "wss://partnersras.com/signalr/connect"
          "?transport=webSockets"
          "&clientProtocol=1.5"
          "&connectionToken=$_connectionToken"
          "&connectionData=$connectionData"
          "&tid=8";

      _socket = await WebSocket.connect(wsUrl);

      _socket!.listen(
        _handleSocketData,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );

      final startUrl =
          "$baseUrl/signalr/start"
          "?transport=webSockets"
          "&clientProtocol=1.5"
          "&connectionToken=$_connectionToken"
          "&connectionData=$connectionData";

      await http.get(Uri.parse(startUrl));

      connected.value = true;

      await joinTicketGroup(fkLeadID);

      print("✅ SignalR Connected");
    } catch (e) {
      print("❌ SignalR Error: $e");
      _scheduleReconnect();
    }
  }
// ================= PUBLIC CONNECT =================
  Future<void> connectSignalRIfNeeded() async {
    if (connected.value) {
      print("⚠ SignalR already connected");
      return;
    }

    await _connectSignalR();
  }
  // void _handleSocketData(dynamic data) {
  //   try {
  //     final decoded = jsonDecode(data);
  //     if (decoded is! Map || !decoded.containsKey("M")) return;
  //
  //     final List hubMessages = decoded["M"];
  //
  //     for (var hubMsg in hubMessages) {
  //       if (hubMsg["M"] == "ReceiveMessage") {
  //         final args = hubMsg["A"];
  //
  //         if (args is List && args.isNotEmpty) {
  //           final msg = args[0];
  //
  //           final int fromUserId =
  //               int.tryParse(msg["FKFromUserID"]?.toString() ?? "0") ?? 0;
  //
  //           final bool isMe = fromUserId == fkAgentID;
  //           final String msgType = msg["MsgType"]?.toString() ?? "TEXT";
  //
  //           // ✅ YAHI LIVE MESSAGE ADD HOGA
  //           messages.add({
  //             "MsgText": msgType == "TEXT"
  //                 ? msg["MsgText"]?.toString() ?? ""
  //                 : "📎 ${msg["OriginalFileName"]?.toString() ?? ""}",
  //             "FromUserType": isMe ? "F" : "C",
  //             "MsgType": msgType,
  //             "MsgDate": msg["MsgDate"]?.toString()
  //                 ?? DateTime.now().toIso8601String(),
  //             "PKID": int.tryParse(msg["PKID"]?.toString() ?? "0") ?? 0,
  //             "OriginalFileName":
  //             msg["OriginalFileName"]?.toString() ?? "",
  //             "SavedFileName":
  //             msg["SavedFileName"]?.toString() ?? "",
  //           });
  //
  //           messages.refresh();
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Parse Error: $e");
  //   }
  // }

  bool _messageExists(int pkid) {
    return messages.any((m) => m["PKID"] == pkid && pkid != 0);
  }
  RxInt dashboardUnreadCount = 0.obs;
  // void _handleSocketData(dynamic data) {
  //   try {
  //     if (data == null || data.toString().isEmpty) return;
  //
  //     final decoded = jsonDecode(data);
  //     if (decoded is! Map || !decoded.containsKey("M")) return;
  //
  //     final List hubMessages = decoded["M"];
  //
  //     for (var hubMsg in hubMessages) {
  //
  //       // =============================
  //       // 🔥 1️⃣ NEW MESSAGE EVENT
  //       // =============================
  //       if (hubMsg["M"] == "ReceiveMessage") {
  //         final args = hubMsg["A"];
  //         if (args is! List || args.isEmpty) continue;
  //
  //         final msg = args[0];
  //
  //         final int pkid = int.tryParse(msg["PKID"]?.toString() ?? "0") ?? 0;
  //
  //         // 🔴 Generate a unique ID fallback if PKID is 0 or null
  //         final String uniqueId = pkid > 0
  //             ? pkid.toString()
  //             : "${msg["MsgDate"]}_${msg["FromUserType"]}_${msg["MsgText"]}";
  //
  //         // 🔴 Duplicate check using uniqueId
  //         if (messages.any((m) => m["UniqueID"] == uniqueId)) {
  //           print("⚠ Duplicate skipped: $uniqueId");
  //           continue;
  //         }
  //
  //         final String msgType = msg["MsgType"] ?? "TEXT";
  //
  //         // ✅ Add message
  //         messages.add({
  //           "UniqueID": uniqueId,
  //           "PKID": pkid,
  //           "MsgText": msgType == "FILE"
  //               ? "📎 ${msg["OriginalFileName"] ?? ""}"
  //               : msg["MsgText"] ?? "",
  //           "FromUserType": msg["FromUserType"] ?? "C",
  //           "MsgType": msgType,
  //           "MsgDate": msg["MsgDate"] ?? "",
  //           "OriginalFileName": msg["OriginalFileName"] ?? "",
  //           "SavedFileName": msg["SavedFileName"] ?? "",
  //           "FileName": msg["FileURL"] ?? "",
  //         });
  //
  //         messages.refresh();
  //
  //         // 🔥 Debug
  //         print("✅ NEW MESSAGE ADDED: $uniqueId");
  //         print("✅ TOTAL MESSAGES: ${messages.length}");
  //       }
  //
  //       // =============================
  //       // 🔥 2️⃣ UNREAD COUNT EVENT
  //       // =============================
  //       if (hubMsg["M"] == "ReceiveUnreadCount") {
  //         final args = hubMsg["A"];
  //         if (args is List && args.isNotEmpty) {
  //           dashboardUnreadCount.value =
  //               int.tryParse(args[0].toString()) ?? 0;
  //           print("🔵 Unread Count Updated: ${dashboardUnreadCount.value}");
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Parse Error: $e");
  //   }
  // }

// ----------------------------
  // Find message index in the list (server or temp)
  int findMessageIndex(Map msg) {
    final int pkid = int.tryParse(msg["PKID"]?.toString() ?? "0") ?? 0;
    final String originalFile = msg["OriginalFileName"] ?? "";
    final String fromUser = msg["FromUserType"] ?? "C";
    final String uniqueId = msg["UniqueID"] ?? "";

    return messages.indexWhere((m) =>
    (pkid > 0 && m["PKID"] == pkid) ||
        (uniqueId.isNotEmpty && m["UniqueID"] == uniqueId) || // temp merge fix
        (m["PKID"] == 0 && m["OriginalFileName"].contains(originalFile) && m["FromUserType"] == fromUser)
    );
  }

// Construct file URL if missing
  String buildFileUrl(String fileUrl, String savedFile) {
    if (fileUrl.isEmpty && savedFile.isNotEmpty) {
      return "$baseUrl/Uploads/$savedFile";
    }
    return fileUrl;
  }

// Generate unique ID for temp message
  String generateTempUniqueId(String fileName) {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    return "$tempId-$fileName";
  }

// SOCKET MESSAGE HANDLER
// ----------------------------
  void _handleSocketData(dynamic data) {
    try {
      if (data == null || data.toString().isEmpty) return;

      final decoded = jsonDecode(data);
      if (decoded is! Map || !decoded.containsKey("M")) return;

      final List hubMessages = decoded["M"];
      bool shouldRefresh = false;

      for (var hubMsg in hubMessages) {
        final String method = hubMsg["M"] ?? "";
        final args = hubMsg["A"];

        // 🔥 RECEIVE MESSAGE
        if (method == "ReceiveMessage" && args is List && args.isNotEmpty) {
          final msg = args[0];
          final int pkid = int.tryParse(msg["PKID"]?.toString() ?? "0") ?? 0;
          final String msgType = msg["MsgType"] ?? "TEXT";
          final String msgDate = msg["MsgDate"]?.toString() ?? DateTime.now().toIso8601String();
          final String originalFile = msg["OriginalFileName"] ?? "";

          final String uniqueId = pkid > 0
              ? pkid.toString()
              : "${msgDate}_${msg["FromUserType"]}_$originalFile";

          String fileUrl = msg["FileURL"] ?? msg["FileName"] ?? "";
          final String savedFile = msg["SavedFileName"] ?? "";
          fileUrl = buildFileUrl(fileUrl, savedFile);

          // Ignore incomplete FILE
          if (msgType == "FILE" && fileUrl.isEmpty && savedFile.isEmpty) {
            print("⚠ Ignored incomplete FILE message: $uniqueId");
            continue;
          }

          // Merge or add
          final int existingIndex = findMessageIndex(msg);

          if (existingIndex != -1) {
            messages[existingIndex] = {
              ...messages[existingIndex],
              "PKID": pkid,
              "SavedFileName": savedFile,
              "FileURL": fileUrl,
              "isUploading": false,
              "UniqueID": uniqueId,
              "MsgText": msgType == "FILE" ? "" : msg["MsgText"] ?? "",
              "MsgType": msgType,
              "MsgDate": msgDate,
            };
            print("✅ Merged message: $uniqueId");
          } else {
            messages.add({
              "UniqueID": uniqueId,
              "PKID": pkid,
              "MsgText": msgType == "FILE" ? "" : msg["MsgText"] ?? "",
              "FromUserType": msg["FromUserType"] ?? "C",
              "MsgType": msgType,
              "MsgDate": msgDate,
              "OriginalFileName": originalFile,
              "SavedFileName": savedFile,
              "FileURL": fileUrl,
              "isUploading": false,
            });
            print("✅ NEW MESSAGE ADDED: $uniqueId");
          }

          shouldRefresh = true;
        }

        // 🔵 UNREAD COUNT
        // if (method == "ReceiveUnreadCount" && args is List && args.isNotEmpty) {
        //   dashboardUnreadCount.value = int.tryParse(args[0].toString()) ?? 0;
        //   print("🔵 Unread Count Updated: ${dashboardUnreadCount.value}");
        // }
      }

      if (shouldRefresh) messages.refresh();
    } catch (e, st) {
      print("❌ Parse Error: $e\n$st");
    }
  }
// ----------------------------
// SEND FILE (WITH TEMP MESSAGE)
// ----------------------------
  Future<void> sendFileMultipart({
    required String filePath,
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
  })
  async {

    try {

      final file = File(filePath);

      print("📁 FILE PATH: $filePath");

      if (!file.existsSync()) {
        print("❌ File does not exist");
        return;
      }

      final fileName = file.path.split('/').last;

      print("📁 FILE NAME: $fileName");
      print("📁 FILE SIZE (KB): ${file.lengthSync() / 1024}");

      final uniqueId = generateTempUniqueId(fileName);

      /// 🔹 TEMP MESSAGE FOR UI
      final tempMessage = {
        "PKID": 0,
        "UniqueID": uniqueId,
        "MsgType": "FILE",
        "OriginalFileName": fileName,
        "filePath": filePath,
        "isUploading": true,
        "FromUserType": "F",
        "MsgDate": DateTime.now().toIso8601String(),
      };

      messages.add(tempMessage);
      messages.refresh();

      /// 🔹 READ FILE
      final bytes = await file.readAsBytes();

      print("📦 FILE BYTES LENGTH: ${bytes.length}");

      /// 🔹 BASE64
      final base64File = base64Encode(bytes);

      print("📦 BASE64 LENGTH: ${base64File.length}");

      final payload = {
        "FKCompanyID": companyId,
        "FKLeadID": leadId,
        "FKAgentID": agentId,
        "FKProductID": productId,
        "OriginalFileName": fileName,
        "Base64File": base64File,
      };

      print("📤 API URL: https://chatapi.partnersras.com/api/SendFileMessage");

      print("📤 PAYLOAD:");
      print(jsonEncode(payload));

      /// 🔹 API CALL
      final response = await http.post(
        Uri.parse("https://chatapi.partnersras.com/api/SendFileMessage"),
        headers: {
          "ApiToken": "1497-63919e5460b9d-476578",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("📥 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);

        final realMsg = decoded["Data"]?[0];

        if (realMsg != null) {

          final String savedFile = realMsg["SavedFileName"] ?? "";

          String fileUrl =
          buildFileUrl(realMsg["FileURL"] ?? "", savedFile);

          /// 🔹 UPDATE TEMP MESSAGE
          int index =
          messages.indexWhere((m) => m["UniqueID"] == uniqueId);

          if (index != -1) {

            messages[index] = {
              ...messages[index],
              "PKID": realMsg["PKID"] ?? 0,
              "SavedFileName": savedFile,
              "FileURL": fileUrl,
              "isUploading": false,
              "MsgDate": realMsg["MsgDate"] ??
                  DateTime.now().toIso8601String(),
            };

            messages.refresh();
          }

          print("✅ FILE UPLOAD SUCCESS");

        }

      } else {

        print("❌ UPLOAD FAILED");

        messages.removeWhere((m) => m["UniqueID"] == uniqueId);
        messages.refresh();

        Get.snackbar("Error", "File upload failed");

      }

    } catch (e) {

      print("🚨 UPLOAD ERROR: $e");

      Get.snackbar("Error", "File upload failed");

    }
  }
//   Future<void> sendFileMultipart({
//     required String filePath,
//     required int companyId,
//     required int leadId,
//     required int agentId,
//     required int productId,
//   })
//   async {
//     try {
//       final file = File(filePath);
//       final fileName = file.path.split('/').last;
//       final uniqueId = generateTempUniqueId(fileName);
//
//       // 🔹 Temp message for UI
//       final tempMessage = {
//         "PKID": 0,
//         "UniqueID": uniqueId,
//         "MsgType": "FILE",
//         "OriginalFileName": fileName,
//         "filePath": filePath,
//         "isUploading": true,
//         "FromUserType": "F",
//         "MsgDate": DateTime.now().toIso8601String(),
//       };
//
//       messages.add(tempMessage);
//       messages.refresh();
//
//       // Convert to Base64
//       final bytes = await file.readAsBytes();
//       final base64File = base64Encode(bytes);
//       final payload = {
//         "FKCompanyID": companyId,
//         "FKLeadID": leadId,
//         "FKAgentID": agentId,
//         "FKProductID": productId,
//         "OriginalFileName": fileName,
//         "Base64File": base64File,
//       };
//       print("📤 Sending File API Payload: ${jsonEncode(payload)}");
//       final response = await http.post(
//         Uri.parse("https://chatapi.partnersras.com/api/SendFileMessage"),
//         headers: {
//           "ApiToken": "1497-63919e5460b9d-476578",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "FKCompanyID": companyId,
//           "FKLeadID": leadId,
//           "FKAgentID": agentId,
//           "FKProductID": productId,
//           "OriginalFileName": fileName,
//           "Base64File": base64File,
//         }),
//       );
//       print("📤 Sending File API Payload: ${jsonEncode(payload)}");
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         final realMsg = decoded["Data"]?[0];
//         Get.snackbar("Error", "File upload");
//         if (realMsg != null) {
//           final String savedFile = realMsg["SavedFileName"] ?? "";
//           String fileUrl = buildFileUrl(realMsg["FileURL"] ?? "", savedFile);
//
//           // 🔹 Update temp message
//           int index = messages.indexWhere((m) => m["UniqueID"] == uniqueId);
//           if (index != -1) {
//             messages[index] = {
//               ...messages[index],
//               "PKID": realMsg["PKID"] ?? 0,
//               "SavedFileName": savedFile,
//               "FileURL": fileUrl,
//               "isUploading": false,
//               "MsgDate": realMsg["MsgDate"] ?? DateTime.now().toIso8601String(),
//             };
//             messages.refresh();
//           }
//         }
//       } else {
//         // ❌ Remove temp if failed
//         messages.removeWhere((m) => m["UniqueID"] == uniqueId);
//         messages.refresh();
//       }
//     } catch (e) {
//       print("Upload Error: $e");
//       Get.snackbar("Error", "File upload failed");
//     }
//   }

  Future<void> joinTicketGroup(int ticketId) async {
    if (!connected.value || _socket == null) return;

    final data = {
      "H": hubName,
      "M": "JoinTicketGroup",
      "A": [ticketId],
      "I": DateTime.now().millisecondsSinceEpoch.toString()
    };

    _socket!.add(jsonEncode(data));

    print("✅ Joined Group: $ticketId");
  }

  // Future<void> sendMessage({
  //   required int companyId,
  //   required int leadId,
  //   required int agentId,
  //   required int productId,
  //   required String text,
  // }) async {
  //
  //   if (text.trim().isEmpty) return;
  //
  //   final uniqueId = generateTempUniqueId("text");
  //
  //   /// 🔹 TEMP MESSAGE FOR UI
  //   final tempMessage = {
  //     "PKID": 0,
  //     "UniqueID": uniqueId,
  //     "MsgType": "TEXT",
  //     "TextMessage": text,
  //     "isSending": true,
  //     "FromUserType": "F",
  //     "MsgDate": DateTime.now().toIso8601String(),
  //   };
  //
  //   messages.add(tempMessage);
  //   messages.refresh();
  //
  //   try {
  //
  //     final Map<String, dynamic> response = await repo.sendText(
  //       companyId: companyId,
  //       leadId: leadId,
  //       agentId: agentId,
  //       productId: productId,
  //       text: text,
  //     );
  //
  //     /// 🔹 FIND TEMP MESSAGE
  //     int index = messages.indexWhere((m) => m["UniqueID"] == uniqueId);
  //
  //     if (index != -1) {
  //       messages[index] = {
  //         ...messages[index],
  //         "PKID": response['PKID'] ?? 0, // <- change here
  //         "isSending": false,
  //         "MsgDate": DateTime.now().toIso8601String(),
  //       };
  //
  //       messages.refresh();
  //     }
  //
  //   } catch (e) {
  //
  //     /// ❌ FAIL
  //     messages.removeWhere((m) => m["UniqueID"] == uniqueId);
  //     messages.refresh();
  //
  //     Get.snackbar("Error", "Message send failed");
  //   }
  // }

  // Future<void> sendMessage({
  //   required int companyId,
  //   required int leadId,
  //   required int agentId,
  //   required int productId,
  //   required String text,
  //   // socket callback for broadcasting
  //   Function(Map<String,dynamic>)? onMessageSent,
  // })
  // async {
  //   if (text.trim().isEmpty) return;
  //
  //   final uniqueId = generateTempUniqueId("text");
  //
  //   /// 🔹 TEMP MESSAGE FOR UI
  //   final tempMessage = {
  //     "PKID": 0,
  //     "UniqueID": uniqueId,
  //     "MsgType": "TEXT",
  //     "TextMessage": text,
  //     "isSending": true,
  //     "FromUserType": "F",
  //     "MsgDate": DateTime.now().toIso8601String(),
  //   };
  //
  //   messages.add(tempMessage);
  //   messages.refresh();
  //   scrollToBottom();
  //
  //   try {
  //     final Map<String, dynamic> response = await repo.sendText(
  //       companyId: companyId,
  //       leadId: leadId,
  //       agentId: agentId,
  //       productId: productId,
  //       text: text,
  //     );
  //
  //     /// 🔹 Update temp message
  //     int index = messages.indexWhere((m) => m["UniqueID"] == uniqueId);
  //     if (index != -1) {
  //       messages[index] = {
  //         ...messages[index],
  //         "PKID": response['PKID'] ?? 0,
  //         "MsgText": text,
  //         "isSending": false,
  //         "MsgDate": DateTime.now().toIso8601String(),
  //       };
  //       messages.refresh();
  //       //scrollToBottom();
  //     }
  //
  //     /// 🔹 Callback to notify server socket / broadcast
  //     if(onMessageSent != null) onMessageSent(messages[index]);
  //
  //   } catch (e) {
  //     messages.removeWhere((m) => m["UniqueID"] == uniqueId);
  //     messages.refresh();
  //     Get.snackbar("Error", "Message send failed");
  //   }
  // }
  // Future<void> sendMessage({
  //   required int companyId,
  //   required int leadId,
  //   required int agentId,
  //   required int productId,
  //   required String text,
  // }) async {
  //   if (text.trim().isEmpty || isSending.value) return;
  //
  //   final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   // 🔹 TEMP MESSAGE FOR UI
  //   final tempMessage = {
  //     "PKID": 0,
  //     "UniqueID": uniqueId,
  //     "MsgType": "TEXT",
  //     "TextMessage": text,
  //     "isSending": true,       // mark sending
  //     "FromUserType": "F",
  //     "MsgDate": DateTime.now().toIso8601String(),
  //   };
  //
  //   messages.add(tempMessage); // add temp message to chat
  //   messages.refresh();
  //
  //   scrollToBottom(); // scroll if you want
  //
  //   isSending.value = true;
  //
  //   try {
  //     // 🔹 API call
  //     final Map<String, dynamic> response = await repo.sendText(
  //       companyId: companyId,
  //       leadId: leadId,
  //       agentId: agentId,
  //       productId: productId,
  //       text: text,
  //     );
  //
  //     // 🔹 Update temp message
  //     final index = messages.indexWhere((m) => m["UniqueID"] == uniqueId);
  //     if (index != -1) {
  //       // Replace the whole map
  //       messages[index] = {
  //         ...messages[index],
  //         "PKID": response['PKID'] ?? 0,
  //         "MsgText": text,
  //         "isSending": false,
  //         "MsgDate": DateTime.now().toIso8601String(),
  //       };
  //
  //       // 🔹 Notify GetX about the update
  //       messages.refresh();  // important
  //       scrollToBottom();
  //     }
  //
  //   } catch (e) {
  //     // ❌ Remove temp message on fail
  //     messages.removeWhere((m) => m["UniqueID"] == uniqueId);
  //     messages.refresh();
  //     Get.snackbar("Error", "Message send failed");
  //   } finally {
  //     isSending.value = false;
  //   }
 // }
  Future<void> sendMessage({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String text,
  })
  async {
    if (isSending.value || text.trim().isEmpty) return;

    isSending.value = true;

    try {
      await repo.sendText(
        companyId: companyId,
        leadId: leadId,
        agentId: agentId,
        productId: productId,
        text: text,
      );



    } catch (e) {
      Get.snackbar("Error", "Message send failed");
    } finally {
      isSending.value = false;
    }
  }

  RxInt leadId = 0.obs;
  RxString ticketNumber = "".obs;
  Future<void> NewLead({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String text,
  })
  async {

    if (isSending.value || text.trim().isEmpty) return;

    isSending.value = true;

    try {

      final response = await repo.newLead(
        companyId: companyId,
        leadId: leadId,
        agentId: agentId,
        productId: productId,
        text: text,
      );

      final data = response["Data"]?[0];
      if (data == null) return;

      final int result = data["Result"] ?? 0;

      if (result != 1) {
        print("⚠️ Lead not created: ${data["Msg"]}");
        return;
      }

      final int newLeadId = data["FKLeadID"] ?? 0;
      final String ticketNo = data["TicketNo"] ?? "";

      if (newLeadId <= 0) return;

      // ✅ THIS IS THE MAIN FIX
      this.leadId.value = newLeadId;       // 👈 reactive update
      this.ticketNumber.value = ticketNo;  // 👈 optional for UI

      if (!connected.value) {
        await _connectSignalR();
      }

      await joinTicketGroup(newLeadId);

      await fetchMessages(
        leadId: newLeadId,
        companyId: companyId,
      );

      print("✅ Joined Group: $newLeadId");

    } catch (e) {
      print("❌ NewLead Error: $e");
      Get.snackbar("Error", "Message send failed");
    } finally {
      isSending.value = false;
    }
  }


  RxBool isSendingss = false.obs;
  RxList<dynamic> Messages = <dynamic>[].obs;

  // ===============================
  // 📂 PICK FILE + SEND
  // ===============================

  Future<void> pickAndSendFile({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
  })
  async {

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) return;

      File file = File(result.files.single.path!);

      String base64File = await _convertToBase64(file);

      await sendFile(
        companyId: companyId,
        leadId: leadId,
        agentId: agentId,
        productId: productId,
        originalFileName: result.files.single.name,
        base64File: base64File,
      );

    } catch (e) {
      print("File Pick Error: $e");
    }
  }

  // ===============================
  // 🔄 Convert To Base64
  // ===============================

  Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // ===============================
  // 📤 SEND FILE API
  // ===============================

  Future<void> sendFile({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String originalFileName,
    required String base64File,
  })
  async {

    if (isSendingss.value) return;

    isSendingss.value = true;

    try {

      final url = Uri.parse(
        "https://chatapi.partnersras.com/api/SendFileMessage",
      );

      final response = await http.post(
        url,
        headers: {
          "ApiToken": "1497-63919e5460b9d-476578",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "FKCompanyID": companyId,
          "FKLeadID": leadId,
          "FKAgentID": agentId,
          "FKProductID": productId,
          "OriginalFileName": originalFileName,
          "Base64File": base64File,
        }),
      );

      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE BODY = ${response.body}");

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final table = data["Table"]?[0];

        if (table != null && table["Result"] == 1) {

          // 🔥 Instant UI Update (No Delay)
          Messages.insert(0, table);

          Messages.refresh();

          print("✅ File Sent Successfully");
        }

      } else {
        Get.snackbar("Error", "File send failed");
      }

    } catch (e) {
      print("Send File Error: $e");
      Get.snackbar("Error", "File send failed");
    } finally {
      isSendingss.value = false;
    }
  }



  RxInt downloadingMsgId = 0.obs;

  Future<void> downloadAndOpenFile({
    required int pkMsgId,
    required int companyId,
    required String fileName,
  }) async {
    try {
      downloadingMsgId.value = pkMsgId;

      final String fileUrl =
          "https://chatapi.partnersras.com/api/DownloadFile"
          "?PKMsgID=$pkMsgId&FKCompanyID=$companyId";

      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$fileName";

      await Dio().download(
        fileUrl,
        filePath,
        options: Options(
          headers: {
            "ApiToken": ApiUrls.apiToken,
          },
        ),
      );

      final extension = fileName.split('.').last.toLowerCase();

      if (extension == "pdf") {
        await OpenFilex.open(filePath, type: "application/pdf");
      } else if (extension == "jpg" || extension == "jpeg") {
        await OpenFilex.open(filePath, type: "image/jpeg");
      } else if (extension == "png") {
        await OpenFilex.open(filePath, type: "image/png");
      } else {
        await OpenFilex.open(filePath);
      }

    } catch (e) {
      print("❌ Download Error: $e");
    } finally {
      downloadingMsgId.value = 0;
    }
  }
  // Future<void> downloadAndOpenFile({
  //   required int pkMsgId,
  //   required int companyId,
  // })
  // async {
  //   try {
  //     downloadingMsgId.value = pkMsgId;
  //
  //     final String fileUrl =
  //         "https://chatapi.partnersras.com/api/DownloadFile"
  //         "?PKMsgID=$pkMsgId&FKCompanyID=$companyId";
  //
  //     print("Download URL: $fileUrl");
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final apiToken = prefs.getString("ApiToken") ?? "";
  //
  //     final dir = await getApplicationDocumentsDirectory();
  //     final fileName = "file_$pkMsgId.pdf";
  //
  //    // final fileName = "file_$pkMsgId";
  //     final filePath = "${dir.path}/$fileName";
  //
  //     await Dio().download(
  //       fileUrl,
  //       filePath,
  //       options: Options(
  //         responseType: ResponseType.bytes,
  //         headers: {
  //           "ApiToken": ApiUrls.apiToken,  // 🔥 MUST MATCH POSTMAN
  //         },
  //       ),
  //     );
  //
  //     await OpenFilex.open(filePath,  type: "application/pdf",
  //     );
  //
  //   } catch (e) {
  //     print("❌ Download Error: $e");
  //   } finally {
  //     downloadingMsgId.value = 0;
  //   }
  // }

  void addMessages(List<Map<String, dynamic>> newMessages) {
    for (var msg in newMessages) {
      bool exists = messages.any((m) => m["PKID"] == msg["PKID"]);
      if (!exists) {
        // Convert backend format to UI-friendly format
        messages.add({
          "text": msg["MsgText"],
          "isMe": msg["FromUserType"] == "F",
          "PKID": msg["PKID"],
          "MsgType": msg["MsgType"],
          "MsgDate": msg["MsgDate"],
          "time": DateTime.tryParse(msg["MsgDate"]) ?? DateTime.now(),
        });
      }
    }
  }


  void _handleDisconnect() {
    connected.value = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connectSignalR();
    });
  }

  // ================= CLEANUP =================
  @override
  void onClose() {
    _socket?.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
