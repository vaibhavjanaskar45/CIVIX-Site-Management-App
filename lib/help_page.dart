import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Welcome to Civix App"),
          _buildText("This app is designed for Super Admins to efficiently manage construction projects, inventory, budgets, and team roles."),

          _buildSectionTitle("🔨 Create a New Project"),
          _buildText("Tap the 'Create a new Project' button to add a new project. Fill in all the required details such as project name, location, and assigned admin."),

          _buildSectionTitle("📋 View Existing Projects"),
          _buildText("Below the modules, you’ll see all existing projects. Tap on any project to view detailed information."),

          _buildSectionTitle("🗑 Delete Projects"),
          _buildText("Click the red trash icon beside any project to delete it permanently."),

          _buildSectionTitle("📁 Modules"),
          _buildText("Modules are shortcuts to manage different aspects of the app:"),
          _buildBullet("Reports - View daily activity reports"),
          _buildBullet("Admins - Manage admin users"),
          _buildBullet("Site Lead - Manage site supervisors"),
          _buildBullet("Budget - Set and review project budgets"),
          _buildBullet("Add Inventory - Add new inventory items"),
          _buildBullet("Assign Inv.. - Assign inventory to projects"),
          _buildBullet("Allocated Inv.. - See what's already assigned"),

          _buildSectionTitle("👥 User Roles"),
          _buildBullet("Super Admin - Has full control over all features"),
          _buildBullet("Admin - Can manage assigned projects"),
          _buildBullet("Site Supervisor - Views and reports from site"),

          _buildSectionTitle("📞 Need More Help?"),
          _buildText("Reach out to the Civix Support Team via email at support@civix.com or call 1800-XXX-XXXX."),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
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
