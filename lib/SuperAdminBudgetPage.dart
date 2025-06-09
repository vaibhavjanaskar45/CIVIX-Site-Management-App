import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class SuperAdminBudgetPage extends StatefulWidget {
  const SuperAdminBudgetPage({super.key});

  @override
  _SuperAdminBudgetPageState createState() => _SuperAdminBudgetPageState();
}

class _SuperAdminBudgetPageState extends State<SuperAdminBudgetPage> {
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  /// 🔍 Fetch all projects and their total spending
  Future<void> _fetchProjectsData() async {
    try {
      QuerySnapshot projectsSnapshot =
          await FirebaseFirestore.instance.collection('Projects').get();
      List<Map<String, dynamic>> projectsData = [];

      for (var projectDoc in projectsSnapshot.docs) {
        var projectData = projectDoc.data() as Map<String, dynamic>;
        String projectId = projectDoc.id;
        String projectName = projectData['name'] ?? 'Unnamed Project';

        double totalSpent = 0.0;
        List<Map<String, dynamic>> breakdown = [];

        QuerySnapshot requestsSnapshot = await FirebaseFirestore.instance
            .collection('Requests')
            .where('projectId', isEqualTo: projectId)
            .where('status', isEqualTo: 'Approved')
            .get();

        for (var request in requestsSnapshot.docs) {
          var requestData = request.data() as Map<String, dynamic>;
          double amount = 0.0;

          if (requestData.containsKey('price')) {
            if (requestData['price'] is num) {
              amount = (requestData['price'] as num).toDouble();
            } else if (requestData['price'] is String) {
              amount = double.tryParse(requestData['price']) ?? 0.0;
            }
          }

          totalSpent += amount;
          breakdown.add({'material': requestData['material'] ?? 'Unknown', 'amount': amount});
        }

        projectsData.add({
          'projectId': projectId,
          'projectName': projectName,
          'totalSpent': totalSpent,
          'breakdown': breakdown,
        });
      }

      setState(() {
        _projects = projectsData;
      });
    } catch (e) {
      log("❌ Error fetching project data: $e");
    }
  }

  /// 🏆 Show Spending Breakdown in a Dialog
  void _showSpendingBreakdown(String projectName, List<Map<String, dynamic>> breakdown, double total) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Spending Breakdown - $projectName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var item in breakdown)
                ListTile(
                  title: Text(item['material']),
                  trailing: Text("₹${item['amount']}"),
                ),
              Divider(),
              ListTile(
                title: Text("Total"),
                trailing: Text("₹$total", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Super Admin Budget"), backgroundColor: Color(0xFF014191),foregroundColor: Colors.white,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _projects.isEmpty
            ? Center(child: CircularProgressIndicator()) // Loader while fetching data
            : ListView.builder(
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  var project = _projects[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(project['projectName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text("Total Spent: ₹${project['totalSpent']}"),
                      trailing: Icon(Icons.visibility, color: Colors.blue),
                      onTap: () => _showSpendingBreakdown(project['projectName'], project['breakdown'], project['totalSpent']),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
