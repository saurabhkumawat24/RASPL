
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppContants
{
  static String appName = "PaguaiShop";
  static String token = "Auth Token";
  static String userDeviceID = "User Device Token";
  static String baseURl = "";


  static String changeDateFormat(String date,String format)
  {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat("MMM d, yyyy - hh:mm a").format(dateTime);

    return DateFormat(format).format(dateTime);
  }
  static bool differentDate(String date)
  {
    DateTime currentTime = DateTime.now();
    DateTime specifiedTime = DateTime.parse(date);

    Duration difference = currentTime.difference(specifiedTime);
    bool isDifferenceLessThan10Minutes = difference.inMinutes.abs() < 10;

    print("Is difference less than 10 minutes: $isDifferenceLessThan10Minutes");

    return difference.inMinutes.abs() < 10;
  }

  static bool currentFood(String date, String startTime, String endTime) {
    // Get the current date in "yyyy-MM-dd" format
    String formattedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

    print("date=>$date");
    print("startTime=>$startTime");
    print("endTime=>$endTime");

    // Combine the current date with the given time
    String startDateTimeString = "$formattedDate $startTime";
    String endDateTimeString = "$formattedDate $endTime";

    DateTime startDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(startDateTimeString);
    DateTime endDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(endDateTimeString);
    DateTime currentDate = DateTime.now();

    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(startDate) || currentDate.isAtSameMomentAs(endDate);
  }


  static String formatDate(String dateString) {
    DateTime inputDate = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(inputDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else {
      return DateFormat.yMMMd().format(inputDate);
    }
  }



}