import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../Controller/authController.dart';
import '../Controller/chatController.dart';
import '../api/api.dart';
import '../util/appImage.dart';
import '../util/font_family.dart';
import 'Dashboard.dart';


class Closechat extends StatefulWidget {
  final String imageurl;
  final String title;
  final int leadId;
  final String ticket;
  final int companyId;
  final int agentId;
  final int productId;
  const Closechat({super.key,
    required this.title,
    required this.leadId,
    required this.companyId,
    required this.agentId,
    required this.productId,
    required this.ticket,
    required this.imageurl,
  });

  @override
  State<Closechat> createState() => _ClosechatState();
}

class _ClosechatState extends State<Closechat> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> chats = [];
  final ImagePicker _picker = ImagePicker();

  // 🔴 REST API variables
  late ChatController chat; // ✅ declare only

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  @override
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    chat = Get.put(ChatController());
    chat.ticketId.value = "";

    // 👇 Important Fix
    WidgetsBinding.instance.addPostFrameCallback((_) {

      authController.readFunction(
        FKLeadID: widget.leadId.toString(),
        FKUserID: widget.agentId.toString(),
      );

      chat.initChat(
        leadId: widget.leadId,
        companyId: widget.companyId,
        agentId: widget.agentId,
        productId: widget.productId,
      );

    });

    ever(chat.messages, (_) => scrollBottom());
  }
  void scrollBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }
  @override
  // Future<void> pickCameraImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  //   if (image != null) addFileMessage(image.path, "image", true);
  // }
  Future<void> pickCameraImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    await chat.sendFileMultipart(
      filePath: image.path,
      companyId: widget.companyId,
      leadId: widget.leadId,
      agentId: widget.agentId,
      productId: widget.productId,
    );
  }

  // Future<void> pickGalleryImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) addFileMessage(image.path, "image", true);
  // }

  Future<void> pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    await chat.sendFileMultipart(
      filePath: image.path,
      companyId: widget.companyId,
      leadId: widget.leadId,
      agentId: widget.agentId,
      productId: widget.productId,
    );
  }

  // Future<void> pickFile() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles();
  //     if (result != null && result.files.single.path != null) {
  //       final file = result.files.single;
  //       addFileMessage(file.path!, "file", true, name: file.name);
  //     }
  //   } catch (e) {
  //     debugPrint("File picker error: $e");
  //   }
  // }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.single.path == null) return;

    await chat.sendFileMultipart(
      filePath: result.files.single.path!,
      companyId: widget.companyId,
      leadId: widget.leadId,
      agentId: widget.agentId,
      productId: widget.productId,
    );
  }


  void addFileMessage(String path, String type, bool isMe, {String? name}) {
    final chat = {
      "type": type,
      "path": type == "image" ? path : null,
      "name": name,
      "msg": type == "text" ? path : null,
      "isMe": isMe,
      "time": DateTime.now(),
    };
    chats.add(chat);
    setState(() {});
  }

  void openAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              attachItem(Icons.camera_alt, "Camera", pickCameraImage),
              attachItem(Icons.image, "Gallery", pickGalleryImage),
              attachItem(Icons.insert_drive_file, "File", pickFile),
            ],
          ),
        );
      },
    );
  }

  Widget attachItem(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF5a6bb6),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  // =================== TIME FORMAT ===================
  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return "Today";
    if (msgDate == today.subtract(const Duration(days: 1))) return "Yesterday";
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }
  void openImage(String path) {
    Get.dialog(
      Dialog(
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
  String _monthName(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[month - 1];
  }
  bool isLastFromSender = true;
  // =================== MESSAGE BUBBLE ===================
  Widget buildMessage(Map<String, dynamic> chat, {bool isLastFromSender = true}) {
    bool isMe = chat["isMe"];
    DateTime time = chat["time"];
    Color bubbleColor = isMe ? Color(0xffbcc5ed).withOpacity(0.5) : Colors.white.withOpacity(0.5);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat["type"] == "text")
                  Text(chat["msg"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                else if (chat["type"] == "image")
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(chat["path"]!), width: 200),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.blue),
                      const SizedBox(width: 6),
                      Flexible(child: Text(chat["name"] ?? "File", style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(formatTime(time), style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (isLastFromSender)
            Positioned(
              bottom: 6,
              left: isMe ? null : 0,
              right: isMe ? 0 : null,
              child: CustomPaint(
                size: const Size(12, 14),
                painter: BubbleTailPainter(isMe: isMe, color: bubbleColor),
              ),
            ),
        ],
      ),
    );
  }
  RxString ticketId = "".obs;
  @override
  // void dispose() {
  //   pollingTimer?.cancel();
  //   controller.dispose();
  //   super.dispose();
  // }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      resizeToAvoidBottomInset: true,
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
              GestureDetector(onTap: () => Get.to(CategoryListScreen()), child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.imageurl.toString() != null && widget.imageurl!.isNotEmpty
                    ? NetworkImage(widget.imageurl.toString())
                    :  AssetImage(AppImage.Background) as ImageProvider,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),

                  Obx(() => Text(
                    chat.ticketId.value.isEmpty
                        ? "Ticket Id: N/A"
                        : "Ticket Id: ${chat.ticketId.value}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  )),              ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,

          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  AppImage.Chatbackground,
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.12),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),


            Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (chat.loading.value) {
                      return const Center(
                        child: CircularProgressIndicator( color: Color(0xFF2e448d),),
                      );
                    }

                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: chat.messages.length,
                      //  reverse: true,
                      itemBuilder: (_, i) {
                        final m = chat.messages[i];

                        final String fromType = m["FromUserType"]?.toString() ?? "";
                        final bool isMe = fromType == "F";

                        final String msgType =
                            m["MsgType"]?.toString().toUpperCase() ?? "";

                        final String msgText =
                            m["MsgText"]?.toString() ?? "";
                        final String fileName =
                            m["OriginalFileName"]?.toString() ?? "";
                        final String msgDate =
                            m["MsgDate"]?.toString() ?? "";

                        final bool isLastFromSender =
                            i == chat.messages.length - 1 ||
                                chat.messages[i + 1]["FromUserType"] != fromType;

                        final String fileUrl = (m["FileName"] ?? "").toString();

                        final String extension =
                        fileUrl.contains(".")
                            ? fileUrl.split('.').last.toLowerCase()
                            : "";

                        final bool isImage =
                            extension == "jpg" ||
                                extension == "jpeg" ||
                                extension == "png" ||
                                extension == "webp";
                        print("ALL MESSAGES: ${chat.messages}");
                        print("SINGLE MESSAGE: ${chat.messages[i]}");
                        return Align(
                          alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(10),
                                constraints:
                                const BoxConstraints(maxWidth: 260),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color(0xffbcc5ed)
                                      .withOpacity(0.5)
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if (msgType == "TEXT")
                                      Text(
                                        msgText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black, // 👈 force visible
                                        ),
                                      )
                                    //
                                    // if (msgType == "FILE")
                                    // const Text(
                                    // "📎 File Attachment",
                                    // style: TextStyle(color: Colors.black),
                                    // ),


                                    else if (msgType == "FILE")
                                     if (isImage)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: InkWell(
                                            onTap: () {
                                              /// 🔍 Full screen preview
                                              // Get.dialog(
                                              //   Scaffold(
                                              //     backgroundColor: Colors.black,
                                              //     body: SafeArea(
                                              //       child: Stack(
                                              //         children: [
                                              //
                                              //           /// 🔍 Zoomable Image
                                              //           Center(
                                              //             child: InteractiveViewer(
                                              //               minScale: 0.8,
                                              //               maxScale: 4,
                                              //               child: Image.network(
                                              //                 fileUrl,
                                              //                 fit: BoxFit.contain,
                                              //                 errorBuilder: (_, __, ___) => const Icon(
                                              //                   Icons.broken_image,
                                              //                   color: Colors.white,
                                              //                   size: 60,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ),
                                              //
                                              //           /// ❌ Close Button
                                              //           Positioned(
                                              //             top: 10,
                                              //             right: 10,
                                              //             child: InkWell(
                                              //               onTap: () => Get.back(),
                                              //               child: Container(
                                              //                 padding: const EdgeInsets.all(8),
                                              //                 decoration: BoxDecoration(
                                              //                   color: Colors.black.withOpacity(0.6),
                                              //                   shape: BoxShape.circle,
                                              //                 ),
                                              //                 child: const Icon(
                                              //                   Icons.close,
                                              //                   color: Colors.white,
                                              //                   size: 26,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ),
                                              //
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              //   barrierColor: Colors.black87,
                                              //   barrierDismissible: true, // 👈 outside tap se bhi close hoga
                                              // );
                                              //
                                              Get.dialog(
                                                Scaffold(
                                                  backgroundColor: Colors.black,
                                                  body: SafeArea(
                                                    child: Stack(
                                                      children: [

                                                        /// 🔍 Zoomable Image
                                                        Center(
                                                          child: InteractiveViewer(
                                                            minScale: 0.8,
                                                            maxScale: 4,
                                                            child: Image.network(
                                                              fileUrl,
                                                              fit: BoxFit.contain,
                                                              errorBuilder: (_, __, ___) => const Icon(
                                                                Icons.broken_image,
                                                                color: Colors.white,
                                                                size: 60,
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        /// ❌ Close Button
                                                        Positioned(
                                                            top: 10,
                                                            right: 60,
                                                            child:Obx(() {
                                                              // Check if this message is being downloaded
                                                              bool isDownloading = chat.downloadingMsgId.value == m["PKID"];

                                                              return InkWell(
                                                                onTap: isDownloading
                                                                    ? null // disable button while downloading
                                                                    : () async {
                                                                  await chat.downloadAndOpenFile(
                                                                    pkMsgId: m["PKID"],
                                                                    companyId: widget.companyId,
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.all(8),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.6),
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: isDownloading
                                                                      ? SizedBox(
                                                                    width: 26,
                                                                    height: 26,
                                                                    child: CircularProgressIndicator(
                                                                      //value: chat.downloadProgress.value,
                                                                      strokeWidth: 2.5,
                                                                      color: Colors.white,
                                                                    ),
                                                                  )
                                                                      : const Icon(
                                                                    Icons.download,
                                                                    color: Colors.white,
                                                                    size: 26,
                                                                  ),
                                                                ),
                                                              );
                                                            })
                                                        ),
                                                        Positioned(
                                                          top: 10,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: () => Get.back(),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: Colors.black.withOpacity(0.6),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: const Icon(
                                                                Icons.close,
                                                                color: Colors.white,
                                                                size: 26,
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                barrierColor: Colors.black87,
                                                barrierDismissible: true, // 👈 outside tap se bhi close hoga
                                              );

                                            },
                                            child: Image.network(
                                              fileUrl,
                                              width: 220,
                                              height: 220,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (_, child, progress) {
                                                if (progress == null) return child;
                                                return const SizedBox(
                                                  width: 200,
                                                  height: 200,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: Color(0xFF2e448d),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.broken_image, size: 40),
                                              ),
                                            ),
                                          ),
                                        )
                                     else Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         const Icon(
                                           Icons.insert_drive_file,
                                           color: Color(0xFF2e448d),
                                         ),
                                         const SizedBox(width: 6),
                                         Flexible(
                                           child: Text(
                                             fileName.isNotEmpty ? fileName : "File",
                                             style: const TextStyle(
                                               color: Colors.black,
                                               fontWeight: FontWeight.w500,
                                             ),
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                         const SizedBox(width: 6),
                                         Obx(() {
                                           // Check if this file is being downloaded
                                           final isDownloading =
                                               chat.downloadingMsgId.value.toString() == m["PKID"]?.toString();

                                           return InkWell(
                                             onTap: isDownloading
                                                 ? null // Disable button while downloading
                                                 : () async {
                                               await chat.downloadAndOpenFile(
                                                 pkMsgId: m["PKID"],
                                                 companyId: widget.companyId,
                                               );
                                             },
                                             child: Container(
                                               width: 26,
                                               height: 26,
                                               alignment: Alignment.center,
                                               child: isDownloading
                                                   ? const SizedBox(
                                                 width: 20,
                                                 height: 20,
                                                 child: CircularProgressIndicator(
                                                   strokeWidth: 2.5,
                                                   color: Color(0xFF2e448d),
                                                 ),
                                               )
                                                   : const Icon(
                                                 Icons.download,
                                                 color: Color(0xFF2e448d),
                                                 size: 26,
                                               ),
                                             ),
                                           );
                                         }),
                                       ],
                                     )
                                      //  Row(
                                      //   mainAxisSize: MainAxisSize.min,
                                      //   children: [
                                      //     const Icon(Icons.insert_drive_file, color: Color(0xFF2e448d)),
                                      //     const SizedBox(width: 6),
                                      //
                                      //     /// File Name
                                      //     Flexible(
                                      //       child: Text(
                                      //         (m["OriginalFileName"] != null &&
                                      //             m["OriginalFileName"].toString().isNotEmpty)
                                      //             ? m["OriginalFileName"].toString()
                                      //             : "File",
                                      //         style: const TextStyle(
                                      //           color: Colors.black,
                                      //           fontWeight: FontWeight.w500,
                                      //         ),
                                      //         overflow: TextOverflow.ellipsis,
                                      //       ),
                                      //     ),
                                      //
                                      //     const SizedBox(width: 6),
                                      //
                                      //     /// Download Button
                                      //     //  InkWell(
                                      //     //  onTap: () async {
                                      //     //    print(m["PKID"]);
                                      //     //    print(widget.companyId);
                                      //     //  await chat.downloadAndOpenFile(
                                      //     //  pkMsgId: m["PKID"],
                                      //     //  companyId: widget.companyId, // 👈 apna companyId daalo
                                      //     //
                                      //     //  );
                                      //     // // openImage(filePath);
                                      //     //  },
                                      //     //  child: const Icon(Icons.download, color: Color(0xFF2e448d)),
                                      //     //  ),
                                      //     Obx(() => InkWell(
                                      //       onTap: chat.downloadingMsgId.value == m["PKID"]
                                      //           ? null
                                      //           : () async {
                                      //         await chat.downloadAndOpenFile(
                                      //           pkMsgId: m["PKID"],
                                      //           companyId: widget.companyId,
                                      //         );
                                      //       },
                                      //       child: chat.downloadingMsgId.value == m["PKID"]
                                      //           ? const SizedBox(
                                      //         height: 18,
                                      //         width: 18,
                                      //         child: CircularProgressIndicator(
                                      //           strokeWidth: 2,
                                      //           color: Color(0xFF2e448d),
                                      //         ),
                                      //       )
                                      //           : const Icon(
                                      //         Icons.download,
                                      //         color: Color(0xFF2e448d),
                                      //       ),
                                      //     )
                                      //
                                      //     )
                                      //   ],
                                      // ),

                                    else
                                     const SizedBox(height: 4),

                                    Text(
                                      msgDate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isLastFromSender)
                                Positioned(
                                  bottom: 6,
                                  left: isMe ? null : 2,
                                  right: isMe ? 2 : null,
                                  child: CustomPaint(
                                    size: const Size(12, 14),
                                    painter: BubbleTailPainter(
                                      isMe: isMe,
                                      color: isMe
                                          ? const Color(0xffbcc5ed)
                                          .withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),


              ],
            ),

          ],
        ),
      ),
    );
  }

}

class BubbleTailPainter extends CustomPainter {
  final bool isMe;
  final Color color;
  BubbleTailPainter({required this.isMe, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true;
    final path = Path();
    if (isMe) {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 1.1, size.height * 2.5, 0, size.height);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.5, 0, 0);
    } else {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(-size.width * 0.1, size.height * 2.5, size.width, size.height);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
