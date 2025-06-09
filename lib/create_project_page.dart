import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  String? _selectedAdmin;
  List<String> _adminNames = [];

  String? _selectedSupervisor;
  List<String> _supervisorNames = [];

  final Color primaryColor = const Color(0xFF014191);

  @override
  void initState() {
    super.initState();
    _fetchAdminNames();
    _fetchSupervisorNames();
  }

  Future<void> _fetchAdminNames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Admins').get();
      List<String> names =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
      setState(() {
        _adminNames = names;
      });
    } catch (e) {
      log("Error fetching admin names: $e");
    }
  }

  Future<void> _fetchSupervisorNames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('SiteSupervisors').get();
      List<String> names =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
      setState(() {
        _supervisorNames = names;
      });
    } catch (e) {
      log("Error fetching supervisor names: $e");
    }
  }

  Future<void> _saveProject() async {
    if (_selectedAdmin == null || _selectedSupervisor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both admin and supervisor")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Projects').add({
      'name': _projectNameController.text.trim(),
      'overview': _overviewController.text.trim(),
      'estimatedBudget': _budgetController.text.trim(),
      'assignedAdmin': _selectedAdmin,
      'assignedSupervisor': _selectedSupervisor,
      'createdAt': Timestamp.now(),
      'totalExpenditure': 0,
      'currentSpending': 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Project Created Successfully")),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Project", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _projectNameController,
              decoration: _inputDecoration("Project Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _overviewController,
              decoration: _inputDecoration("Project Overview"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              decoration: _inputDecoration("Estimated Budget"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedAdmin,
              decoration: _inputDecoration("Select Admin"),
              items: _adminNames
                  .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAdmin = value),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedSupervisor,
              decoration: _inputDecoration("Select Site Supervisor"),
              items: _supervisorNames
                  .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSupervisor = value),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProject,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Project", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
