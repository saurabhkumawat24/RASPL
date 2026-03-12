import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Controller/authController.dart';
import '../Controller/chatController.dart';
import '../api/api.dart';
import '../util/appImage.dart';
import '../util/font_family.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WhatsAppChatPage extends StatefulWidget {
  final String imageurl;
  final String title;
  final int leadId;
  final String ticket;
  final int companyId;
  final int agentId;
  final int productId;
  const WhatsAppChatPage({super.key,
    required this.title,
    required this.leadId,
    required this.companyId,
    required this.agentId,
    required this.productId, required this.ticket, required this.imageurl,
  });

  @override
  State<WhatsAppChatPage> createState() => _WhatsAppChatPageState();
}

class _WhatsAppChatPageState extends State<WhatsAppChatPage> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> chats = [];
  final ImagePicker _picker = ImagePicker();

  // 🔴 REST API variables
  late ChatController chat; // ✅ declare only

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  @override

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return File(result!.path);
  }
  Future<void> _openLink(LinkableElement link) async {
    final Uri url = Uri.parse(link.url);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // browser open karega
      );
    }
  }
  void copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Copied",
      "Message copied",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  void initState() {
    super.initState();
    final AuthController authController = Get.find<AuthController>();

    chat = Get.put(ChatController());
    chat.ticketId.value = "";
    chat.leadId.value = widget.leadId;
    // 👇 Important Fix
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.currentOpenLeadId.value = widget.leadId;
      authController.currentUserId.value = widget.agentId.toString();
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
    //authController.currentOpenLeadId.value = 0;
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }
  @override
  // Future<void> pickCameraImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  //
  //   if (image == null) return;
  //
  //   await chat.sendFileMultipart(
  //     filePath: image.path,
  //     companyId: widget.companyId,
  //     leadId: chat.leadId.value,
  //     agentId: widget.agentId,
  //     productId: widget.productId,
  //   );
  // }

  Future<void> pickCameraImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    File compressed = await compressImage(File(image.path));

    await chat.sendFileMultipart(
      filePath: compressed.path,
      companyId: widget.companyId,
      leadId: chat.leadId.value,
      agentId: widget.agentId,
      productId: widget.productId,
    );
  }
  // Future<void> pickGalleryImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   if (image == null) return;
  //
  //   await chat.sendFileMultipart(
  //     filePath: image.path,
  //     companyId: widget.companyId,
  //     leadId: chat.leadId.value,
  //     agentId: widget.agentId,
  //     productId: widget.productId,
  //   );
  // }
  // Future<void> pickGalleryImages() async {
  //   final List<XFile>? images = await _picker.pickMultiImage();
  //
  //   if (images == null || images.isEmpty) return;
  //
  //   Get.dialog(
  //     ImagePreviewDialog(
  //       files: images.map((e) => File(e.path)).toList(),
  //       onSend: (files) async {
  //         for (var file in files) {
  //           await chat.sendFileMultipart(
  //             filePath: file.path,
  //             companyId: widget.companyId,
  //             leadId: chat.leadId.value,
  //             agentId: widget.agentId,
  //             productId: widget.productId,
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }
  Future<void> pickGalleryImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images == null || images.isEmpty) return;

    Get.dialog(
      ImagePreviewDialog(
        files: images.map((e) => File(e.path)).toList(),
        onSend: (files) async {
          for (var file in files) {

            File compressed = await compressImage(file);

            await chat.sendFileMultipart(
              filePath: compressed.path,
              companyId: widget.companyId,
              leadId: chat.leadId.value,
              agentId: widget.agentId,
              productId: widget.productId,
            );
          }
        },
      ),
    );
  }
  // Future<void> pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //
  //   if (result == null || result.files.single.path == null) return;
  //
  //   await chat.sendFileMultipart(
  //     filePath: result.files.single.path!,
  //     companyId: widget.companyId,
  //     leadId: chat.leadId.value,
  //     agentId: widget.agentId,
  //     productId: widget.productId,
  //   );
  // }



  Future<File> compressFileIfNeeded(File file) async {

    int sizeMB = file.lengthSync() ~/ (1024 * 1024);

    if (sizeMB < 5) {
      return file; // 5MB se choti file compress nahi karega
    }

    final dir = await getTemporaryDirectory();
    final zipPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.zip";

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    encoder.addFile(file);

    encoder.close();

    return File(zipPath);
  }
  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result == null) return;

    List<File> files =
    result.paths.whereType<String>().map((p) => File(p)).toList();

    Get.dialog(
      FilePreviewDialog(
        files: files,
        onSend: (selectedFiles) async {
          for (var file in selectedFiles) {

            File compressed = await compressFileIfNeeded(file);

            await chat.sendFileMultipart(
              filePath: compressed.path,
              companyId: widget.companyId,
              leadId: chat.leadId.value,
              agentId: widget.agentId,
              productId: widget.productId,
            );
          }
        },
      ),
    );
  }
  // Future<void> pickFiles() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //   );
  //
  //   if (result == null) return;
  //
  //   List<File> files =
  //   result.paths.whereType<String>().map((p) => File(p)).toList();
  //
  //   Get.dialog(
  //     FilePreviewDialog(
  //       files: files,
  //       onSend: (selectedFiles) async {
  //         for (var file in selectedFiles) {
  //           await chat.sendFileMultipart(
  //             filePath: file.path,
  //             companyId: widget.companyId,
  //             leadId: chat.leadId.value,
  //             agentId: widget.agentId,
  //             productId: widget.productId,
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }



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
              attachItem(Icons.image, "Gallery", pickGalleryImages),
              attachItem(Icons.insert_drive_file, "File", pickFiles),
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
  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
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
              GestureDetector(
                  onTap: () {
                    final AuthController authController = Get.find<AuthController>();

                    authController.readFunction(
                      FKLeadID: widget.leadId.toString(),
                      FKUserID: widget.agentId.toString(),
                    );
                    Get.back();
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.imageurl.toString() != null && widget.imageurl!.isNotEmpty
                    ? NetworkImage(widget.imageurl.toString())
                    :  AssetImage(AppImage.Background) as ImageProvider,
              ),

              // CircleAvatar(radius: 20, backgroundImage: AssetImage(AppImage.AppLogo)),
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

                        final String msgDate =
                            m["MsgDate"]?.toString() ?? "";

                        final String fromUserName =
                            m["FromUserName"]?.toString() ?? "";
                        final String toUserName =
                            m["ToUserName"]?.toString() ?? "";

                        final bool isLastFromSender =
                            i == chat.messages.length - 1 ||
                                chat.messages[i + 1]["FromUserType"] != fromType;

                        final String fileName =
                            m["OriginalFileName"]?.toString() ?? "";

                        final String savedFile =
                            m["SavedFileName"]?.toString() ?? "";

                        // final String fileUrl =
                        //     m["FileURL"]?.toString() ?? "";
                        final String fileUrl =
                        (m["FileURL"] ?? m["FileName"] ?? "").toString();
                        final String extension =
                        savedFile.contains(".")
                            ? savedFile.split(".").last.toLowerCase()
                            : fileUrl.contains(".")
                            ? fileUrl.split(".").last.toLowerCase()
                            : "";

                        final bool isImage =
                        ["jpg", "jpeg", "png", "gif", "webp"]
                            .contains(extension);


                        // final String extension =
                        // fileName.contains(".")
                        //     ? fileName.split('.').last.toLowerCase()
                        //     : "";
                        //
                        // final bool isImage =
                        //     extension == "jpg" ||
                        //         extension == "jpeg" ||
                        //         extension == "png" ||
                        //         extension == "webp";
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
                                  Text(
                                    fromUserName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    if (msgType == "TEXT")
                            GestureDetector(
                            onTap: () {
                          if (msgText.contains("http")) {
                            openUrl(msgText); // link open
                          }
                        },
                        onLongPress: () {
                        Clipboard.setData(ClipboardData(text: msgText));

                        // Get.snackbar(
                        //   "Copied",
                        //   "Message copied",
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   duration: Duration(seconds: 2),
                        // );
                        },
                        child: Text(
                        msgText,
                        style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: msgText.contains("http")
                        ? Colors.blue
                            : Colors.black,
                        decoration: msgText.contains("http")
                        ? TextDecoration.underline
                            : TextDecoration.none,
                        ),
                        ),
                        ),
                        /// ✅ TEXT MESSAGE


                        /// ✅ FILE MESSAGE (Your Existing Code)
                        if (msgType == "FILE")
                        // if (isImage)
                        // Stack(
                        // alignment: Alignment.center,
                        // children: [
                        // GestureDetector(
                        // onTap: () async {
                        // RxDouble rotationAngle = 0.0.obs;
                        //
                        // Get.dialog(
                        // Scaffold(
                        // backgroundColor: Colors.black,
                        // body: SafeArea(
                        // child: Stack(
                        // children: [
                        //
                        // /// 🔍 Zoom + Rotate Image
                        // Center(
                        // child: Obx(() => InteractiveViewer(
                        // minScale: 0.8,
                        // maxScale: 4,
                        // child: Transform.rotate(
                        // angle: rotationAngle.value,
                        // child: Image.network(
                        // fileUrl,
                        // fit: BoxFit.contain,
                        //   errorBuilder: (_, __, ___) => const Icon(
                        // Icons.broken_image,
                        // color: Colors.white,
                        // size: 60,
                        // ),
                        // ),
                        // ),
                        // )),
                        // ),
                        //
                        // /// ⟳ Rotate Button
                        // Positioned(
                        // top: 10,
                        // right: 110,
                        // child: InkWell(
                        // onTap: () {
                        // rotationAngle.value += 1.57; // 90 degree
                        // },
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: const Icon(
                        // Icons.rotate_right,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // ),
                        // ),
                        //
                        // /// ⬇ Download Button
                        // Positioned(
                        // top: 10,
                        // right: 60,
                        // child: Obx(() {
                        // bool isDownloading =
                        // chat.downloadingMsgId.value == m["PKID"];
                        //
                        // return InkWell(
                        // onTap: isDownloading
                        // ? null
                        //     : () async {
                        // await chat.downloadAndOpenFile(
                        // pkMsgId: m["PKID"],
                        // companyId: widget.companyId,
                        // );
                        // },
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: isDownloading
                        // ? const SizedBox(
                        // width: 26,
                        // height: 26,
                        // child: CircularProgressIndicator(
                        // strokeWidth: 2.5,
                        // color: Colors.white,
                        // ),
                        // )
                        //     : const Icon(
                        // Icons.download,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // );
                        // }),
                        // ),
                        //
                        // /// ❌ Close Button
                        // Positioned(
                        // top: 10,
                        // right: 10,
                        // child: InkWell(
                        // onTap: () => Get.back(),
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: const Icon(
                        // Icons.close,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // ),
                        // ),
                        // ],
                        // ),
                        // ),
                        // ),
                        // barrierColor: Colors.black87,
                        // barrierDismissible: true,
                        // );
                        //
                        // },
                        // child: ClipRRect(
                        // borderRadius: BorderRadius.circular(12),
                        // child: Image.network(
                        // fileUrl ?? "",
                        // height: 180,
                        // width: 180,
                        // fit: BoxFit.cover,
                        // errorBuilder: (_, __, ___)=>
                        // const Icon(Icons.broken_image, size: 80),
                        // ),
                        // ),
                        // ),
                        //
                        // // 🔹 Loader overlay
                        // Obx(() {
                        // final isDownloading = chat.downloadingMsgId.value == m["PKID"];
                        // if (!isDownloading) return const SizedBox.shrink();
                        //
                        // return Container(
                        // height: 180,
                        // width: 180,
                        // decoration: BoxDecoration(
                        // color: Colors.black45,
                        // borderRadius: BorderRadius.circular(12),
                        // ),
                        // child: const Center(
                        // child: CircularProgressIndicator(
                        // color: Colors.white,
                        // ),
                        // ),
                        // );
                        // }),
                        // ],
                        // )
                        if (isImage)
                        Stack(
                        alignment: Alignment.center,
                        children: [
                        GestureDetector(
                        onTap: () {

                        /// 🔹 Collect all image messages
                        final imageMessages = chat.messages.where((msg) {
                        final savedFile = msg["SavedFileName"] ?? "";
                        final fileUrl = (msg["FileURL"] ?? msg["FileName"] ?? "").toString();

                        final ext = savedFile.toString().contains(".")
                        ? savedFile.toString().split(".").last.toLowerCase()
                            : fileUrl.contains(".")
                        ? fileUrl.split(".").last.toLowerCase()
                            : "";

                        return ["jpg","jpeg","png","gif","webp"].contains(ext);
                        }).toList();

                        /// 🔹 Current image index
                        final startIndex =
                        imageMessages.indexWhere((img) => img["PKID"] == m["PKID"]);

                        PageController pageController =
                        PageController(initialPage: startIndex);

                        RxInt currentIndex = startIndex.obs;
                        RxDouble rotationAngle = 0.0.obs;

                        // Get.dialog(
                        // Scaffold(
                        // backgroundColor: Colors.black,
                        // body: SafeArea(
                        // child: Stack(
                        // children: [
                        //
                        // /// IMAGE SLIDER
                        // Center(
                        // child:  PageView.builder(
                        // controller: pageController,
                        // itemCount: imageMessages.length,
                        // onPageChanged: (i) {
                        // currentIndex.value = i;
                        // rotationAngle.value = 0;
                        // },
                        // itemBuilder: (_, index) {
                        //
                        // final img = imageMessages[index];
                        // final url =
                        // (img["FileURL"] ?? img["FileName"]).toString();
                        //
                        // return InteractiveViewer(
                        // minScale: 0.8,
                        // maxScale: 4,
                        // child: Transform.rotate(
                        // angle: rotationAngle.value,
                        // child: Image.network(
                        // url,
                        // fit: BoxFit.contain,
                        // errorBuilder: (_, __, ___) => const Icon(
                        // Icons.broken_image,
                        // color: Colors.white,
                        // size: 60,
                        // ),
                        // ),
                        // ),
                        // );
                        // },
                        // )),
                        //
                        //
                        //
                        // /// IMAGE COUNTER
                        // Positioned(
                        // top: 12,
                        // left: 20,
                        // child: Obx(() => Text(
                        // "${currentIndex.value + 1} / ${imageMessages.length}",
                        // style: const TextStyle(
                        // color: Colors.white,
                        // fontSize: 16,
                        // fontWeight: FontWeight.w500,
                        // ),
                        // )),
                        // ),
                        //
                        // /// ROTATE BUTTON
                        // Positioned(
                        // top: 10,
                        // right: 110,
                        // child: InkWell(
                        // onTap: () {
                        // rotationAngle.value += 1.57;
                        // },
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: const Icon(
                        // Icons.rotate_right,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // ),
                        // ),
                        //
                        // /// DOWNLOAD BUTTON
                        // Positioned(
                        // top: 10,
                        // right: 60,
                        // child: Obx(() {
                        //
                        // bool isDownloading =
                        // chat.downloadingMsgId.value ==
                        // imageMessages[currentIndex.value]["PKID"];
                        //
                        // return InkWell(
                        // onTap: isDownloading
                        // ? null
                        //     : () async {
                        //
                        // await chat.downloadAndOpenFile(
                        // pkMsgId:
                        // imageMessages[currentIndex.value]["PKID"],
                        // companyId: widget.companyId,
                        //   fileName: m["OriginalFileName"],
                        //
                        // );
                        // },
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: isDownloading
                        // ? const SizedBox(
                        // width: 26,
                        // height: 26,
                        // child: CircularProgressIndicator(
                        // strokeWidth: 2.5,
                        // color: Colors.white,
                        // ),
                        // )
                        //     : const Icon(
                        // Icons.download,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // );
                        // }),
                        // ),
                        //
                        // /// CLOSE BUTTON
                        // Positioned(
                        // top: 10,
                        // right: 10,
                        // child: InkWell(
                        // onTap: () => Get.back(),
                        // child: Container(
                        // padding: const EdgeInsets.all(8),
                        // decoration: BoxDecoration(
                        // color: Colors.black.withOpacity(0.6),
                        // shape: BoxShape.circle,
                        // ),
                        // child: const Icon(
                        // Icons.close,
                        // color: Colors.white,
                        // size: 26,
                        // ),
                        // ),
                        // ),
                        // ),
                        // ],
                        // ),
                        // ),
                        // ),
                        // barrierColor: Colors.black87,
                        // barrierDismissible: true,
                        // );
                        Get.dialog(
                          Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Stack(
                                children: [
                                  /// 🔹 PageView for multiple images
                                  Center(
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: imageMessages.length,
                                      onPageChanged: (i) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          currentIndex.value = i;
                                          rotationAngle.value = 0;
                                        });
                                      },
                                      itemBuilder: (_, index) {
                                        final img = imageMessages[index];
                                        final url = (img["FileURL"] ?? img["FileName"]).toString();

                                        return InteractiveViewer(
                                          minScale: 0.8,
                                          maxScale: 4,
                                          child: Obx(() => Transform.rotate(
                                            angle: rotationAngle.value,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            ),
                                          )),
                                        );
                                      },
                                    ),
                                  ),

                                  /// 🔹 Image counter
                                  Positioned(
                                    top: 12,
                                    left: 20,
                                    child: Obx(() => Text(
                                      "${currentIndex.value + 1} / ${imageMessages.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                  ),

                                  /// 🔹 Rotate button
                                  Positioned(
                                    top: 10,
                                    right: 110,
                                    child: InkWell(
                                      onTap: () {
                                        rotationAngle.value += 1.57; // rotate 90 degree
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.rotate_right,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// 🔹 Download button
                                  Positioned(
                                    top: 10,
                                    right: 60,
                                    child: Obx(() {
                                      bool isDownloading = chat.downloadingMsgId.value ==
                                          imageMessages[currentIndex.value]["PKID"];

                                      return InkWell(
                                        onTap: isDownloading
                                            ? null
                                            : () async {
                                          await chat.downloadAndOpenFile(
                                            pkMsgId:
                                            imageMessages[currentIndex.value]["PKID"],
                                            companyId: widget.companyId,
                                            fileName: imageMessages[currentIndex.value]
                                            ["OriginalFileName"],
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: isDownloading
                                              ? const SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: CircularProgressIndicator(
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
                                    }),
                                  ),

                                  /// 🔹 Close button
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
                          barrierDismissible: true,
                        );
                        },

                        /// CHAT IMAGE
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                        fileUrl,
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80),
                        ),
                        ),
                        ),

                        /// DOWNLOAD LOADER OVERLAY
                        Obx(() {
                        final isDownloading =
                        chat.downloadingMsgId.value == m["PKID"];
                        if (!isDownloading) return const SizedBox.shrink();

                        return Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                        ),
                        ),
                        );
                        }),
                        ],
                        )
                        //                                     GestureDetector(
                        // onTap: () async {
                        // await chat.downloadAndOpenFile(
                        // pkMsgId: m["PKID"],
                        // companyId: widget.companyId,
                        // );
                        // },
                        // child: ClipRRect(
                        // borderRadius: BorderRadius.circular(12),
                        // child: Image.network(
                        //   fileUrl ?? "",
                        // height: 180,
                        // width: 180,
                        // fit: BoxFit.cover,
                        // errorBuilder: (, _, _) =>
                        // const Icon(Icons.broken_image, size: 80),
                        // ),
                        // ),
                        // )
                        else
                        Obx(() {
                        final isDownloading =
                        chat.downloadingMsgId.value.toString() == m["PKID"]?.toString();

                        return GestureDetector(
                        onTap: isDownloading
                        ? null
                            : () async {
                        await chat.downloadAndOpenFile(
                        pkMsgId: m["PKID"],
                        companyId: widget.companyId,
                        fileName: m["OriginalFileName"],
                        );
                        },
                        child: Row(
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

                        Container(
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
                        ],
                        ),
                        );
                        })
                                    //                                     Row(
                        // mainAxisSize: MainAxisSize.min,
                        // children: [
                        // const Icon(
                        // Icons.insert_drive_file,
                        // color: Color(0xFF2e448d),
                        // ),
                        //
                        // const SizedBox(width: 6),
                        //
                        // Flexible(
                        // child: Text(
                        // fileName.isNotEmpty ? fileName : "File",
                        // style: const TextStyle(
                        // color: Colors.black,
                        // fontWeight: FontWeight.w500,
                        // ),
                        // overflow: TextOverflow.ellipsis,
                        // ),
                        // ),
                        //
                        // const SizedBox(width: 6),
                        //
                        // Obx(() {
                        // final isDownloading =
                        // chat.downloadingMsgId.value.toString() ==
                        // m["PKID"]?.toString();
                        //
                        //
                        //
                        // return InkWell(
                        // onTap: () async {
                        // await chat.downloadAndOpenFile(
                        // pkMsgId: m["PKID"],
                        // companyId: widget.companyId,
                        // );
                        // },
                        // child: const Icon(
                        // Icons.download,
                        // color: Color(0xFF2e448d),
                        // ),
                        // );
                        // }),
                        // ],
                        // )
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     const Icon(Icons.insert_drive_file,
                        //         color: Color(0xFF2e448d)),
                        //     const SizedBox(width: 6),
                        //
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
                        //     Obx(() {
                        //       final isDownloading =
                        //           chat.downloadingMsgId.value?.toString() ==
                        //               m["PKID"]?.toString();
                        //
                        //       return InkWell(
                        //         onTap: isDownloading
                        //             ? null
                        //             : () async {
                        //           await chat.downloadAndOpenFile(
                        //             pkMsgId: m["PKID"],
                        //             companyId: widget.companyId,
                        //           );
                        //         },
                        //         child: const Icon(
                        //           Icons.download,
                        //           color: Color(0xFF2e448d),
                        //         ),
                        //       );
                        //     }),
                        //     // Obx(() => InkWell(
                        //     //   onTap: chat.downloadingMsgId.value ==
                        //     //       m["PKID"]
                        //     //       ? null
                        //     //       : () async {
                        //     //     await chat.downloadAndOpenFile(
                        //     //       pkMsgId: m["PKID"],
                        //     //       companyId: widget.companyId,
                        //     //     );
                        //     //   },
                        //     //   child: chat.downloadingMsgId.value == m["PKID"]
                        //     //       ? const SizedBox(
                        //     //     height: 18,
                        //     //     width: 18,
                        //     //     child:
                        //     //     CircularProgressIndicator(
                        //     //       strokeWidth: 8,
                        //     //       color: Color(0xFF2e448d),
                        //     //     ),
                        //     //   )
                        //     //       : const Icon(
                        //     //     Icons.download,
                        //     //     color: Color(0xFF2e448d),
                        //     //   ),
                        //     // )),
                        //   ],
                        // ),



                        else
                        const SizedBox(height: 4),
                        if (m["isUploading"] == true)
                        Text(
                        "Uploading...",
                        style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        ),
                        )
                        else  if (m["isSending"] == true)
                          Text(
                            "Sending...",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                        Text(
                        m["MsgDate"] ?? "",
                        style: const TextStyle(fontSize: 12),
                        ),
                        // Text(
                        //   msgDate,
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //   ),
                        // ),
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

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  minLines: 1,
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(hintText: "Message", border: InputBorder.none),
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.attach_file), onPressed: openAttachmentSheet),
                              //IconButton(icon: const Icon(Icons.camera_alt), onPressed: pickCameraImage),
                              IconButton(icon: const Icon(Icons.camera_alt), onPressed: pickCameraImage),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // CircleAvatar(
                      //   radius: 24,
                      //   backgroundColor: const Color(0xFF5a6bb6),
                      //   child: IconButton(icon: const Icon(Icons.send, color: Colors.white),
                      //     onPressed: chat.sending.value ? null : send,
                      //   ),
                      // ),
                      widget.leadId=="0"||widget.leadId==0?
                      Obx(() {
                        final isNewLead = chat.ticketId.value.isEmpty;
                        final isSending = chat.isSending.value;
                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF5a6bb6),
                          child: IconButton(
                            icon:  const Icon(Icons.send, color: Colors.white),

                            onPressed: isSending
                                ? null
                                : () async {
                              final text = controller.text.trim();
                              if (text.isEmpty) return;

                              controller.clear();
                              if (isNewLead) {
                                await chat.NewLead(
                                  text: text,
                                  companyId: widget.companyId,
                                  leadId: widget.leadId,
                                  agentId: widget.agentId,
                                  productId: widget.productId,
                                );
                              } else {
                                await chat.sendMessage(
                                  text: text,
                                  companyId: widget.companyId,
                                  leadId: chat.leadId.value,
                                  agentId: widget.agentId,
                                  productId: widget.productId,
                                );
                              }
                            },
                          ),
                        );
                      }):
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF5a6bb6),
                        child: IconButton(
                            icon:  const Icon(Icons.send, color: Colors.white),

                            onPressed: ()async{
                              final text = controller.text.trim();
                              if (text.isEmpty) return;
                              controller.clear();
                              await chat.sendMessage(
                                text: text,
                                companyId: widget.companyId,
                                leadId: widget.leadId,
                                agentId: widget.agentId,
                                productId: widget.productId,
                              );
                            }

                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

}

class ImagePreviewDialog extends StatelessWidget {
  final List<File> files;
  final Function(List<File>) onSend;

  const ImagePreviewDialog({
    super.key,
    required this.files,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {

    final RxList<File> selected = files.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            /// Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [

                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),

                  const SizedBox(width: 8),

                  Obx(() => Text(
                    "${selected.length} Selected",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
            ),

            /// Image Grid
            Expanded(
              child: Obx(() => GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: selected.length,
                itemBuilder: (context, i) {

                  final file = selected[i];

                  return Stack(
                    children: [

                      /// Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      /// Remove Button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            selected.removeAt(i);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )),
            ),

            /// Send Button
            Padding(
              padding: const EdgeInsets.all(15),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF475594),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                    onSend(selected.toList());
                    Get.back();
                  },
                  icon: const Icon(Icons.send,color: Colors.white,),
                  label: Text("Send (${selected.length})",style: TextStyle(color: Colors.white),),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class FilePreviewDialog extends StatelessWidget {
  final List<File> files;
  final Function(List<File>) onSend;

  const FilePreviewDialog({
    super.key,
    required this.files,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog( shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      title: Row( children: [ const Icon(Icons.attach_file, color: Color(0xFF475594)),
        const SizedBox(width: 8), Text( "Selected Files (${files.length})",
          style: const TextStyle( fontWeight: FontWeight.bold, ), ), ], ),
      content: SizedBox( width: double.maxFinite, height: 250,
        child: ListView.separated( itemCount: files.length, separatorBuilder: (_, __) =>
        const Divider(height: 1), itemBuilder: (_, i) { final fileName = files[i].path.split('/').last;
          return ListTile( contentPadding: EdgeInsets.zero, leading: Container( padding: const EdgeInsets.all(8),
            decoration: BoxDecoration( color: Colors.blue.withOpacity(.1), borderRadius: BorderRadius.circular(8),
            ), child: const Icon( Icons.insert_drive_file, color: Color(0xFF475594), ), ),
            title: Text( fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style:
            const TextStyle(fontSize: 14), ), ); }, ), ), actions: [ TextButton(
        style: TextButton.styleFrom( foregroundColor: Colors.grey[700], ),
        onPressed: () => Get.back(), child: const Text("Cancel"), ),
        ElevatedButton.icon( style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF475594),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), ), ),
          onPressed: () { onSend(files); Get.back(); }, icon: const Icon(Icons.send, size: 18,color: Colors.white,),
          label: Text("Send (${files.length})",style: TextStyle(color: Colors.white),), ) ], );
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


// class FilePreviewDialog extends StatelessWidget {
//   final List<File> files;
//   final Function(List<File>) onSend;
//
//   const FilePreviewDialog({
//     super.key,
//     required this.files,
//     required this.onSend,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Selected Files"),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: ListView.builder(
//           itemCount: files.length,
//           itemBuilder: (_, i) {
//             return ListTile(
//               leading: const Icon(Icons.insert_drive_file),
//               title: Text(files[i].path.split('/').last),
//             );
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             onSend(files);
//             Get.back();
//           },
//           child: Text("Send (${files.length})"),
//         )
//       ],
//     );
//   }
// }

// class ImagePreviewDialog extends StatelessWidget {
//   final List<File> files;
//   final Function(List<File>) onSend;
//
//   const ImagePreviewDialog({
//     super.key,
//     required this.files,
//     required this.onSend,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     RxList<File> selected = files.obs;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//
//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.all(10),
//                 gridDelegate:
//                 const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 6,
//                   mainAxisSpacing: 6,
//                 ),
//                 itemCount: files.length,
//                 itemBuilder: (context, i) {
//                   return Stack(
//                     children: [
//                       Image.file(
//                         files[i],
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       ),
//                       Positioned(
//                         top: 4,
//                         right: 4,
//                         child: GestureDetector(
//                           onTap: () {
//                             selected.remove(files[i]);
//                           },
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                     ],
//                   );
//                 },
//               ),
//             ),
//
//             /// Send Button
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: ElevatedButton(
//                 onPressed: () {
//                   onSend(selected);
//                   Get.back();
//                 },
//                 child: Text("Send (${files.length})"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

