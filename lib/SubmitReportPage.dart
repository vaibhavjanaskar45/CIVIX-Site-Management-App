import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitReportPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String adminName;

  const SubmitReportPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.adminName,
  });

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final TextEditingController _reportController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a report")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('Reports').add({
        'projectId': widget.projectId,
        'projectName': widget.projectName,
        'adminName': widget.adminName,
        'report': _reportController.text.trim(),
        'date': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully!")),
      );

      _reportController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Report"),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Project: ${widget.projectName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Report By : ${widget.adminName}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reportController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter Report",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
  width: 300,
  child: ElevatedButton.icon(
    onPressed: _isSubmitting ? null : _submitReport,
    icon: const Icon(Icons.send, color: Colors.white),
    label: const Text("Submit"),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF014191),
      foregroundColor: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
