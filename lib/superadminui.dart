import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_project_page.dart';
import 'project_details_page.dart';
import 'ManageAdminsPage.dart';
import 'SuperAdminRequestsPage.dart';
import 'AddInventoryPage.dart';
import 'AssignInventoryPage.dart';
import 'ManageInventory.dart';
import 'SuperAdminBudgetPage.dart';
import 'site_supervisors_page.dart';
import 'help_page.dart';
import 'about_us_page.dart';
import 'SuperAdminReportsPage.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  void _navigateToCreateProjectPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProjectPage()),
    );
    if (result != null) {
      setState(() {});
    }
  }

  Future<void> _deleteProject(String projectId) async {
    await FirebaseFirestore.instance.collection('Projects').doc(projectId).delete();
    setState(() {});
  }

  void _navigateToModule(String title) {
    Widget? targetPage;

    switch (title) {
      case 'Admins':
        targetPage = ManageAdminsPage();
        break;
      case 'Site Lead':
        targetPage = SiteSupervisorsPage();
        break;
      case 'Manage Requests':
        targetPage = SuperAdminRequestsPage();
        break;
      case 'Reports':
        targetPage = SuperAdminReportsPage();
     break; 
     case 'Budget':
        targetPage = SuperAdminBudgetPage();
        break;
      case 'Add Inventory':
        targetPage = AddInventoryPage();
        break;
      case 'Assign Inventory':
        targetPage = AssignInventoryPage();
        break;
      case 'Allocated Inventory':
        targetPage = ManageInventoryScreen();
        break;
      case 'Help':
        targetPage = HelpPage();
        break;
      case 'About Civix':
        targetPage = AboutUsPage();
     break;

    }

    if (targetPage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong!')));
    }
  }

  IconData _getModuleIcon(String title) {
    switch (title) {
      case 'Admins':
        return Icons.people;
      case 'Site Lead':
        return Icons.engineering;
      case 'Manage Requests':
        return Icons.assignment_outlined;
      case 'Add Inventory':
        return Icons.inventory;
      case 'Assign Inventory':
        return Icons.assignment_turned_in;
      case 'Allocated Inventory':
        return Icons.inventory_2_outlined;
      case 'Budget':
        return Icons.attach_money;
      case 'Help':
        return Icons.help_outline;
      case 'About Civix':
        return Icons.info_outline;
      case 'Reports':
        return Icons.notifications_active_outlined;  
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

  @override
  Widget build(BuildContext context) {
    List<String> moduleTitles = [
      'Manage Requests',
      'Admins',
      'Site Lead',
      'Reports',
      'Budget',
      'Add Inventory',
      'Assign Inventory',
      'Allocated Inventory',
      'Help',
      'About Civix',
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello Super Admin!'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF014191),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      'SA',
                      style: TextStyle(
                        color: Color(0xFF014191),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Civix',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text('We Build | Manage | Construct', style: TextStyle(fontSize: 14, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('2025-26', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),

            // Create Project Section
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: GestureDetector(
                  onTap: _navigateToCreateProjectPage,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF014191)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 30, color: Color(0xFF014191)),
                        SizedBox(height: 10),
                        Text(
                          'Create a new Project',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Modules Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Text('Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: moduleTitles.map((title) => _buildModuleItem(title)).toList(),
              ),
            ),

            // Project List Section
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Text('Existing Projects :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Projects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var project = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsPage(project: project),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF014191),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project['name'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 16),
                                Text('Admin: ${project['assignedAdmin']}', style: TextStyle(fontSize: 12, color: Colors.white)),
                                Text('Site Supervisor: ${project['assignedSupervisor'] ?? "N/A"}',
                                    style: TextStyle(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProject(doc.id),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
