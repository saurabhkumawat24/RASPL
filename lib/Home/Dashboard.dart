import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:insurence_crm/Home/Profile.dart';
import 'package:insurence_crm/util/font_family.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/authController.dart';
import '../Controller/chatController.dart';
import '../Response/ActiveResponse.dart';
import '../Response/ProductResponse.dart';
import '../Response/SearchLeadResponse.dart';
import '../main.dart';
import '../util/appImage.dart';
import 'Chatpage.dart';
import 'CloseChat.dart';
import 'ProductPage.dart';

enum LeadView {
  active,
  closed,
  create,
}
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> with RouteAware{
  bool isActive = true;

  final List<Map<String, dynamic>> items = [
    {"title": "GCCV", "msg": "This is the sample msg..", "count": 4},
    {"title": "PCCV", "msg": "This is the sample msg.."},
    {"title": "PRIVATE CAR", "msg": "This is the sample msg which should appear in two lines only like WhatsApp preview text"},
    {"title": "MISCELLANEOUS", "msg": "This is the sample msg.."},
    {"title": "TWO WHEELER", "msg": "This is the sample msg.."},

  ];
  @override
  RxInt searchTrigger = 0.obs;
  TextEditingController searchController = TextEditingController();
  // ================= INIT =================
  @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _initializeData();
  //   });
  // }
  final chatController = Get.find<ChatController>();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override

  /// 🔥 Jab Chat page se BACK aate ho
  @override
  void didPopNext() {
    debugPrint("🔁 Back to Dashboard → refreshing API");
    _initializeData();
  }
  String userName = '';
  String imageUrl = '';
  String websiteUrl = '';
  String LoginId = '';
  bool showProductList = false;
  final AuthController authController = Get.find<AuthController>();

  LeadView currentView = LeadView.active;
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
    await authController.getLeadsFunction(
      userId: agentId,
      leadID: "All",
      fKCompanyID: CompanyID,
      fKProductID: 0,
      leadStatus: "Open,Pending", // 👈 Active leads
    );
  }
  Future<void> callActiveApi() async {
    final prefs = await SharedPreferences.getInstance();
    final int CompanyID =
        int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
    await authController.getLeadsFunction(
      userId: agentId,
      leadID: "All",
      fKCompanyID: CompanyID,
      fKProductID: 0,
      leadStatus: "Open,Pending", // 👈 Active leads
    );
  }

  Future<void> callClosedApi() async {
    final prefs = await SharedPreferences.getInstance();
    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
    await authController.getLeads(agentId, "Closed", 1, 0);
  }
  @override
  String selectedFilter = "date"; // date | id | product
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final AuthController authController = Get.find<AuthController>();


      return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
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
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),

      CircleAvatar(
      radius: 22,
      backgroundColor: Colors.transparent,
      child: CircleAvatar(
      radius: 22,
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? CircleAvatar( radius: 22, backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(
              AppImage.AppLogo,

           ), ), )
            : null,
      ),
      ),
      const SizedBox(width: 12),

            // 🧑 Name & ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                 Text(
                   LoginId,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(width: 12),
          GestureDetector(
              onTap: (){
                Get.to(
                      () => Profile(),
                  transition: Transition.rightToLeft, // animation type
                  duration: const Duration(milliseconds: 400), // animation time
                  curve: Curves.easeInOut, // smooth feel
                );              },
              child: Icon(Icons.settings,color: Colors.white,)),
          SizedBox(width: 12),

        ],
      ),


        body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
          Row(
          children: [
            _tabButton(
              context,
              title: "Active",
              selected: currentView == LeadView.active,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final int agentId =
                    int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
                final int CompanyID =
                    int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
                setState(() {
                  currentView = LeadView.active;
                });

                await authController.getLeadsFunction(
                  userId: agentId,
                  leadID: "All",
                  fKCompanyID: CompanyID,
                  fKProductID: 0,
                  leadStatus: "Open,Pending",
                );
              },
            ),
          const SizedBox(width: 10),
            _tabButton(
              context,
              title: "Closed",
              selected: currentView == LeadView.closed,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final int agentId =
                    int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
                final int CompanyID =
                    int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;

                setState(() {
                  currentView = LeadView.closed;
                });
                await authController.getLeadsFunction(
                  userId: agentId,
                  leadID: "All",
                  fKCompanyID: CompanyID,
                  fKProductID: 0,
                  leadStatus: "Close",
                );
               // await authController.getLeads(agentId, "Closed", 1, 0);
              },
            ),
          ],
        ),
            SizedBox(height: 10,),
            // Expanded(
            //   child: showProductList
            //       ? _ProductCategoryList(theme)
            //       : isActive
            //       ? _activeCategoryList(theme)
            //       : _closedTicketList(theme),
            // ),
            Expanded(
              child: currentView == LeadView.create
                  ? _ProductCategoryList(theme)
                  : currentView == LeadView.active
                  ? _activeCategoryList(theme)
                  : _closedTicketList(theme),
            ),
          ],
        ),
      ),

      );
  }
  Widget _bottomFixedButton() {
    return SafeArea(
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5a6bb6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            Get.to(
                  () => Productpage(

              ),
              transition: Transition.rightToLeft, // animation type
              duration: const Duration(milliseconds: 400), // animation time
              curve: Curves.easeInOut,
            );

          },
          child: const Text(
            "Create New Lead",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void onTabChange(bool value) async {
    setState(() {
      isActive = value;
    });

    if (isActive) {
      await callActiveApi();   // ✅ Active API
    } else {
      await callClosedApi();   // ✅ Closed API
    }
  }
  // 🔘 Tab Button using Theme
  Widget _tabButton(
      BuildContext context, {
        required String title,
        required bool selected,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Color(0xFF5a6bb6)
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0xFF5a6bb6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? Colors.white : Color(0xFF5a6bb6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }


  Widget _ProductCategoryList(ThemeData theme) {
    return GetBuilder<AuthController>(
      builder: (authController) {

        if (authController.isProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2e448d),
            ),
          );
        }

        final products = authController.filteredProducts;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// 🔍 SEARCH
              TextField(
                onChanged: (value) {
                  authController.filterProducts(value);
                },
                decoration: InputDecoration(
                  hintText: "Search by Name",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 📦 PRODUCT LIST
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text("No Products Found"))
                    : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {

                    final product = products[index];

                    return ListTile(
                      title: Text(product.productName ?? ""),
                      subtitle: Text(product.leadID ?? ""),
                    );

                  },
                ),
              ),
            ],
          ),
        );
      },
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
    )?.then((value) {

      // 👇 Back aane par refresh
      _initializeData();

    });
  }
  Future<void> navigateToChat(LeadItem product) async {

    final prefs = await SharedPreferences.getInstance();
    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    final int leadId = product.pkId;
    final int productId = product.fkProductId;
    final String ticket = product.leadId;   // 👈 YEH IMPORTANT
    final String image = product.iconUrl;   // 👈 YEH IMPORTANT

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
    )?.then((value) {

      // 👇 Back aane par refresh
      _initializeData();

    });
  }
  Future<void> navigateToChatss(LeadItem product) async {

    final prefs = await SharedPreferences.getInstance();
    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    final int leadId = product.pkId;
    final int productId = product.fkProductId;
    final String ticket = product.leadId;   // 👈 YEH IMPORTANT
    final String image = product.iconUrl;   // 👈 YEH IMPORTANT

    debugPrint("📌 Navigating to WhatsAppChatPage:");
    debugPrint("Title: ${product.productName}");
    debugPrint("LeadId: $leadId");
    debugPrint("Ticket: $ticket");
    debugPrint("ProductId: $productId");
    debugPrint("CompanyId: $companyId");
    debugPrint("AgentId: $agentId");

    Get.to(
          () => Closechat(
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
    )?.then((value) {

      // 👇 Back aane par refresh
      _initializeData();

    });
  }

  Future<void> navigateToChat1(SearchLeadData ticketData) async {
    final prefs = await SharedPreferences.getInstance();

    final int agentId =
        int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;

    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;
    final int productId = int.tryParse(ticketData.fkProductID?.toString() ?? "0") ?? 0;
    final int leadId = int.tryParse(ticketData.pkid?.toString() ?? "0") ?? 0;
    final String ticketId = ticketData.leadID ?? "";
    final String image = ticketData.agentPhoto;   // 👈 YEH IMPORTANT

    debugPrint("📌 Navigating to WhatsAppChatPage:");
    debugPrint("Title: ${ticketData.companyURL}");
    debugPrint("LeadId: $leadId");
    debugPrint("Ticket: $ticketId");
    debugPrint("ProductId: $productId");
    debugPrint("CompanyId: $companyId");
    debugPrint("AgentId: $agentId");
    Get.to(
          () => Closechat(
        title: ticketData.productName.toString(),
        leadId: leadId,
        ticket: ticketId,
        companyId: companyId,
        agentId: agentId,
        productId: productId,
            imageurl: image,
      ),
      transition: Transition.rightToLeft, // animation type
        duration: const Duration(milliseconds: 400), // animation time
        curve: Curves.easeInOut,
    )?.then((value) {

      // 👇 Back aane par refresh
      _initializeData();

    });
  }

  // Widget _closedTicketList(ThemeData theme) {
  //
  //   final controller = Get.find<AuthController>();
  //
  //   return Obx(() {
  //
  //     // 🔹 Filter only closed leads
  //     List<SearchLeadData> filteredTickets =
  //     controller.leadList
  //         .where((lead) => lead.leadStatus == "Close")
  //         .toList();
  //
  //     // 🔹 Apply sorting
  //     if (selectedFilter == "date") {
  //       filteredTickets.sort(
  //               (a, b) => b.creationDate.compareTo(a.creationDate));
  //     } else if (selectedFilter == "id") {
  //       filteredTickets.sort(
  //               (a, b) => a.leadID.compareTo(b.leadID));
  //     } else if (selectedFilter == "product") {
  //       filteredTickets.sort(
  //               (a, b) => a.productName.compareTo(b.productName));
  //     }
  //
  //     if (controller.isLoadings.value) {
  //       return const Center(child: CircularProgressIndicator());
  //     }
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         TextField(
  //           controller: searchController,
  //           onChanged: (value) async {
  //             final String value = searchController.text.trim();
  //
  //             if (value.isEmpty) {
  //               // 🔥 Restore old data
  //               controller.leadList.assignAll(controller.originalLeadList);
  //               return;
  //             }
  //
  //             final results = controller.originalLeadList.where((lead) {
  //               return lead.leadID.toString().contains(value) ||
  //                   lead.productName.toString().toLowerCase().contains(value.toLowerCase());
  //             }).toList();
  //
  //             controller.leadList.assignAll(results);
  //           },
  //           decoration: InputDecoration(
  //             hintText: "Search by Lead ID",
  //             prefixIcon: const Icon(Icons.search),
  //             filled: true,
  //             fillColor: Colors.grey.withOpacity(0.1),
  //             contentPadding:
  //             const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(15),
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //         ),
  //
  //         const SizedBox(height: 15),
  //
  //         Expanded(
  //           child: ListView.separated(
  //             itemCount: filteredTickets.length,
  //             separatorBuilder: (_, __) =>
  //             const SizedBox(height: 10),
  //             itemBuilder: (context, index) {
  //               final ChatController chatController = Get.find<ChatController>();
  //               final ticket = filteredTickets[index];
  //
  //
  //               return  Column(
  //                 children: [
  //                   InkWell(
  //                     borderRadius: BorderRadius.circular(12),
  //                     onTap: () => navigateToChat1(ticket),
  //
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         // 🔹 Left Icon / Avatar
  //
  //                         const SizedBox(width: 14),
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             CircleAvatar(
  //                               radius: 25,
  //                               backgroundColor: Colors.grey.shade200,
  //                               backgroundImage: ticket.agentPhoto.toString() != null && ticket.agentPhoto!.isNotEmpty
  //                                   ? NetworkImage("${ticket.companyURL}${ticket.agentPhoto}",)
  //                                   :  AssetImage(AppImage.Background,) as ImageProvider,
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded( // 🔥 MOST IMPORTANT
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     ticket.productName.toString(),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontWeight: FontWeight.w600,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     ticket.leadDescription.toString(),
  //                                     maxLines: 2,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.w400,
  //                                         color: Colors.black54,
  //                                         height: 1.3,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //
  //                             const SizedBox(width: 8),
  //
  //                             Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               children: [
  //                                 Text(
  //                                   ticket.leadID.toString(),
  //                                   style: theme.textTheme.titleMedium?.copyWith(
  //                                       fontSize: 15,
  //                                       color: Colors.grey,
  //                                       fontFamily: FontFamily.roboto
  //
  //                                   ),
  //                                 ),
  //
  //                                 const SizedBox(height: 4),
  //
  //                                 Text(
  //                                   ticket.assignDate.toString(),
  //                                   style: theme.textTheme.titleMedium?.copyWith(
  //                                       fontSize: 10,
  //                                       color: Colors.grey,
  //                                       fontFamily: FontFamily.roboto
  //
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         )
  //
  //                         //const Icon(Icons.arrow_forward_ios, size: 16),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
  //                     child: const Divider(
  //                       thickness: 0.5,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                 ],
  //               );
  //
  //             },
  //           ),
  //
  //
  //         ),
  //       ],
  //     );
  //   });
  // }


  // Widget _activeCategoryList(ThemeData theme) {
  //   final controller = Get.find<AuthController>();
  //
  //   return Obx(() {
  //     if (controller.isLoadings1.value) {
  //       return const Center(child: CircularProgressIndicator());
  //     }
  //
  //     /// 🔥 STEP 1: Always start from ORIGINAL list
  //     List<LeadItem> list = controller.originalLeadLists;
  //
  //     /// 🔥 STEP 2: Active filter
  //     list = list.where((lead) =>
  //     lead.leadStatus == "Open" ||
  //         lead.leadStatus == "Pending"
  //     ).toList();
  //
  //     /// 🔥 STEP 3: Search filter
  //     final search = searchController.text.trim().toLowerCase();
  //     if (search.isNotEmpty) {
  //       list = list.where((lead) {
  //         return lead.leadId.toLowerCase().contains(search) ||
  //             lead.productName.toLowerCase().contains(search);
  //       }).toList();
  //     }
  //
  //     /// 🔥 STEP 4: Sorting
  //     if (selectedFilter == "date") {
  //       list.sort((a, b) =>
  //           (b.creationDate ?? DateTime(0))
  //               .compareTo(a.creationDate ?? DateTime(0)));
  //     } else if (selectedFilter == "id") {
  //       list.sort((a, b) => a.leadId.compareTo(b.leadId));
  //     } else if (selectedFilter == "product") {
  //       list.sort((a, b) => a.productName.compareTo(b.productName));
  //     }
  //
  //     if (list.isEmpty) {
  //       return const Center(child: Text("No active leads found"));
  //     }
  //
  //     return Column(
  //       children: [
  //         /// 🔍 SEARCH
  //         TextField(
  //           controller: searchController,
  //           onChanged: (_) => controller.leadLists.refresh(),
  //           decoration: InputDecoration(
  //             hintText: "Search by Lead ID / Product",
  //             prefixIcon: const Icon(Icons.search),
  //             filled: true,
  //             fillColor: Colors.grey.withOpacity(0.1),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(15),
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //         ),
  //
  //         const SizedBox(height: 15),
  //
  //         /// 📄 LIST
  //         Expanded(
  //           child: ListView.separated(
  //             itemCount: list.length,
  //             separatorBuilder: (_, __) => const SizedBox(height: 10),
  //             itemBuilder: (context, index) {
  //               final tickets = list[index];
  //
  //               final ChatController chatController = Get.find<ChatController>();
  //               //final ticket = filteredTickets[index];
  //
  //
  //               return  Column(
  //                 children: [
  //                   InkWell(
  //                     borderRadius: BorderRadius.circular(12),
  //                     onTap: () => navigateToChat(tickets),
  //
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         // 🔹 Left Icon / Avatar
  //
  //                         const SizedBox(width: 14),
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             CircleAvatar(
  //                               radius: 25,
  //                               backgroundColor: Colors.grey.shade200,
  //                               backgroundImage: tickets.iconUrl.toString() != null && tickets.iconUrl!.isNotEmpty
  //                                   ? NetworkImage("${tickets.iconUrl}",)
  //                                   :  AssetImage(AppImage.Background,) as ImageProvider,
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded( // 🔥 MOST IMPORTANT
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     tickets.productName.toString(),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontWeight: FontWeight.w600,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     tickets.leadId.toString(),
  //                                     maxLines: 2,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.w400,
  //                                         color: Colors.black54,
  //                                         height: 1.3,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //
  //                             const SizedBox(width: 8),
  //
  //                             Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               children: [
  //                                 if ((tickets.unReadUserCount ?? 0) > 0)
  //                                   CircleAvatar(
  //                                                                                         radius: 12,
  //                                                                                         backgroundColor: Colors.red,
  //                                                                                         child: Text(
  //                                                                                           (tickets.unReadUserCount ?? 0) > 99
  //                                                                                               ? "0+"
  //                                                                                               : tickets.unReadUserCount.toString(),
  //                                                                                           style: const TextStyle(
  //                                                                                             fontSize: 11,
  //                                                                                             color: Colors.white,
  //                                                                                             fontWeight: FontWeight.bold,
  //                                                                                           ),
  //                                                                                         ),
  //                                                                                       ),
  //                                 // Text(
  //                                 //   ticket.leadId.toString(),
  //                                 //   style: theme.textTheme.titleMedium?.copyWith(
  //                                 //       fontSize: 15,
  //                                 //       color: Colors.grey,
  //                                 //       fontFamily: FontFamily.roboto
  //                                 //
  //                                 //   ),
  //                                 // ),
  //
  //                                 const SizedBox(height: 4),
  //
  //                                 Text(
  //                                   DateFormat("dd MMM yyyy hh:mm a")
  //                                       .format(DateTime.parse(tickets.assignDate.toString())),
  //                                   style: theme.textTheme.titleMedium?.copyWith(
  //                                     fontSize: 10,
  //                                     color: Colors.grey,
  //                                     fontFamily: FontFamily.roboto,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         )
  //
  //                         //const Icon(Icons.arrow_forward_ios, size: 16),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
  //                     child: const Divider(
  //                       thickness: 0.5,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                 ],
  //               );
  //
  //             },
  //           ),
  //
  //
  //         ),
  //       ],
  //     );
  //   });
  // }

  // Widget _activeCategoryList(ThemeData theme) {
  //   //final AuthController authController = Get.find<AuthController>();
  //
  //   return Obx(() {
  //     authController.searchTrigger.value;
  //
  //     if (authController.isLoadings1.value) {
  //       return const Center(child: CircularProgressIndicator());
  //     }
  //     if (authController.originalLeadLists==null) {
  //       return Center(child: const Text("No Active Leads Found"));
  //     }
  //
  //     /// 🔥 STEP 1: Base list
  //     List<LeadItem> list = authController.originalLeadLists;
  //
  //     /// 🔥 STEP 2: Active filter
  //     list = list.where((lead) =>
  //     lead.leadStatus == "Open" ||
  //         lead.leadStatus == "Pending"
  //     ).toList();
  //
  //     /// 🔥 STEP 3: Search filter
  //     final search = searchController.text.trim().toLowerCase();
  //     if (search.isNotEmpty) {
  //       list = list.where((lead) {
  //         return (lead.leadId ?? "").toLowerCase().contains(search) ||
  //             (lead.productName ?? "").toLowerCase().contains(search);
  //       }).toList();
  //     }
  //
  //     /// 🔥 STEP 4: Sorting
  //     if (selectedFilter == "date") {
  //       list.sort((a, b) =>
  //           (b.creationDate ?? DateTime(0))
  //               .compareTo(a.creationDate ?? DateTime(0)));
  //     } else if (selectedFilter == "id") {
  //       list.sort((a, b) =>
  //           (a.leadId ?? "").compareTo(b.leadId ?? ""));
  //     } else if (selectedFilter == "product") {
  //       list.sort((a, b) =>
  //           (a.productName ?? "").compareTo(b.productName ?? ""));
  //     }
  //
  //     return Column(
  //       children: [
  //         /// 🔍 SEARCH
  //         TextField(
  //           controller: searchController,
  //           onChanged: (_) => authController.searchTrigger.value++,
  //           decoration: InputDecoration(
  //             hintText: "Search by Product / Lead ID",
  //             prefixIcon: const Icon(Icons.search),
  //             filled: true,
  //             fillColor: Colors.grey.withOpacity(0.1),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(15),
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //         ),
  //
  //         const SizedBox(height: 15),
  //
  //         /// 📄 LIST
  //         Expanded(
  //           child: ListView.separated(
  //             itemCount: list.length,
  //             separatorBuilder: (_, __) => const SizedBox(height: 10),
  //             itemBuilder: (context, index) {
  //               final tickets = list[index];
  //
  //               final ChatController chatController = Get.find<ChatController>();
  //               //final ticket = filteredTickets[index];
  //
  //
  //               return  Column(
  //                 children: [
  //                   InkWell(
  //                     borderRadius: BorderRadius.circular(12),
  //                     onTap: () => navigateToChat(tickets),
  //
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         // 🔹 Left Icon / Avatar
  //
  //                         const SizedBox(width: 14),
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             CircleAvatar(
  //                               radius: 25,
  //                               backgroundColor: Colors.grey.shade200,
  //                               backgroundImage: tickets.iconUrl.toString() != null && tickets.iconUrl!.isNotEmpty
  //                                   ? NetworkImage("${tickets.iconUrl}",)
  //                                   :  AssetImage(AppImage.Background,) as ImageProvider,
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded( // 🔥 MOST IMPORTANT
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     tickets.productName.toString(),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontWeight: FontWeight.w600,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     tickets.leadId.toString(),
  //                                     maxLines: 2,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: theme.textTheme.titleMedium?.copyWith(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.w400,
  //                                         color: Colors.black54,
  //                                         height: 1.3,
  //                                         fontFamily: FontFamily.roboto
  //
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //
  //                             const SizedBox(width: 8),
  //
  //                             Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               children: [
  //                                 // if ((tickets.unReadUserCount ?? 0) > 0)
  //                                 //   CircleAvatar(
  //                                 //     radius: 12,
  //                                 //     backgroundColor: Colors.red,
  //                                 //     child: Text(
  //                                 //       (tickets.unReadUserCount ?? 0) > 99
  //                                 //           ? "0+"
  //                                 //           : tickets.unReadUserCount.toString(),
  //                                 //       style: const TextStyle(
  //                                 //         fontSize: 11,
  //                                 //         color: Colors.white,
  //                                 //         fontWeight: FontWeight.bold,
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 if ((tickets.unReadUserCount ?? 0) > 0)
  //                                   CircleAvatar(
  //                                     radius: 12,
  //                                     backgroundColor: Colors.red,
  //                                     child: Text(
  //                                       (tickets.unReadUserCount ?? 0) > 99
  //                                           ? "99+"
  //                                           : tickets.unReadUserCount.toString(),
  //                                       style: const TextStyle(
  //                                         fontSize: 11,
  //                                         color: Colors.white,
  //                                         fontWeight: FontWeight.bold,
  //                                       ),
  //                                     ),
  //                                   ),
  //
  //                                 const SizedBox(height: 4),
  //
  //                                 Text(
  //                                   DateFormat("dd MMM yyyy hh:mm a")
  //                                       .format(DateTime.parse(tickets.assignDate.toString())),
  //                                   style: theme.textTheme.titleMedium?.copyWith(
  //                                     fontSize: 10,
  //                                     color: Colors.grey,
  //                                     fontFamily: FontFamily.roboto,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         )
  //
  //                         //const Icon(Icons.arrow_forward_ios, size: 16),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
  //                     child: const Divider(
  //                       thickness: 0.5,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //
  //                 ],
  //               );
  //
  //             },
  //           ),
  //
  //
  //         ),
  //         _bottomFixedButton(),
  //
  //       ],
  //     );
  //   });
  // }
  Widget _activeCategoryList(ThemeData theme) {
    //final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      authController.searchTrigger.value;

      if (authController.isLoadings1.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (authController.originalLeadLists==null) {
        return Center(child: const Text("No Active Leads Found"));
      }

      /// 🔥 STEP 1: Base list
      List<LeadItem> list = authController.originalLeadLists;

      /// 🔥 STEP 2: Active filter
      list = list.where((lead) =>
      lead.leadStatus == "Open" ||
          lead.leadStatus == "Pending"
      ).toList();

      /// 🔥 STEP 3: Search filter
      final search = searchController.text.trim().toLowerCase();
      if (search.isNotEmpty) {
        list = list.where((lead) {
          return (lead.leadId ?? "").toLowerCase().contains(search) ||
              (lead.productName ?? "").toLowerCase().contains(search);
        }).toList();
      }

      /// 🔥 STEP 4: Sorting
      if (selectedFilter == "date") {
        list.sort((a, b) =>
            (b.creationDate ?? DateTime(0))
                .compareTo(a.creationDate ?? DateTime(0)));
      } else if (selectedFilter == "id") {
        list.sort((a, b) =>
            (a.leadId ?? "").compareTo(b.leadId ?? ""));
      } else if (selectedFilter == "product") {
        list.sort((a, b) =>
            (a.productName ?? "").compareTo(b.productName ?? ""));
      }

      return Column(
        children: [
          /// 🔍 SEARCH
          TextField(
            controller: searchController,
            onChanged: (_) => authController.searchTrigger.value++,
            decoration: InputDecoration(
              hintText: "Search by Product / Lead ID",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// 📄 LIST
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tickets = list[index];

                final ChatController chatController = Get.find<ChatController>();
                //final ticket = filteredTickets[index];


                return  Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => navigateToChat(tickets),

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
                                backgroundImage: tickets.iconUrl.toString() != null && tickets.iconUrl!.isNotEmpty
                                    ? NetworkImage("${tickets.iconUrl}",)
                                    :  AssetImage(AppImage.Background,) as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded( // 🔥 MOST IMPORTANT
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tickets.productName.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: FontFamily.roboto

                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tickets.leadId.toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
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
                                  // if ((tickets.unReadUserCount ?? 0) > 0)
                                  //   CircleAvatar(
                                  //     radius: 12,
                                  //     backgroundColor: Colors.red,
                                  //     child: Text(
                                  //       (tickets.unReadUserCount ?? 0) > 99
                                  //           ? "0+"
                                  //           : tickets.unReadUserCount.toString(),
                                  //       style: const TextStyle(
                                  //         fontSize: 11,
                                  //         color: Colors.white,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ),
                                  if ((tickets.unReadUserCount ?? 0) > 0)
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        (tickets.unReadUserCount ?? 0) > 99
                                            ? "99+"
                                            : tickets.unReadUserCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 4),

                                  Text(
                                    DateFormat("dd MMM yyyy hh:mm a")
                                        .format(DateTime.parse(tickets.assignDate.toString())),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontFamily: FontFamily.roboto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )

                          //const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
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
          _bottomFixedButton(),

        ],
      );
    });
  }

  Widget _closedTicketList(ThemeData theme) {
    //final AuthController authController = Get.find<AuthController>();


    return Obx(() {
      authController.searchTrigger.value;

      if (authController.isLoadings1.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (authController.originalLeadLists==null) {
        return Center(child: const Text("No Close Leads Found"));
      }
      /// 🔥 STEP 1: Base list
      List<LeadItem> list = authController.originalLeadLists;

      /// 🔥 STEP 2: Active filter
      list = list.where((lead) =>
      lead.leadStatus == "Close"
      ).toList();

      /// 🔥 STEP 3: Search filter
      final search = searchController.text.trim().toLowerCase();
      if (search.isNotEmpty) {
        list = list.where((lead) {
          return (lead.leadId ?? "").toLowerCase().contains(search) ||
              (lead.productName ?? "").toLowerCase().contains(search);
        }).toList();
      }

      /// 🔥 STEP 4: Sorting
      if (selectedFilter == "date") {
        list.sort((a, b) =>
            (b.creationDate ?? DateTime(0))
                .compareTo(a.creationDate ?? DateTime(0)));
      } else if (selectedFilter == "id") {
        list.sort((a, b) =>
            (a.leadId ?? "").compareTo(b.leadId ?? ""));
      } else if (selectedFilter == "product") {
        list.sort((a, b) =>
            (a.productName ?? "").compareTo(b.productName ?? ""));
      }

      return Column(
        children: [
          /// 🔍 SEARCH
          TextField(
            controller: searchController,
            onChanged: (_) => authController.searchTrigger.value++,
            decoration: InputDecoration(
              hintText: "Search by Product / Lead ID",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// 📄 LIST
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tickets = list[index];

                final ChatController chatController = Get.find<ChatController>();
                //final ticket = filteredTickets[index];


                return  Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => navigateToChatss(tickets),

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
                                backgroundImage: tickets.iconUrl.toString() != null && tickets.iconUrl!.isNotEmpty
                                    ? NetworkImage("${tickets.iconUrl}",)
                                    :  AssetImage(AppImage.Background,) as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded( // 🔥 MOST IMPORTANT
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tickets.productName.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: FontFamily.roboto

                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tickets.leadId.toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
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
                                  //   ticket.leadId.toString(),
                                  //   style: theme.textTheme.titleMedium?.copyWith(
                                  //       fontSize: 15,
                                  //       color: Colors.grey,
                                  //       fontFamily: FontFamily.roboto
                                  //
                                  //   ),
                                  // ),

                                  const SizedBox(height: 4),

                                  Text(
                                    DateFormat("dd MMM yyyy hh:mm a")
                                        .format(DateTime.parse(tickets.assignDate.toString())),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontFamily: FontFamily.roboto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )

                          //const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
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
      );
    });
  }

}





// Widget _activeCategoryList(ThemeData theme) {
//   return GetBuilder<AuthController>( builder: (controller) {
//     if (controller.isLoading2) {
//     return const Center(child: CircularProgressIndicator(
//       color: Color(0xFF2e448d),
//     ),); }
//     if (controller.productResponse == null) {
//       return const Center(child: Text("No Products Found")); } return
//     Column(
//       children: [
//         TextField(
//           onChanged: (value) {
//             authController.filterProducts(value); // Controller me function
//           },
//           decoration: InputDecoration(
//             hintText: "Search",
//             prefixIcon: const Icon(Icons.search),
//             filled: true,
//             fillColor: Colors.grey.withOpacity(0.1),
//             contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(15),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12),
//         Expanded(
//           child: ListView.separated(
//           padding: const EdgeInsets.all(8),
//           itemCount: authController.productResponse!.data!.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 10),
//           itemBuilder: (context, index) {
//             final Product = authController.productResponse!.data![index];
//             //final item = items[index];
//
//             return Column(
//               children: [
//
//                 InkWell(
//                   borderRadius: BorderRadius.circular(12),
//           /*
//                   onTap: () {
//                     //Get.to(
//                       // WhatsAppChatPage(
//                       //   tittle:  Product.productName.toString(),
//                       // ),
//
//                     // 🟢 Safe Get.to call with proper null checks
//                     final int safeLeadId = int.tryParse(Product.fKOpenLeadID?.toString() ?? "") ?? 0;
//                     final int safeProductId = int.tryParse(Product.pKID?.toString() ?? "") ?? 0;
//
//           // ✅ Safe extraction of companyId and agentId
//
//
//                     final int safeCompanyId = (authController.loginResponse?.data?.isNotEmpty ?? false)
//                         ? authController.loginResponse!.data![0].fKCompanyID ?? 0
//                         : 0;
//
//                     final int safeAgentId = (authController.loginResponse?.data?.isNotEmpty ?? false)
//                         ? authController.loginResponse!.data![0].pKUserID ?? 0
//                         : 0;
//                     final loginData = authController.loginResponse?.data?[0];
//
//           // Safe IDs
//                     final int companyId = loginData?.fKCompanyID ?? 0;  // 1
//                     final int agentId = loginData?.pKUserID ?? 0;       // 226
//           // 🔹 Debug prints before navigation
//                     debugPrint("leadID = '${Product.leadID}'");
//                     debugPrint("fKOpenLeadID = '${Product.fKOpenLeadID}'");
//                     debugPrint("pKID = '${Product.pKID}'");
//
//                     debugPrint("companyId: $safeCompanyId");
//                     debugPrint("agentId: $safeAgentId");
//                     debugPrint("leadId: $safeLeadId");
//                     debugPrint("productId: $safeProductId");
//
//           // 🟢 Navigation
//                     Get.to(
//                           () => WhatsAppChatPage(
//                         title: Product.productName.toString(),
//                         leadId: int.tryParse(Product.fKOpenLeadID?.toString() ?? "") ?? 0,
//                         companyId: companyId,
//                         agentId: agentId,
//                         productId: int.tryParse(Product.pKID?.toString() ?? "") ?? 0,
//                       ),
//                       transition: Transition.rightToLeft,
//                       duration: const Duration(milliseconds: 400),
//                       curve: Curves.easeInOut,
//                     );
//
//                     print("🚀 companyId: $companyId, agentId: $agentId");
//
//                   },
//           */
//                   onTap: () => navigateToChat(Product),
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 🔹 Left Icon / Avatar
//
//                       const SizedBox(width: 14),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundColor: Colors.grey.shade200,
//                             backgroundImage: Product.iconURL.toString() != null && Product.iconURL!.isNotEmpty
//                                 ? NetworkImage(Product.iconURL.toString())
//                                 :  AssetImage(AppImage.Background) as ImageProvider,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded( // 🔥 MOST IMPORTANT
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   Product.productName.toString(),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                       fontFamily: FontFamily.roboto
//
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   Product.productName.toString(),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.black54,
//                                     height: 1.3,
//                                       fontFamily: FontFamily.roboto
//
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 8),
//
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 Product.leadID.toString(),
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   fontSize: 15,
//                                   color: Colors.grey,
//                                     fontFamily: FontFamily.roboto
//
//                                 ),
//                               ),
//
//                               const SizedBox(height: 4),
//
//                               //if (index == 0)
//                                 CircleAvatar(
//                                   radius: 11,
//                                   backgroundColor: const Color(0xFF5a6bb6),
//                                   child:  Text(Product.unReadCount.toString(),
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       )
//
//                       //const Icon(Icons.arrow_forward_ios, size: 16),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 65), // 50 radius + 15 spacing
//                   child: const Divider(
//                     thickness: 0.5,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             );
//           },
//               ),
//         ),
//       ],
//     );});
// }

// const SizedBox(height: 12),
//
// Expanded(
//   child: GridView.builder(
//     padding: const EdgeInsets.all(8),
//     itemCount: items.length,
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,          // 🔥 2 cards per row
//       mainAxisSpacing: 10,
//       crossAxisSpacing: 10,
//       childAspectRatio: 2,      // 🔥 card height control
//     ),
//     itemBuilder: (context, index) {
//       final item = items[index];
//
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: theme.dividerColor,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             item["title"],
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//
//         // child: Stack(
//         //   children: [
//         //     // 🔹 Text Content
//         //
//         //     // 🔴 Badge (top-right)
//         //     if (item["count"] != null)
//         //       Positioned(
//         //         top: 0,
//         //         right: 0,
//         //         child: Container(
//         //           padding: const EdgeInsets.symmetric(
//         //             horizontal: 8,
//         //             vertical: 4,
//         //           ),
//         //           decoration: BoxDecoration(
//         //             color: Colors.red,
//         //             borderRadius: BorderRadius.circular(12),
//         //           ),
//         //           child: Text(
//         //             item["count"].toString(),
//         //             style: const TextStyle(
//         //               color: Colors.white,
//         //               fontSize: 12,
//         //               fontWeight: FontWeight.bold,
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //   ],
//         // ),
//       );
//     },
//   ),
// ),


//   Future<void> navigateToChat(dynamic product) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final loginData = authController.loginResponse?.data?[0];
//     final int agentId =
//         int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;
//     final int leadId = int.tryParse(product.fKOpenLeadID?.toString() ?? "") ?? 0;
//     final int Ticket = product.fKOpenLeadID??0;
//     final int productId = int.tryParse(product.pKID?.toString() ?? "") ?? 0;
//     final int companyId = loginData?.fKCompanyID ?? 0;
//     //final int agentId = authController.loginResponse?.data?[1].pKUserID ?? 0;
//
//     debugPrint("📌 Navigating to WhatsAppChatPage with values:");
//     debugPrint("Ticket: ${product.productName}");
//     debugPrint("Title: ${product.productName}");
//     debugPrint("LeadId: $leadId");
//     debugPrint("ProductId: $productId");
//     debugPrint("CompanyId: $companyId");
//     debugPrint("AgentId: $agentId");
//
// // Navigation
//     Get.to(
//           () => WhatsAppChatPage(
//         title: product.productName.toString(),
//         leadId: leadId,
//         companyId: 1,
//         agentId: 226,
//         productId: productId,
//       ),
//       transition: Transition.rightToLeft,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }


// Widget _filterChip(String title, String value) {
//   final bool isSelected = selectedFilter == value;
//
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         selectedFilter = value;
//       });
//     },
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? Color(0xFF5a6bb6) : Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Color(0xFF5a6bb6)),
//       ),
//       child: Center(
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Color(0xFF5a6bb6),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ),
//   );
// }
