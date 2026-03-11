
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Auth/Loginpage.dart';
import 'Home/Dashboard.dart';
import 'Notification.dart';
import 'util/appImage.dart';
import 'util/get.di.dart' as di;

@pragma('vm:entry-point')

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  await di.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkLogin();

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationService.handleMessage(message);
    });


    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        NotificationService.handleMessage(message);
      }
    });
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    // Timer(const Duration(seconds: 2), () {
    //   Get.off(
    //         () => Loginpage(),
    //     transition: Transition.rightToLeft,
    //     duration: const Duration(milliseconds: 400),

    //     curve: Curves.easeInOut,
    //   );
    // });

  }
  Future<void> checkLogin() async {
    final prefs = Get.find<SharedPreferences>();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    String userId = prefs.getString("loginId") ?? "";

    Timer(const Duration(seconds: 2), () {
      if (isLoggedIn && userId.isNotEmpty) {
        Get.offAll(
              () => CategoryListScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 250),
        );

      } else {
        Get.offAll(
              () => Loginpage(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 250),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorObservers: [routeObserver],

      //navigatorKey: NotificationService.navigatorKey,
      title: 'RSAPL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black12,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Center(
            child: Image.asset(
              AppImage.AppLogo,
              height: 100,
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}
