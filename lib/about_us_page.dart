import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Civix'),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // Replace the Icon widget with your image here
                  Image.asset(
                    'assets/civixlogo.jpg', // Your image path
                    width: 80, // Adjust the size as needed
                    height: 80, // Adjust the size as needed
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Civix",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014191),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("We Build | Manage | Construct", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildSectionTitle("📌 Our Vision"),
            _buildText("To revolutionize project management in construction through smart, digital solutions that enhance transparency, efficiency, and accountability."),

            _buildSectionTitle("💼 What is Civix?"),
            _buildText("Civix is an all-in-one platform that allows Super Admins, Admins, and Site Supervisors to collaboratively manage construction projects, inventory, budgets, and reports with ease."),

            _buildSectionTitle("🌟 Key Features"),
            _buildBullet("Create and manage multiple projects"),
            _buildBullet("Assign admins and supervisors"),
            _buildBullet("Real-time reporting and progress tracking"),
            _buildBullet("Smart inventory management and allocation"),
            _buildBullet("Secure and role-based access control"),

           _buildSectionTitle("👥 Meet the Team"),
_buildText("Civix is built by a passionate team of developers, architects, and managers who believe in transforming the construction space through technology."),

const SizedBox(height: 10),
const Text("• Developed by: Vaibhav Janaskar", style: TextStyle(fontSize: 16)),
const SizedBox(height: 4),
const Text("• Mentored by: Jyoti Kharade", style: TextStyle(fontSize: 16)),

            _buildSectionTitle("📬 Contact Us"),
            _buildText("Email: contact@civix.com"),
            _buildText("Phone: +91-9876543210"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
