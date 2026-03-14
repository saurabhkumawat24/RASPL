
import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Response/ActiveResponse.dart';
import '../Response/SearchLeadResponse.dart';
import '../Response/lead_reopen_model.dart';
import '../api/api.dart';
import '../api/api_client.dart';
import '../util/appContants.dart';
import 'package:http/http.dart' as http;


class AuthRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> login({
    required String loginId,
    required String password,
    required String deviceToken,
  })
  async {
    return await apiClient.getDataOther(
      "https://chatapi.partnersras.com/api/Login"
          "?LoginID=$loginId"
          "&PWD=$password"
          "&DeviceToken=$deviceToken",
      headers: {
        "Content-Type": "application/json",
        "ApiToken": ApiUrls.apiToken, // 🔥 MUST
      },
    );
  }

  Future<Response> product({
    required String PKUserID,
    required String FKCompanyID,
  })
  async {
    return await apiClient.getDataOther(
      "https://chatapi.partnersras.com/api/GetProduct"
          "?PKUserID=$PKUserID"
          "&FKCompanyID=$FKCompanyID",
      headers: {
        "Content-Type": "application/json",
        "ApiToken": ApiUrls.apiToken, // 🔥 MUST
      },
    );
  }

  Future<Response> read({
    required String FKLeadID,
    required String FKUserID,
  })
  async {
    return await apiClient.getDataOther(
      "https://chatapi.partnersras.com/api/UpdateMessageReadStatus"
          "?FKLeadID=$FKLeadID"
          "&FKUserID=$FKUserID",
      headers: {
        "Content-Type": "application/json",
        "ApiToken": ApiUrls.apiToken, // 🔥 MUST
      },
    );
  }

  Future<SearchLeadResponse?> fetchLeads({
    required int fkUserId,
    required String leadID,
    required int fKCompanyID,
    required int fKProductID,
  })
  async {

    final url = Uri.parse(
        "https://chatapi.partnersras.com/api/SearchLead?LeadID=$leadID&FKCompanyID=$fKCompanyID&FKProductID=$fKProductID&LeadStatus=close&FKUserID=$fkUserId");

    final response = await http.get(
      url,
      headers: {
        "ApiToken": ApiUrls.apiToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SearchLeadResponse.fromJson(data);
    } else {
      print("❌ API Error: ${response.statusCode}");
      return null;
    }
  }

  Future<ActiveResponse?> FetchLeads({
    required int fkUserId,
    required String leadID,
    required int fKCompanyID,
    required int fKProductID,
    required String leadStatus,
  }) async
  {
    try {
      final queryParams = {
        "LeadID": leadID,
        "FKCompanyID": fKCompanyID.toString(),
        "FKProductID": fKProductID.toString(),
        "LeadStatus": leadStatus.replaceAll(" ", ""),
        "FKUserID": fkUserId.toString(),
      };

      final url = Uri.https(
        "chatapi.partnersras.com",
        "/api/SearchLead",
        queryParams,
      );

      print("📤 FINAL URL: $url");

      final response = await http
          .get(
        url,
        headers: {"ApiToken": ApiUrls.apiToken},
      )
          .timeout(const Duration(seconds: 15));

      print("📥 STATUS: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return ActiveResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ FetchLeads Error: $e");
    }

    return null;
  }

  Future<LeadReopenModel?> leadReopen({
    required int fkUserId,
    required String fkLeadID,
  }) async
  {
    try {
      final queryParams = {
        "FKLeadID": fkLeadID.toString(),
        "FKUserID": fkUserId.toString(),
      };

      final url = Uri.https(
        "chatapi.partnersras.com",
        "/api/ReopenLeadRequest",
        queryParams,
      );

      print("📤 FINAL URL: $url");

      final response = await http.get(
        url,
        headers: {"ApiToken": ApiUrls.apiToken},
      )
          .timeout(const Duration(seconds: 15));

      print("📥 STATUS: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return LeadReopenModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ FetchLeads Error: $e");
    }

    return null;
  }

















  Future<bool>saveUserPassword(String password)
  async{
    return await sharedPreferences.setString(password, password);
  }

  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(
        token);
    return await sharedPreferences.setString(AppContants.token, token);
  }
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppContants.token);
  }



  bool clearSharedData() {

    apiClient.token = null;
    sharedPreferences.clear();
    apiClient.updateHeader("");
    return true;
  }
}