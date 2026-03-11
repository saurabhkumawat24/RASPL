import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // ✅ Handle background messages if needed
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
   static void handleMessage(RemoteMessage message) {
    final String? route = message.data['route'];

    print('Handling notification tap with route: $route');

    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    } else {
      Get.toNamed('/');
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final String? imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl;

    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/notification_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          contentTitle: message.notification?.title,
          summaryText: message.notification?.body,
        );

        androidDetails = AndroidNotificationDetails(
          'default_channel_id',
          'Default',
          channelDescription: 'Default channel for notifications',
          styleInformation: bigPictureStyleInformation,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
      }
      catch (e) {
        print('Error loading image: $e');
        androidDetails = const AndroidNotificationDetails(
          'default_channel_id',
          'Default',
          channelDescription: 'Default channel for notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
      }
    }
    else {
      androidDetails = const AndroidNotificationDetails(
        'default_channel_id',
        'Default',
        channelDescription: 'Default channel for notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
    }
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'No title',
      message.notification?.body ?? 'No body',
      platformDetails,
      payload: message.data['route'] ?? 'default_route', // ✅ payload mein route
    );
  }
  static Future<void> _onSelectNotification(NotificationResponse response) async {
    final String? route = response.payload;
    print('Notification tapped with route: $route');

    if (route == 'notification_page') {
      print('Navigating to notification page');
      Get.toNamed('/notification_page');
    } else {
      print('Unknown route or default action');
      Get.toNamed('/');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    await showNotification(message);
  }
}