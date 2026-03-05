
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// void showCustomSnackBar(String? message, {bool isError = true, bool getXSnackBar = false}) {
//   if(message != null && message.isNotEmpty) {
//     if(getXSnackBar) {
//       Get.showSnackbar(GetSnackBar(
//         backgroundColor: isError ? Colors.red : Colors.green,
//         message: message,
//         maxWidth: 500,
//         duration: const Duration(seconds: 3),
//         snackStyle: SnackStyle.FLOATING,
//         margin: const EdgeInsets.only(left: 10, right:  10, bottom:  100),
//         borderRadius: 5,
//         isDismissible: true,
//         dismissDirection: DismissDirection.horizontal,
//       ));
//     }else {
//       ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
//         dismissDirection: DismissDirection.horizontal,
//         margin: EdgeInsets.only(
//           right:  10,
//           top: 10, bottom: 10, left: 10,
//         ),
//         duration: const Duration(seconds: 3),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//         content: Text(message, style: TextStyle(color: Colors.white,fontSize: 14)),
//       ));
//     }
//   }
// }

void showCustomSnackBar(
    String? message, {
      bool isError = true,
      bool getXSnackBar = false,
    }) {
  if (message == null || message.isEmpty) return;

  final Color bgColor = isError ? Colors.red.shade600 : Colors.green.shade600;
  final IconData icon = isError ? Icons.error_outline : Icons.check_circle_outline;

  if (getXSnackBar) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        borderRadius: 12,
        boxShadows: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        messageText: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
