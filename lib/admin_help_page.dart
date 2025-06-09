import 'package:flutter/material.dart';

class AdminHelpPage extends StatelessWidget {
  const AdminHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Help"),
        backgroundColor: Color(0xFF014191),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "📋 Admin Features Guide",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("✅ View Project Details:\nCheck assigned inventory, total spent, and material cost breakdown.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text("📦 Assigned Inventory:\nDisplays inventory items allocated to the project.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text("💰 Total Spent:\nShows the approved spending for a project. Tap to see material-wise breakdown.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text("📨 Manage Supervisor Requests:\nView and approve/reject requests raised by supervisors.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text("📝 Make a Request:\nSend requests directly to the Super Admin for materials or budget.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text("👁️ View Requests:\nTrack the status of all your project’s past and current requests.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Text("❓ Need more help?\nContact the technical team or refer to the official admin manual.", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
