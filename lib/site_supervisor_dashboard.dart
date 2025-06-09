import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'SupervisorRequestPage.dart';

class SiteSupervisorDashboard extends StatefulWidget {
  final String supervisorName;

  const SiteSupervisorDashboard({super.key, required this.supervisorName});

  @override
  _SiteSupervisorDashboardState createState() => _SiteSupervisorDashboardState();
}

class _SiteSupervisorDashboardState extends State<SiteSupervisorDashboard> {
  List<Map<String, dynamic>> _assignedProjects = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedProjects();
  }

  Future<void> _fetchAssignedProjects() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Projects')
          .where('assignedSupervisor', isEqualTo: widget.supervisorName)
          .get();

      setState(() {
        _assignedProjects = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'overview': data['overview'],
            'budget': data['estimatedBudget'],
            'admin': data['assignedAdmin'],
            'totalSpent': data['totalSpent'] ?? 0,
          };
        }).toList();
      });
    } catch (e) {
      log("Error fetching assigned projects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("CIVIX SUPERVISOR", style: TextStyle(letterSpacing: 2)),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${widget.supervisorName} 👋",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF014191),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your Assigned Projects",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              _assignedProjects.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Text(
                          "No projects assigned yet.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignedProjects.length,
                      itemBuilder: (context, index) {
                        var project = _assignedProjects[index];
                        return Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF014191),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Overview: ${project['overview']}"),
                                Text("Budget: ₹${project['budget']}"),
                                Text("Admin: ${project['admin']}"),
                                Text("Total Spent: ₹${project['totalSpent']}"),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF014191),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                    label: const Text("View Details"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SupervisorRequestPage(
                                            projectId: project['id'],
                                            projectName: project['name'],
                                            supervisorName: widget.supervisorName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
