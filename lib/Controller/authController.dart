
import 'package:get/get.dart';
import 'package:insurence_crm/Auth/Loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/Dashboard.dart';
import '../Repo/authRepo.dart';
import '../Response/ActiveResponse.dart';
import '../Response/LoginResponse.dart';
import '../Response/ProductResponse.dart';
import '../Response/ReadReponse.dart';
import '../Response/SearchLeadResponse.dart';
import '../util/custom_snackbar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class AuthController extends GetxController {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});




  bool isLoginLoading = false;
  bool isProductLoading = false;
  bool isReadLoading = false;

  LoginResponse? loginResponse;
  ProductResponse? productResponse;
  ReadResponse? readResponse;
  ActiveResponse? activeResponse;

  List<ProductData> filteredProducts = [];
  List<LeadItem> filteredProduct = [];
  RxList<LeadItem> originalLeadLists = <LeadItem>[].obs;

  // ================= LOGIN FUNCTION =================
  Future<void> loginFunction({
    required String loginId,
    required String password,
    required String deviceToken,
  })
  async {
    try {
      isLoginLoading = true;
      update();

      Response response = await authRepo.login(
        loginId: loginId,
        password: password,
        deviceToken: deviceToken,
      );

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body["Data"] != null &&
          response.body["Data"].isNotEmpty) {

        final data = response.body["Data"][0];

        // if (data["Result"] == 1) {
        //
        //   loginResponse = LoginResponse.fromJson(data);
        //
        //   final prefs = await SharedPreferences.getInstance();
        //
        //   await prefs.setBool("isLoggedIn", true);
        //   await prefs.setString("userToken", data["UserToken"] ?? "");
        //   await prefs.setString("deviceToken", data["DeviceToken"] ?? "");
        //   await prefs.setString("UserID", data["PKUserID"].toString());
        //   await prefs.setString("loginId", data["LoginID"] ?? "");
        //   await prefs.setString("FKCompanyID", data["FKCompanyID"].toString());
        //   await prefs.setString("Name", data["Name"] ?? "");
        //   await prefs.setString("ImageURL", data["PhotoURL"] ?? "");
        //   await prefs.setString("URL", data["WebsiteURL"] ?? "");
        //
        //   showCustomSnackBar(
        //     data["Msg"] ?? "Login Success",
        //     isError: false,
        //     getXSnackBar: false,
        //   );
        //
        //   Get.offAll(() => CategoryListScreen());
        // }

        if (data["Result"] == 1) {

          loginResponse = LoginResponse.fromJson(data);

          final prefs = await SharedPreferences.getInstance();

          await prefs.setBool("isLoggedIn", true);
          await prefs.setString("userToken", data["UserToken"] ?? "");
          await prefs.setString("deviceToken", data["DeviceToken"] ?? "");
          await prefs.setString("UserID", data["PKUserID"].toString());
          await prefs.setString("loginId", data["LoginID"] ?? "");
          await prefs.setString("FKCompanyID", data["FKCompanyID"].toString());
          await prefs.setString("Name", data["Name"] ?? "");
          await prefs.setString("ImageURL", data["PhotoURL"] ?? "");
          await prefs.setString("URL", data["WebsiteURL"] ?? "");
          String userId = data["PKUserID"].toString();

          await _connectSignalR(userId);

          print("🟢 Socket Connected After Login");
          Get.offAll(() => CategoryListScreen());
        }
        else {
          showCustomSnackBar(
            data["Msg"] ?? "Login Failed",
            isError: true,
            getXSnackBar: false,
          );
        }
      } else {
        showCustomSnackBar(
          "Server Error",
          isError: true,
          getXSnackBar: false,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        "Something went wrong",
        isError: true,
        getXSnackBar: false,
      );
    } finally {
      isLoginLoading = false;
      update();
    }
  }




  RxBool isLoadings = false.obs;
  RxList<SearchLeadData> leadList = <SearchLeadData>[].obs;
  List<SearchLeadData> originalLeadList = [];
  Future<void> getLeads(int userId,
      String leadID,
      int fKCompanyID,
      int fKProductID,)
  async {
    try {
      isLoadings.value = true;

      final response = await authRepo.fetchLeads(fkUserId: userId,fKCompanyID:fKCompanyID ,fKProductID:fKProductID ,leadID: leadID);
      if (response != null) {
        leadList.assignAll(response.data);
        originalLeadList = response.data; // 👈 Save original
      }
      if (response != null) {
        leadList.assignAll(response.data);
      }

    } catch (e) {
      print("❌ Controller Error: $e");
    } finally {
      isLoadings.value = false;
    }
  }
  // ================= PRODUCT FUNCTION =================
  // Future<void> productFunction({
  //   required String PKUserID,
  //   required String FKCompanyID,
  // })
  // async {
  //   try {
  //     isProductLoading = true;
  //     update();
  //
  //     Response response = await authRepo.product(
  //       PKUserID: PKUserID,
  //       FKCompanyID: FKCompanyID,
  //     );
  //
  //     if (response.statusCode == 200 &&
  //         response.body != null &&
  //         response.body["Data"] != null) {
  //
  //       productResponse = ProductResponse.fromJson(response.body);
  //       filteredProducts = productResponse?.data ?? [];
  //
  //       // 🔥 IMPORTANT PART
  //       if (connected.value) {
  //         for (var product in filteredProducts) {
  //           final ticketId = product.fKOpenLeadID ?? 0;
  //
  //           if (ticketId > 0) {
  //             joinTicketGroup(ticketId);
  //           }
  //         }
  //       }
  //
  //     } else {
  //       productResponse = null;
  //       filteredProducts = [];
  //     }
  //   } catch (e) {
  //     productResponse = null;
  //     filteredProducts = [];
  //   } finally {
  //     isProductLoading = false;
  //     update();
  //   }
  // }


  RxList<LeadItem> leadLists = <LeadItem>[].obs;
  //List<LeadItem> originalLeadLists = [];
  RxBool isLoadings1 = false.obs;
  Future<void> GetLeads(
      int userId,
      String leadID,
      int fKCompanyID,
      int fKProductID,
      String leadStatus, // 👈 NEW
      )
  async {
    try {
      isLoadings1.value = true;

      final response = await authRepo.FetchLeads(
        fkUserId: userId,
        fKCompanyID: fKCompanyID,
        fKProductID: fKProductID,
        leadID: leadID,
        leadStatus: leadStatus, // 👈 pass
      );

      if (response != null) {
        leadLists.assignAll(response.data);
        originalLeadLists.assignAll(response.data);

      }
    } catch (e) {
      print("❌ Controller Error: $e");
    } finally {
      isLoadings1.value = false;
    }
  }

  RxInt searchTrigger = 0.obs;

  Future<void> getLeadsFunction({
    required int userId,
    required String leadID,
    required int fKCompanyID,
    required int fKProductID,
    required String leadStatus,
  })
  async {
    try {
      isLoadings1.value = true;
      update();

      final ActiveResponse? response = await authRepo.FetchLeads(
        fkUserId: userId,
        fKCompanyID: fKCompanyID,
        fKProductID: fKProductID,
        leadID: leadID,
        leadStatus: leadStatus,
      );

      if (response != null && response.data.isNotEmpty) {

        // activeResponse = response;
        // filteredProduct = response.data;
        //
        // originalLeadLists = List.from(filteredProduct);
        // originalLeadLists = List.from(response.data);
        //
        // /// 🔥 Optional observable (agar kahin aur use ho)
        // leadLists.assignAll(response.data);
        activeResponse = response;
        filteredProduct = response.data;

        originalLeadLists.assignAll(response.data);

        /// optional
        leadLists.assignAll(response.data);
        /// 🔥 CONNECT SIGNALR ONLY ONCE
        if (!connected.value) {
          await _connectSignalR(userId.toString());
        }

        /// 🔥 JOIN ALL LEADS
        for (final lead in filteredProduct) {
          final int ticketId = lead.pkId;
          if (ticketId > 0) {
            joinTicketGroup(ticketId);
          }
        }

      }
      else {
       // _clearLeads();
      }

    } catch (e) {
      print("❌ GetLeads Error: $e");
      //_clearLeads();
    } finally {
      isLoadings1.value = false;
      update();
    }
  }

  void filterLeadsByProductName(String query) {
    if (query.isEmpty) {
      // 🔁 Reset to original list
      leadLists.assignAll(originalLeadLists);
    } else {
      final filtered = originalLeadLists.where((lead) {
        return lead.productName
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      leadLists.assignAll(filtered);
    }
  }

  Future<void> productFunction({
    required String PKUserID,
    required String FKCompanyID,
  })
  async {
    try {
      isProductLoading = true;
      update();

      Response response = await authRepo.product(
        PKUserID: PKUserID,
        FKCompanyID: FKCompanyID,
      );

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body["Data"] != null) {

        productResponse = ProductResponse.fromJson(response.body);
        filteredProducts = productResponse?.data ?? [];

        // 🔥 CONNECT SIGNALR HERE (only if not connected)
        if (!connected.value) {
          print("🟢 Connecting SignalR from Product API...");
          await _connectSignalR(PKUserID);
        }

        // 🔥 Join all tickets
        for (var product in filteredProducts) {
          final ticketId = product.fKOpenLeadID ?? 0;
          if (ticketId > 0) {
            joinTicketGroup(ticketId);
          }
        }

      } else {
        productResponse = null;
        filteredProducts = [];
      }
    } catch (e) {
      productResponse = null;
      filteredProducts = [];
    } finally {
      isProductLoading = false;
      update();
    }
  }

  // Future<void> productFunction({
  //   required String PKUserID,
  //   required String FKCompanyID,
  // })
  // async {
  //   try {
  //     isProductLoading = true;
  //     update();
  //
  //     Response response = await authRepo.product(
  //       PKUserID: PKUserID,
  //       FKCompanyID: FKCompanyID,
  //     );
  //
  //     if (response.statusCode == 200 &&
  //         response.body != null &&
  //         response.body["Data"] != null) {
  //
  //       productResponse = ProductResponse.fromJson(response.body);
  //       filteredProducts = productResponse?.data ?? [];
  //     } else {
  //       productResponse = null;
  //       filteredProducts = [];
  //     }
  //   } catch (e) {
  //     productResponse = null;
  //     filteredProducts = [];
  //   } finally {
  //     isProductLoading = false;
  //     update();
  //   }
  // }

  void updateProductUnread(int leadId, int unreadCount) {
    int index = filteredProducts.indexWhere(
          (p) => p.fKOpenLeadID == leadId,
    );

    if (index != -1) {
      filteredProducts[index].unReadCount = unreadCount;

      dashboardUnreadCount.value =
          filteredProducts.fold(
            0,
                (sum, p) => sum + (p.unReadCount ?? 0),
          );

      update();
    }
  }

  void updateActiveUnread(int leadId, int unreadCounts) {
    int index = filteredProduct.indexWhere(
          (p) => p.leadId == leadId,
    );

    if (index != -1) {
      filteredProduct[index].unReadUserCount = unreadCounts;

      dashboardUnreadCount.value =
          filteredProduct.fold(
            0,
                (sum, p) => sum + (p.unReadUserCount ?? 0),
          );

      update();
    }
  }

  // ================= FILTER PRODUCTS =================
  // void filterProducts(String query) {
  //   final allProducts = productResponse?.data ?? [];
  //
  //   if (query.isEmpty) {
  //     filteredProducts = allProducts;
  //   } else {
  //     filteredProducts = allProducts
  //         .where((p) =>
  //         (p.productName ?? "")
  //             .toLowerCase()
  //             .contains(query.toLowerCase()))
  //         .toList();
  //   }
  //
  //   update();
  // }

  void filterProducts(String query) {

    final allProducts = productResponse?.data ?? [];

    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((p) {
        return (p.productName ?? "")
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }

    update(); // rebuild UI
  }

  void filterProduct(String query) {
    final allProduct = activeResponse?.data ?? [];

    if (query.isEmpty) {
      filteredProduct = allProduct;
    } else {
      filteredProduct = allProduct
          .where((p) =>
          (p.productName ?? "")
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }

    update();
  }

  // ================= READ FUNCTION =================
  Future<void> readFunction({
    required String FKLeadID,
    required String FKUserID,
  })
  async {
    try {
      isReadLoading = true;
      update();

      Response response = await authRepo.read(
        FKLeadID: FKLeadID,
        FKUserID: FKUserID,
      );

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body["Data"] != null) {

        readResponse = ReadResponse.fromJson(response.body);
      } else {
        readResponse = null;
      }
    } catch (e) {
      readResponse = null;
    } finally {
      isReadLoading = false;
      update();
    }
  }

  WebSocket? _socket;
  Timer? _reconnectTimer;
  String? _connectionToken;

  RxBool connected = false.obs;
  RxInt dashboardUnreadCount = 0.obs;

  final String baseUrl = "https://partnersras.com";
  final String hubName = "chatHub";

  // ================= LOGIN SUCCESS CALL THIS =================
  Future<void> connectAfterLogin(String userId) async {
    await _connectSignalR(userId);
  }

  // ================= NEGOTIATE =================
  Future<void> _negotiate(String userId) async {
    final connectionData =
    Uri.encodeComponent('[{"name":"$hubName"}]');

    final url =
        "$baseUrl/signalr/negotiate"
        "?clientProtocol=1.5"
        "&connectionData=$connectionData"
        "&UserID=$userId"
        "&UserType=A";

    print("🟡 NEGOTIATE URL: $url");
    final client = http.Client();

    final response = await client.get(Uri.parse(url));
    //final response = await http.get(Uri.parse(url));

    print("🟡 NEGOTIATE RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    _connectionToken =
        Uri.encodeComponent(data["ConnectionToken"]);
  }

  // ================= CONNECT =================
  Future<void> _connectSignalR(String userId) async {
    try {
      print("🟡 Starting SignalR...");

      await _negotiate(userId);

      print("🟢 Negotiate Success");
      print("🟢 ConnectionToken: $_connectionToken");

      final connectionData =
      Uri.encodeComponent('[{"name":"$hubName"}]');

      final wsUrl =
          "wss://partnersras.com/signalr/connect"
          "?transport=webSockets"
          "&clientProtocol=1.5"
          "&connectionToken=$_connectionToken"
          "&connectionData=$connectionData"
          "&tid=8";

      print("🔵 WS URL: $wsUrl");

      _socket = await WebSocket.connect(wsUrl);

      print("🟢 WebSocket Connected");
      print("🔵 ReadyState: ${_socket?.readyState}");

      _socket!.listen(
            (data) {
          print("🔥 SOCKET DATA: $data");
          _handleSocketData(data);
        },
        onDone: () {
          print("❌ SOCKET CLOSED");
          _handleDisconnect(userId);
        },
        onError: (e) {
          print("❌ SOCKET ERROR: $e");
          _handleDisconnect(userId);
        },
      );

      final startUrl =
          "$baseUrl/signalr/start"
          "?transport=webSockets"
          "&clientProtocol=1.5"
          "&connectionToken=$_connectionToken"
          "&connectionData=$connectionData";

      print("🟣 START URL: $startUrl");

      final startResponse = await http.get(Uri.parse(startUrl));

      print("🟣 Start Response: ${startResponse.body}");

      connected.value = true;
      print("✅ Global SignalR Connected");

    } catch (e) {
      print("🚨 CONNECT ERROR: $e");
    }
  }
  // ================= HANDLE MESSAGE =================
  // void _handleSocketData(dynamic data) {
  //   print("🔥 RAW SOCKET DATA: $data");
  //
  //   try {
  //     if (data == null || data.toString().isEmpty) return;
  //
  //     final decoded = jsonDecode(data);
  //
  //     print("🔥 DECODED: $decoded");
  //
  //     if (decoded is! Map || !decoded.containsKey("M")) return;
  //
  //     final List hubMessages = decoded["M"];
  //
  //     for (var hubMsg in hubMessages) {
  //
  //       print("🔥 HUB MESSAGE: $hubMsg");
  //
  //       if (hubMsg["M"] == "ReceiveUnreadCount") {
  //         final args = hubMsg["A"];
  //         print("🔥 Unread Args: $args");
  //
  //         if (args is List && args.isNotEmpty) {
  //           dashboardUnreadCount.value =
  //               int.tryParse(args[0].toString()) ?? 0;
  //         }
  //       }
  //
  //       if (hubMsg["M"] == "ReceiveMessage") {
  //         print("📩 New Message: ${hubMsg["A"]}");
  //       }
  //     }
  //
  //   } catch (e) {
  //     print("Parse Error: $e");
  //   }
  // }

  void updateUnread(int leadId) {

    int index = originalLeadLists.indexWhere(
          (e) => e.pkId.toString() == leadId.toString(),
    );

    if (index != -1) {

      originalLeadLists[index].unReadUserCount =
          (originalLeadLists[index].unReadUserCount ?? 0) + 1;

      originalLeadLists.refresh(); // UI refresh
    }

  }
  RxList<ProductResponse> productList = <ProductResponse>[].obs;
  // void _handleSocketData(dynamic data) {
  //   try {
  //     if (data == null || data.toString().isEmpty) return;
  //
  //     final decoded = jsonDecode(data);
  //
  //     if (decoded is! Map || !decoded.containsKey("M")) return;
  //
  //     final List hubMessages = decoded["M"];
  //
  //     for (var hubMsg in hubMessages) {
  //
  //       // 🔔 MESSAGE RECEIVED
  //       if (hubMsg["M"] == "ReceiveMessage") {
  //
  //         final args = hubMsg["A"];
  //
  //         if (args is List && args.isNotEmpty) {
  //
  //           final message = args[0];
  //           int leadId = message["FKLeadID"] ?? 0;
  //           if (leadId == currentOpenLeadId.value) {
  //             _refreshReadData();
  //           }
  //
  //
  //           print("📩 Message for Lead: $leadId");
  //
  //           // 👇 Increment unread locally
  //           updateProductUnreadIncrement(leadId);
  //           updateProductUnreadIncrements(leadId);
  //           updateUnreadForLead(leadId);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Parse Error: $e");
  //   }
  // }
  void _handleSocketData(dynamic data) {

    if (data == "{}") return; // ignore heartbeat

    print("🔥 SOCKET DATA: $data");

    try {

      if (data == null || data.toString().isEmpty) return;

      final decoded = jsonDecode(data);

      if (decoded is! Map || !decoded.containsKey("M")) return;

      final List hubMessages = decoded["M"];

      for (var hubMsg in hubMessages) {

        if (hubMsg["M"] == "ReceiveMessage") {

          final args = hubMsg["A"];

          if (args is List && args.isNotEmpty) {

            final message = args[0];

            int leadId = int.parse(message["FKLeadID"].toString());

            print("📩 Message for Lead: $leadId");

            /// 🔥 UPDATE UNREAD BADGE
            Get.find<AuthController>().updateUnread(leadId);

          }
        }
      }

    } catch (e) {

      print("Socket Parse Error: $e");

    }
  }

  // void _handleSocketData(dynamic data) {
  //   try {
  //
  //     if (data == null || data.toString().isEmpty) return;
  //
  //     final decoded = jsonDecode(data);
  //
  //     if (decoded is! Map || !decoded.containsKey("M")) return;
  //
  //     final List hubMessages = decoded["M"];
  //
  //     for (var hubMsg in hubMessages) {
  //
  //       if (hubMsg["M"] == "ReceiveMessage") {
  //
  //         final args = hubMsg["A"];
  //
  //         if (args is List && args.isNotEmpty) {
  //
  //           final message = args[0];
  //
  //           int leadId = message["FKLeadID"] ?? 0;
  //
  //           print("📩 Message for Lead: $leadId");
  //           if (leadId == currentOpenLeadId.value) {
  //             _refreshReadData();
  //           } else {
  //             updateUnreadForLead(leadId);
  //           }
  //           // 👇 Agar chat open hai to read refresh
  //           // if (leadId == currentOpenLeadId.value) {
  //           //   _refreshReadData();
  //           // } else {
  //           //
  //           //   // 👇 unread increase
  //           //   updateUnreadForLead(leadId);
  //           //
  //           //   // dashboard count
  //           //   updateProductUnreadIncrement(leadId);
  //           //   updateProductUnreadIncrements(leadId);
  //           //
  //           // }
  //
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Parse Error: $e");
  //   }
  // }
  Timer? _readTimer;
  RxInt currentOpenLeadId = 0.obs;
  RxString currentUserId = "".obs;
  void _refreshReadData() {
    _readTimer?.cancel();

    _readTimer = Timer(const Duration(milliseconds: 500), () {
      readFunction(
        FKLeadID: currentOpenLeadId.value.toString(),
        FKUserID: currentUserId.value,
      );
    });
  }

  // void updateUnreadForLead(int leadId) {
  //
  //   // PRODUCT LIST
  //   final productIndex = filteredProducts.indexWhere(
  //           (e) => e.fKOpenLeadID == leadId);
  //
  //   if (productIndex != -1) {
  //     filteredProducts[productIndex].unReadCount += 1;
  //   }
  //
  //   // ACTIVE LEAD LIST
  //   final leadIndex = filteredProduct.indexWhere(
  //           (e) => e.pkId == leadId);
  //
  //   if (leadIndex != -1) {
  //     filteredProduct[leadIndex].unReadUserCount =
  //         (filteredProduct[leadIndex].unReadUserCount ?? 0) + 1;
  //   }
  //
  //   dashboardUnreadCount.value =
  //       filteredProducts.fold(
  //           0,
  //               (sum, p) => sum + (p.unReadCount ?? 0));
  //
  //   update();
  //
  //   print("✅ Unread Updated for Lead $leadId");
  // }
  // void updateUnreadForLead(int leadId) {
  //
  //   // PRODUCT LIST
  //   final productIndex =
  //   filteredProducts.indexWhere((e) => e.fKOpenLeadID == leadId);
  //
  //   if (productIndex != -1) {
  //     filteredProducts[productIndex].unReadCount =
  //         (filteredProducts[productIndex].unReadCount ?? 0) + 1;
  //   }
  //
  //   // ACTIVE LEAD LIST
  //   final leadIndex =
  //   filteredProduct.indexWhere((e) => e.pkId == leadId);
  //
  //   if (leadIndex != -1) {
  //     filteredProduct[leadIndex].unReadUserCount =
  //         (filteredProduct[leadIndex].unReadUserCount ?? 0) + 1;
  //   }
  //
  //   // DASHBOARD COUNT
  //   dashboardUnreadCount.value = filteredProducts.fold(
  //     0,
  //         (sum, p) => sum + (p.unReadCount ?? 0),
  //   );
  //
  //   update(); // because using GetBuilder
  //
  //   print("✅ Unread Updated for Lead $leadId");
  // }
  void updateUnreadForLead(int leadId) {

    final productIndex =
    filteredProducts.indexWhere((e) => e.fKOpenLeadID == leadId);

    if (productIndex != -1) {

      filteredProducts[productIndex].unReadCount =
          (filteredProducts[productIndex].unReadCount ?? 0) + 1;

      //filteredProducts.refresh();
    }

    final leadIndex =
    filteredProduct.indexWhere((e) => e.pkId == leadId);

    if (leadIndex != -1) {

      filteredProduct[leadIndex].unReadUserCount =
          (filteredProduct[leadIndex].unReadUserCount ?? 0) + 1;

      //filteredProduct.refresh();
    }

    dashboardUnreadCount.value =
        filteredProducts.fold(
            0,
                (sum, p) => sum + (p.unReadCount ?? 0));
  }
  void updateProductUnreadIncrement(int leadId) {

    final index = filteredProducts.indexWhere(
            (element) => element.fKOpenLeadID == leadId);

    if (index != -1) {

      filteredProducts[index].unReadCount =
          filteredProducts[index].unReadCount + 1;

      // 🔥 Dashboard total update
      dashboardUnreadCount.value =
          filteredProducts.fold(
            0,
                (sum, p) => sum + p.unReadCount,
          );

      update(); // because you are using GetBuilder

      print("✅ Unread Updated for Lead $leadId");
    } else {
      print("❌ No Product Found For Lead $leadId");
    }
  }
  void updateProductUnreadIncrements(int leadId) {

    final index = filteredProduct.indexWhere(
            (element) => element.pkId == leadId);

    if (index != -1) {

      filteredProduct[index].unReadUserCount =
          (filteredProduct[index].unReadUserCount ?? 0) + 1;

      // 🔥 ORIGINAL LIST UPDATE
      final originalIndex = originalLeadLists.indexWhere(
              (element) => element.pkId == leadId);

      if (originalIndex != -1) {
        originalLeadLists[originalIndex].unReadUserCount =
            (originalLeadLists[originalIndex].unReadUserCount ?? 0) + 1;
      }

      dashboardUnreadCount.value =
          filteredProduct.fold(
            0,
                (sum, p) => sum + (p.unReadUserCount ?? 0),
          );

      update();
    }
  }
  // void updateProductUnreadIncrements(int leadId) {
  //
  //   final index = filteredProduct.indexWhere(
  //           (element) => element.leadId == leadId);
  //
  //   if (index != -1) {
  //
  //     filteredProduct[index].unReadUserCount =
  //         filteredProduct[index].unReadUserCount + 1;
  //
  //     // 🔥 Dashboard total update
  //     dashboardUnreadCount.value =
  //         filteredProduct.fold(
  //           0,
  //               (sum, p) => sum + p.unReadUserCount,
  //         );
  //
  //     update(); // because you are using GetBuilder
  //
  //     print("✅ Unread Updated for Lead $leadId");
  //   } else {
  //     print("❌ No Product Found For Lead $leadId");
  //   }
  // }

  // ================= JOIN TICKET =================
  final Set<int> _joinedTickets = {};
  void joinTicketGroup(int ticketId) {
    if (!connected.value || _socket == null) return;

    if (_joinedTickets.contains(ticketId)) return; // prevent duplicate

    final data = {
      "H": hubName,
      "M": "JoinTicketGroup",
      "A": [ticketId.toString()], // 👈 always string
      "I": DateTime.now().millisecondsSinceEpoch.toString()
    };

    _socket!.add(jsonEncode(data));

    _joinedTickets.add(ticketId);

    print("✅ Joined Ticket: $ticketId");
  }
  // ================= LEAVE TICKET =================
  void leaveTicketGroup(int ticketId) {
    if (!connected.value || _socket == null) return;

    final data = {
      "H": hubName,
      "M": "LeaveTicketGroup",
      "A": [ticketId],
      "I": DateTime.now().millisecondsSinceEpoch.toString()
    };

    _socket!.add(jsonEncode(data));

    print("🚪 Left Ticket: $ticketId");
  }

  // ================= DISCONNECT =================
  void _handleDisconnect(String userId) {
    connected.value = false;
    _joinedTickets.clear(); // 👈 clear joined list
    print("⚠️ Disconnected");
    _scheduleReconnect(userId);
  }
  void _scheduleReconnect(String userId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connectSignalR(userId);
    });
  }

  @override
  void onClose() {
    _socket?.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }


  // ================= CHECK LOGIN =================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => Loginpage());
  }
}
