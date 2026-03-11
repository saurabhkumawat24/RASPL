import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    Get.back();
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: 10),
              Text("Terms & Conditions", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22)),

              // CircleAvatar(radius: 20, backgroundImage: AssetImage(AppImage.AppLogo)),
            ],
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "RIGHTASSURE SERVICES",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Last Updated: March 2026",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              Text(
                "1. Acceptance of Terms",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "By using the RIGHTASSURE SERVICES application, you agree to comply with and be bound by these Terms & Conditions.",
              ),

              SizedBox(height: 20),

              Text(
                "2. App Functionality",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "RIGHTASSURE SERVICES allows agents to select products and communicate with the admin through chat.",
              ),

              SizedBox(height: 10),

              Text("Users can:"),
              SizedBox(height: 6),

              Text("• Select products"),
              Text("• Chat with admin"),
              Text("• Share images and files"),
              Text("• Manage active and closed chats"),

              SizedBox(height: 20),

              Text(
                "3. User Responsibilities",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "Users must provide accurate information and avoid sharing harmful or illegal content.",
              ),

              SizedBox(height: 20),

              Text(
                "4. Chat Status",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text("• Active Chat – Ongoing conversation"),
              Text("• Closed Chat – Completed conversation"),

              SizedBox(height: 20),

              Text(
                "5. File & Image Sharing",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "Users may share images or files in chat. The content must not violate any laws or third-party rights.",
              ),

              SizedBox(height: 20),

              Text(
                "6. Privacy",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "Your personal data is processed according to our Privacy Policy.",
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}