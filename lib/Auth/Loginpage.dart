// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
// import '../Controller/authController.dart';
// import '../Home/Dashboard.dart';
// import '../util/appImage.dart';
// import '../util/custom_snackbar.dart';
// import '../util/font_family.dart';
//
// class Loginpage extends StatefulWidget {
//   const Loginpage({super.key});
//
//   @override
//   State<Loginpage> createState() => _LoginpageState();
// }
//
// class _LoginpageState extends State<Loginpage> {
//   bool agree = true;
//
//   @override
//
//   Widget build(BuildContext context) {
//     return GetBuilder<AuthController>(builder: (authController) {
//       return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF4A6CF7),
//                   Color(0xFF6B8CFF),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: Image.asset(
//               AppImage.Background,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 0),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Positioned.fill(
//                       child: Image.asset(
//                         width: 60,
//                         AppImage.appLogo,
//                         fit: BoxFit.fill,
//                       ),
//                     ),
//                     SizedBox(height: 30,),
//                     Text(
//                       "Assure Your Trust with Expert Solutions",
//                       textAlign: TextAlign.end,          // 🔥 right align
//                       textDirection: TextDirection.rtl,  // 🔥 end se start
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         //color: Color(0xFF4A6CF7),
//                         //fontFamily: FontFamily.schyler,
//                         //fontStyle: FontStyle.italic, // optional (safe)
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//
//                     const Text(
//                       "Partner Login",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF4A6CF7),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _textField("Username ", "Enter Username "),
//                     const SizedBox(height: 14),
//
//                     _textField(
//                       "Password",
//                       "Enter Password",
//                       obscure: true,
//                     ),
//                     const SizedBox(height: 14),
//
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: agree,
//                           onChanged: (val) {
//                             setState(() => agree = val ?? false);
//                           },
//                           activeColor: const Color(0xFF4A6CF7),
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "I agree to the processing of Personal data",
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: authController.isLoading1
//                             ? null
//                             : () {
//                           if (!agree) {
//                             showCustomSnackBar(
//                               "Please accept terms & conditions",
//                               isError: true,
//                               getXSnackBar: false,
//                             );
//                             return;
//                           }
//
//                           authController.loginFunction(
//                             loginId: usernameController.text.trim(),
//                             password:
//                             passwordController.text.trim(),
//                             deviceToken: "2323223", // FCM later
//                           );
//                         },
//                         // onPressed: () {
//                         //   Get.to(CategoryListScreen(),
//                         //       transition: Transition.rightToLeft, // animation type
//                         //       duration: const Duration(milliseconds: 400), // animation time
//                         //       curve: Curves.easeInOut, // smooth feel
//                         //        );
//                         // },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF4A6CF7),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         child: const Text(
//                           "Login",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Text(
//                       "Powered by Right Assure Services Pvt. Ltd.",
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//
//                     const SizedBox(height: 50),
//
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );});
//   }
//
//   Widget _textField(String label, String hint, {bool obscure = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           obscureText: obscure,
//           decoration: InputDecoration(
//             hintText: hint,
//             filled: true,
//             fillColor: Colors.grey.shade100,
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
// }
//import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/authController.dart';
import '../Home/Dashboard.dart';
import '../util/appImage.dart';
import '../util/custom_snackbar.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});
  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool agree = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  String? deviceToken;
  bool tokenReady = false;
  void initState() {
    super.initState();
    getDeviceToken();
  }
  Future<void> getDeviceToken() async {
    await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null && token.isNotEmpty) {
      deviceToken = token;
      tokenReady = true;
      setState(() {});
      print("FCM TOKEN = $deviceToken");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF6B8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned.fill(
            child: Image.asset(AppImage.Background, fit: BoxFit.cover),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: GetBuilder<AuthController>(
                  builder: (controller) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AppImage.AppLogo, width: 70),
                        const SizedBox(height: 30),

                        const Text(
                          "Assure Your Trust with Expert Solutions",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),
                        const Text(
                          "Partner Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A6CF7),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _textField(
                          "Username",
                          "Enter Username",
                          controller: usernameController,
                        ),

                        const SizedBox(height: 14),

                        _textField(
                          "Password",
                          "Enter Password",
                          controller: passwordController,
                          obscure: true,
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Checkbox(
                              value: agree,
                              onChanged: (val) =>
                                  setState(() => agree = val ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                "By continuing, I agree to the Terms & Conditions.",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authController.isLoginLoading
                                ? null
                                : () {
                              if (!agree) {
                                showCustomSnackBar(
                                  "Please accept terms & conditions",
                                  isError: true,
                                  getXSnackBar: false,
                                );
                                return;
                              }

                              authController.loginFunction(
                                loginId: usernameController.text.trim(),
                                password: passwordController.text.trim(),
                                deviceToken: deviceToken??"", // FCM later
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6CF7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: authController.isLoginLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Powered by Right Assure Services Pvt. Ltd.",
                          style:
                          TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
      String label,
      String hint, {
        bool obscure = false,
        required TextEditingController controller,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}