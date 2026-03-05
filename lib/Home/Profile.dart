import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth/LoginPage.dart';
import '../Controller/authController.dart';
import '../services/signalr_service.dart';
import '../util/appColor.dart';
import '../util/appImage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  final AuthController authController = Get.find<AuthController>();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }
  String userName = '';
  String imageUrl = '';
  String websiteUrl = '';
  String LoginId = '';
  // ================= API CALL =================
  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    final int agentId = int.tryParse(prefs.getString("UserID") ?? "0") ?? 0;

    final int companyId = int.tryParse(prefs.getString("FKCompanyID") ?? "0") ?? 0;

    setState(() {
      userName = prefs.getString("Name") ?? '';
      imageUrl = prefs.getString("ImageURL") ?? '';
      websiteUrl = prefs.getString("URL") ?? '';
      LoginId = prefs.getString("loginId") ?? '';
    });

    if (!mounted) return;

    authController.productFunction(
      PKUserID: agentId.toString(),
      FKCompanyID: companyId.toString(),
    );

  }
  @override
  Widget build(BuildContext context) {
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
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 10,),
            GestureDetector(
                onTap: (){
                  Get.back();
                },
                child: Icon(CupertinoIcons.arrow_left,color: Colors.white,)),
            SizedBox(width: 10,),
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),
          ],
        ),

      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: Stack(
                                children:[
                                  Container(
                                    height:120,

                                    child: CachedNetworkImage(
                                      imageUrl:"",
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,

                                            // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => CircleAvatar(radius: 120,backgroundColor: Colors.white,
                                        child: Icon(Icons.person,size: 40,color: Colors.black,),),
                                      errorWidget: (context, url, error) =>  CircleAvatar(radius: 120,backgroundColor: Colors.white,
                                        child: Icon(Icons.person,size: 40,color: Colors.black),),
                                    ),/*Image.asset(AppImage.userImageImage, height: 54,fit: BoxFit.fill,)*/),

                                ] ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30,),
                SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      settingItem(
                        icon: Icons.edit,
                        title: "Update Profile",
                        onTap: () {
                          //Get.to(() => UpdateProfileScreen());
                        },
                      ),
                      Divider(),

                      settingItem(
                        icon: Icons.info_outline,
                        title: "About Us",
                        onTap: () {
                          //Get.to(() => AboutUsScreen());
                        },
                      ),
                      Divider(),

                      settingItem(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {
                         // Get.to(() => PrivacyPolicyScreen());
                        },
                      ),
                      Divider(),

                      settingItem(
                        icon: Icons.logout,
                        title: "Logout",
                        iconColor: Colors.black,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  "Confirm Logout",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                actions: [
                                  /// ❌ NO
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "No",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A6CF7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final AuthController authController = Get.find<AuthController>();

                                      await Get.find<AuthController>().logout();
                                    // //  Get.delete<SignalRService>();
                                    //   final prefs = Get.find<SharedPreferences>();
                                    //   prefs.remove("loginId");
                                    //   prefs.setBool("isLoggedIn", false);
                                    //
                                    //  // authController.clearSharedData();
                                    //   Get.offAll(() => Loginpage());

                                    },
                                    child: const Text("Yes",style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              );
                            },
                          );
                        },

                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
    );
  }
  Widget settingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color iconColor = Colors.black,
  })
  {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

}


