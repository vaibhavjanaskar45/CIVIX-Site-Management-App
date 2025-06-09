import 'package:civix/SubmitReportPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'project_requests_page.dart';
import 'MakeRequestPage.dart';
import 'ViewRequestsPage.dart';
import 'admin_help_page.dart';
import 'about_us_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailsPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  double _totalSpent = 0.0;
  List<Map<String, dynamic>> _spendingBreakdown = [];
  List<Map<String, dynamic>> _assignedInventory = [];

  @override
  void initState() {
    super.initState();
    _fetchTotalSpent();
    _fetchAssignedInventory();
  }

  void _navigateToModule(String title) {
    Widget? targetPage;

    switch (title) {
      case 'Manage Site Request':
        targetPage = ProjectRequestsPage(
          projectId: widget.projectId,
          projectName: widget.projectName,
        );
        break;
      case 'Raise Request to Admin':
        targetPage = MakeRequestPage(
          projectId: widget.projectId,
        );
        break;
      case 'View Request History':
        targetPage = ViewRequestsPage(
          projectId: widget.projectId,
          projectName: widget.projectName,
        );
        break;
      case 'About us':
        targetPage = AboutUsPage();
        break;
      case 'Help':
        targetPage = AdminHelpPage();
        break;
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong!')));
    }
  }

  IconData _getModuleIcon(String title) {
    switch (title) {
      case 'Manage Site Request':
        return Icons.mark_as_unread_outlined;
      case 'Raise Request to Admin':
        return Icons.engineering;
      case 'View Request History':
        return Icons.assignment_outlined;
      case 'About us':
        return Icons.info_outline;
        case 'Help':
        return Icons.help;
      default:
        return Icons.apps;
    }
  }

  Widget _buildModuleItem(String title) {
    return GestureDetector(
      onTap: () => _navigateToModule(title),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 238, 237, 237),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getModuleIcon(title),
                size: 30,
                color: Color(0xFF014191),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchTotalSpent() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Requests')
          .where('projectId', isEqualTo: widget.projectId)
          .where('status', isEqualTo: 'Approved')
          .get();

      double total = 0.0;
      List<Map<String, dynamic>> breakdown = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double amount = 0.0;

        if (data.containsKey('price')) {
          if (data['price'] is num) {
            amount = (data['price'] as num).toDouble();
          } else if (data['price'] is String) {
            amount = double.tryParse(data['price']) ?? 0.0;
          }
        }

        total += amount;
        breakdown.add({
          'material': data['material'] ?? 'Unknown',
          'amount': amount,
        });
      }

      setState(() {
        _totalSpent = total;
        _spendingBreakdown = breakdown;
      });
    } catch (e) {
      log("❌ Error fetching total spent: $e");
    }
  }

  Future<void> _fetchAssignedInventory() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Inventory').get();
      List<Map<String, dynamic>> inventoryList = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('assignedToProjects') &&
            data['assignedToProjects'] is List) {
          List assignedProjects = data['assignedToProjects'];

          for (var project in assignedProjects) {
            if (project is Map<String, dynamic> &&
                project['projectId'] == widget.projectId) {
              inventoryList.add({
                'inventoryName': data['name'] ?? 'Unknown',
                'quantity': project['quantityAssigned'] ?? 0,
              });
            }
          }
        }
      }

      setState(() {
        _assignedInventory = inventoryList;
      });
    } catch (e) {
      log("❌ Error fetching assigned inventory: $e");
    }
  }

  void _showSpendingBreakdown() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 10),
          contentPadding: EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: EdgeInsets.fromLTRB(24, 10, 24, 20),
          title: Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: Colors.blueAccent, size: 28),
              SizedBox(width: 10),
              Text(
                "Spending Breakdown",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._spendingBreakdown.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['material'],
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[800]),
                          ),
                          Text(
                            "₹${item['amount']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1.5, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        "₹$_totalSpent",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014191),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.close, size: 20, color: Colors.white),
                label: Text(
                  "Close",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> moduleTitles = [
      'Manage Site Request',
      'Raise Request to Admin',
      'View Request History',
      'About us',
      'Help',
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Project: ${widget.projectName}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showSpendingBreakdown,
                child: Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBDEFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Spent:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "₹$_totalSpent",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF014191),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Assigned Inventory
              const Text(
                "Assigned Inventory",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _assignedInventory.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "No inventory assigned yet.",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : Card(
  margin: const EdgeInsets.only(top: 8),
  child: Container(
    decoration: BoxDecoration(
      color: const Color(0xFFBBDEFB),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF90CAF9)),
    ),
    padding: const EdgeInsets.all(8), // optional: adds spacing inside the card
    child: Column(
      children: _assignedInventory.map((item) {
        return ListTile(
          title: Text(
            item['inventoryName'],
            style: const TextStyle(color: Color(0xFF000000)),
          ),
          trailing: Text(
            "Qty: ${item['quantity']}",
            style: const TextStyle(color: Color(0xFF014191)),
          ),
        );
      }).toList(),
    ),
  ),
),

const SizedBox(height: 30),


SizedBox(
  width: double.infinity, // Full width
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmitReportPage(
            projectId: widget.projectId,
            projectName: widget.projectName,
            adminName: "- Admin",
          ),
        ),
      );
    },
    
    label: const Text("Submit Report"),
    icon: const Icon(Icons.send,color: Colors.white),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF014191),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded edges
      ),
    ),
  ),
),





              const SizedBox(height: 30),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.start,
                children: moduleTitles.map((title) {
                  return _buildModuleItem(title);
                }).toList(),
              ),
            ],
          ),
        ),
        


      ),
    );
  }
}
