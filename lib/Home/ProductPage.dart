import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/authController.dart';
import '../Controller/chatController.dart';
import '../Response/ProductResponse.dart';
import '../main.dart';
import '../util/appImage.dart';
import '../util/font_family.dart';
import 'Chatpage.dart';
import 'Profile.dart';

class Productpage extends StatefulWidget {
  const Productpage({super.key});

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> {
  @override
  TextEditingController searchController = TextEditingController();
  // ================= INIT =================
  @override
  final chatController = Get.find<ChatController>();
  RxInt searchTrigger = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
    //chatController.connectSignalRIfNeeded();
  }
  // ================= ROUTE AWARE =================
  @override


  @override
  String userName = '';
  String imageUrl = '';
  String websiteUrl = '';
  String LoginId = '';
  bool showProductList = false;
  final AuthController authController = Get.find<AuthController>();

  // ================= API CALL =================
  Future<void> _initializeData() async {
    final AuthController authController = Get.find<AuthController>();

    final prefs = await SharedPreferences.getInstance();

    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;

    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;

    setState(() {
      userName = prefs.getString("Name") ?? '';
      imageUrl = prefs.getString("ImageURL") ?? '';
      websiteUrl = prefs.getString("URL") ?? '';
      LoginId = prefs.getString("loginId") ?? '';
    });
    final int CompanyID =
        int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    if (!mounted) return;

    authController.productFunction(
      PKUserID: agentId.toString(),
      FKCompanyID: companyId.toString(),
    );

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // if (authController.isProductLoading) {
    //   return const Center(
    //     child: CircularProgressIndicator(
    //       color: Color(0xFF2e448d),
    //     ),
    //   );
    // }

    final products = authController.filteredProducts;
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF202f66),
                  Color(0xFF2e448d),
                  Color(0xFF475594),
                  Color(0xFF5a6bb6),
                ],
              ),
            ),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white)),
                const SizedBox(width: 10),
                Text("All Product", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22)),

                // CircleAvatar(radius: 20, backgroundImage: AssetImage(AppImage.AppLogo)),
              ],
            ),
          ),
        ),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [
      //           Color(0xFF202f66),
      //           Color(0xFF2e448d),
      //           Color(0xFF475594),
      //           Color(0xFF5a6bb6),
      //         ],
      //         begin: Alignment.topLeft,
      //         end: Alignment.topRight,
      //       ),
      //     ),
      //   ),
      //   titleSpacing: 0,
      //   title: Row(
      //     children: [
      //       const SizedBox(width: 8),
      //
      //       CircleAvatar(
      //         radius: 22,
      //         backgroundColor: Colors.transparent,
      //         child: CircleAvatar(
      //           radius: 22,
      //           backgroundImage: imageUrl.isNotEmpty
      //               ? NetworkImage(imageUrl)
      //               : null,
      //           child: imageUrl.isEmpty
      //               ? CircleAvatar( radius: 22, backgroundColor: Colors.white,
      //             child: CircleAvatar(
      //               radius: 20,
      //               backgroundImage: AssetImage(
      //                 AppImage.AppLogo,
      //
      //               ), ), )
      //               : null,
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //
      //       // 🧑 Name & ID
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             userName,
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 16,
      //               fontWeight: FontWeight.w600,
      //             ),
      //           ),
      //           const SizedBox(height: 2),
      //           Text(
      //             LoginId,
      //             style: TextStyle(
      //               color: Colors.white70,
      //               fontSize: 12,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),



      body: GetBuilder<AuthController>(
          builder: (authController) {
            final products = authController.filteredProducts;

            return Padding(
        padding: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              // ===================
              // SEARCH FIELD
              // ===================
              TextField(
                onChanged: (value) {
                  authController.filterProducts(value);

                },
                decoration: InputDecoration(
                  hintText: "Search by Name",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  contentPadding:
                  const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===================
              // PRODUCT LIST
              // ===================
              Expanded(
                child: products.isEmpty
                    ? const Center(
                  child: Text("No Products Found"),
                )
                    : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ChatController chatController = Get.find<
                        ChatController>();

                    final product =
                    products[index];

                    return Column(
                      children: [

                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => navigateToChats(product),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Left Icon / Avatar

                              const SizedBox(width: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: product.iconURL.toString() !=
                                        null && product.iconURL!.isNotEmpty
                                        ? NetworkImage(product.iconURL.toString())
                                        : AssetImage(
                                        AppImage.Background) as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded( // 🔥 MOST IMPORTANT
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          product.productName.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: FontFamily.roboto

                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.productName.toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black54,
                                              height: 1.3,
                                              fontFamily: FontFamily.roboto

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Text(
                                      //   product.leadID.toString(),
                                      //   style: theme.textTheme.titleMedium
                                      //       ?.copyWith(
                                      //       fontSize: 15,
                                      //       color: Colors.grey,
                                      //       fontFamily: FontFamily.roboto
                                      //
                                      //   ),
                                      // ),

                                      //  const SizedBox(height: 4),

                                      // Obx(() => chatController.dashboardUnreadCount.value > 0
                                      //     ? Container(
                                      //   padding: EdgeInsets.all(6),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.red,
                                      //     shape: BoxShape.circle,
                                      //   ),
                                      //   child: Text(
                                      //     chatController.dashboardUnreadCount.value.toString(),
                                      //     style: TextStyle(color: Colors.white),
                                      //   ),
                                      // )
                                      //     : SizedBox())
                                      /// Product unread count
                                      // if ((product.unReadCount ?? 0) > 0)
                                      //   CircleAvatar(
                                      //     radius: 12,
                                      //     backgroundColor: Colors.red,
                                      //     child: Text(
                                      //       (product.unReadCount ?? 0) > 99
                                      //           ? "99+"
                                      //           : product.unReadCount.toString(),
                                      //       style: const TextStyle(
                                      //         fontSize: 11,
                                      //         color: Colors.white,
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // Obx(() {
                                      //   final auth = Get.find<AuthController>();
                                      //
                                      //   return Text(
                                      //     auth.dashboardUnreadCount.value.toString(),
                                      //     style: TextStyle(fontSize: 18, color: Colors.red),
                                      //   );
                                      // })
                                      // if ((product.unReadCount ?? 0) > 0)
                                      //   CircleAvatar(
                                      //     radius: 12,
                                      //     backgroundColor: Colors.red,
                                      //     child: Text(
                                      //       (product.unReadCount ?? 0) > 99
                                      //           ? "0+"
                                      //           : product.unReadCount.toString(),
                                      //       style: const TextStyle(
                                      //         fontSize: 11,
                                      //         color: Colors.white,
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //   ),
                                      //     CircleAvatar(
                                      //     radius: 11,
                                      //     backgroundColor: const Color(0xFF5a6bb6),
                                      //     child:  Text(product.unReadCount.toString(),
                                      //       style: TextStyle(
                                      //         fontSize: 10,
                                      //         color: Colors.white,
                                      //         fontWeight: FontWeight.w600,
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ],
                              )

                              //const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 65),
                          // 50 radius + 15 spacing
                          child: const Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      );})

    );
  }

  Future<void> navigateToChats(ProductData product) async {

    final prefs = await SharedPreferences.getInstance();
    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    final int leadId = 0;
    final int productId = product.pKID;
    final String ticket = product.leadID;   // 👈 YEH IMPORTANT
    final String image = product.iconURL;   // 👈 YEH IMPORTANT

    debugPrint("📌 Navigating to WhatsAppChatPage:");
    debugPrint("Title: ${product.productName}");
    debugPrint("LeadId: $leadId");
    debugPrint("Ticket: $ticket");
    debugPrint("ProductId: $productId");
    debugPrint("CompanyId: $companyId");
    debugPrint("AgentId: $agentId");

    Get.to(
          () => WhatsAppChatPage(
        title: product.productName,
        leadId: leadId,
        ticket: ticket, // 👈 PASS THIS
        companyId: companyId,
        agentId: agentId,
        imageurl: image,
        productId: productId,
      ),
      transition: Transition.rightToLeft, // animation type
      duration: const Duration(milliseconds: 400), // animation time
      curve: Curves.easeInOut,
    );
  }

}
