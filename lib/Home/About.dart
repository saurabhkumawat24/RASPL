import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
              Text("About", style: const TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),

              // CircleAvatar(radius: 20, backgroundImage: AssetImage(AppImage.AppLogo)),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              Center(
                child: Text(
                  "RIGHTASSURE SERVICES",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "Connecting Agents with Admin Support",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              SizedBox(height: 25),

              Text(
                "About the App",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text(
                "RIGHTASSURE SERVICES is a platform designed to help agents connect directly with administrators regarding available products. The application allows agents to select products, start conversations with the admin, and share files or images for better communication.",
              ),

              SizedBox(height: 20),

              Text(
                "Key Features",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text("• Product selection by agents"),
              Text("• Direct chat with admin"),
              Text("• Image and file sharing in chat"),
              Text("• Active and closed chat management"),
              Text("• Easy communication and support"),

              SizedBox(height: 20),

              Text(
                "Our Mission",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text(
                "Our mission is to simplify communication between agents and administrators, making product discussions faster, easier, and more efficient.",
              ),

              SizedBox(height: 20),

              Text(
                "Contact",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Text(
                "For support or inquiries, please contact us through the application.",
              ),

              SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}