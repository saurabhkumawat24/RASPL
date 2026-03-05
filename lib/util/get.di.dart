// TODO Implement this library.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/authController.dart';
import '../Controller/chatController.dart';
import '../Repo/authRepo.dart';
import '../Repo/chatRepo.dart';
import '../api/api.dart';
import '../api/api_client.dart';




// Future<void> init() async {
//   // Core
//   final sharedPreferences = await SharedPreferences.getInstance();
//   Get.lazyPut(() => sharedPreferences);
//   Get.lazyPut(() => ApiClient(appBaseUrl: ApiUrls.BASE_URL, sharedPreferences: Get.find()));
//   //Get.lazyPut(() => DashController(Repo: Get.find()));
//   Get.lazyPut(() => AuthController(authRepo: Get.find()));
//
//
//   Get.put(ChatRepo());
//   Get.put(ChatController(), permanent: true);
//   //Get.lazyPut(() => DataRepo( sharedPreferences: Get.find(), apiClient: Get.find()));
//   Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
//
// }

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences, permanent: true);

  // API client
  Get.put(ApiClient(appBaseUrl: ApiUrls.BASE_URL, sharedPreferences: Get.find()), permanent: true);

  // Repos
  Get.put(AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()), permanent: true);
  Get.put(ChatRepo(), permanent: true);

  // Controllers
  Get.put(AuthController(authRepo: Get.find()), permanent: true);
  Get.put(ChatController(), permanent: true);
}