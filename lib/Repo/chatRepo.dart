import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../api/api.dart';

class ChatRepo {
  Future<Map<String, dynamic>> fetchMessages(
      int leadId,
      int companyId,
      ) async {
    final res = await http.get(
      Uri.parse(
        "https://chatapi.partnersras.com/api/GetLeadMessage"
            "?FKLeadID=$leadId&FKCompanyID=$companyId",
      ),
      headers: {
        "ApiToken": ApiUrls.apiToken,
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      return {};
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;   // 🔥 return full response
    }

    return {};
  }

  Future<Map<String, dynamic>> sendText({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String text,
  })
  async {
    final url = Uri.parse(
      "https://chatapi.partnersras.com/api/SendTextMessage",
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
        "MsgType": "TEXT",
        "MsgText": text,
      }),
    );

    print("STATUS CODE = ${response.statusCode}");
    print("RESPONSE BODY = ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Send message failed");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendFile({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String originalFileName,
    required String base64File,
  }) async {

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

    if (response.statusCode != 200) {
      throw Exception("Send file failed");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> newLead({
    required int companyId,
    required int leadId,
    required int agentId,
    required int productId,
    required String text,
  })
  async {
    final url = Uri.parse(
      "https://chatapi.partnersras.com/api/CreateLead",
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
        "MsgType": "TEXT",
        "MsgText": text,
      }),
    );

    print("STATUS CODE = ${response.statusCode}");
    print("RESPONSE BODY = ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Send message failed");
    }

    return jsonDecode(response.body);
  }

  Future<Uint8List> downloadFile({
    required int pkMsgId,
    required int companyId,
  }) async {

    final url = Uri.parse(
      "https://chatapi.partnersras.com/api/DownloadFile"
          "?PKMsgID=$pkMsgId&FKCompanyID=$companyId",
    );

    final response = await http.get(
      url,
      headers: {
        "ApiToken": "1497-63919e5460b9d-476578",
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;   // ✅ DIRECT BYTES
    } else {
      throw Exception("Download failed: ${response.statusCode}");
    }
  }

}



// Future<List<Map<String, dynamic>>> fetchMessages(
//     int leadId,
//     int companyId,
//     )
// async {
//   final res = await http.get(
//     Uri.parse(
//       "https://chatapi.partnersras.com/api/GetLeadMessage"
//           "?FKLeadID=$leadId&FKCompanyID=$companyId",
//     ),
//     headers: {
//       "ApiToken": ApiUrls.apiToken,
//       "Content-Type": "application/json",
//     },
//   );
//
//   if (res.statusCode != 200) {
//     return [];
//   }
//
//   final decoded = jsonDecode(res.body);
//
//   // API safety: handle both Map & List
//   if (decoded is Map<String, dynamic>) {
//     final logs = decoded["MessageLogs"];
//     if (logs is List) {
//       return List<Map<String, dynamic>>.from(logs);
//     }
//     if (logs is Map<String, dynamic>) {
//       return [Map<String, dynamic>.from(logs)];
//     }
//   }
//
//   if (decoded is List) {
//     return List<Map<String, dynamic>>.from(decoded);
//   }
//
//   return [];
// }

// ===== SEND =====

// Future sendText({
//   required int companyId,
//   required int leadId,
//   required int agentId,
//   required int productId,
//   required String text,
// })
// async {
//   await http.post(
//     Uri.parse("https://chatapi.partnersras.com/api/SendTextMessage"),
//     headers: {
//       "ApiToken": ApiUrls.apiToken,
//       "Content-Type": "application/json"
//     },
//     body: jsonEncode({
//       "FKCompanyID": companyId,
//       "FKLeadID": leadId,
//       "FKAgentID": agentId,
//       "FKProductID": productId,
//       "MsgType": "TEXT",
//       "MsgText": text
//     }),
//   );
// }

// Future<Uint8List> downloadFile({
//   required int pkMsgId,
//   required int companyId,
// }) async {
//   final url = Uri.parse(
//     "https://chatapi.partnersras.com/api/DownloadFile"
//         "?PKMsgID=$pkMsgId&FKCompanyID=$companyId",
//   );
//
//   final response = await http.get(
//     url,
//     headers: {
//       "ApiToken": "1497-63919e5460b9d-476578",
//     },
//   );
//
//   if (response.statusCode == 200) {
//     return response.bodyBytes;
//   } else {
//     throw Exception("Download failed: ${response.statusCode}");
//   }
// }
//
// Future markRead(int leadId, int userId) async {
//   await http.get(
//     Uri.parse(
//         "https://chatapi.partnersras.com/api/UpdateMessageReadStatus"
//             "?FKLeadID=$leadId&FKUserID=$userId"
//     ),
//     headers: {
//       "ApiToken": ApiUrls.apiToken,
//       "Content-Type": "application/json"
//     },
//   );
// }
