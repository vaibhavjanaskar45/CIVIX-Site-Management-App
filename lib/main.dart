import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'superadminui.dart';
import 'admin_dashboard.dart';
import 'site_supervisor_dashboard.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  String _selectedRole = "Super Admin"; // Default role

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both username and password.";
      });
      _clearErrorMessageAfterDelay();
      return;
    }

    if (_selectedRole == "Super Admin") {
      if (username == "CivixSuperAdmin" && password == "Civix321") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminDashboard()),
        );
        return;
      } else {
        setState(() {
          _errorMessage = "Invalid Super Admin Username or Password";
        });
        _clearErrorMessageAfterDelay();
        return;
      }
    }

    // Firestore collection for Admins and Site Supervisors
    String collectionName = _selectedRole == "Admin" ? "Admins" : "SiteSupervisors";

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        String userName = userDoc['name'] ?? username;

        if (!mounted) return; // Prevents calling setState if widget is disposed

        Widget nextPage = _selectedRole == "Admin"
            ? AdminDashboard(adminName: userName)
            : SiteSupervisorDashboard(supervisorName: userName);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      } else {
        setState(() {
          _errorMessage = "Invalid $_selectedRole Username or Password";
        });
      _clearErrorMessageAfterDelay();

      }


    } catch (e) {
      log("Error fetching $_selectedRole data: $e");
      setState(() {
        _errorMessage = "Error connecting to the database";
      });
      _clearErrorMessageAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/civixlogo.jpg',
                height: 120,
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.white,
                elevation:1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text( 
                        "Sign In",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF014191)),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 246, 252, 255),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                        child: Row(
                          children: [
                            _buildToggleButton("Super Admin"),
                            _buildToggleButton("Admin"),
                            _buildToggleButton("Supervisor"),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_errorMessage.isNotEmpty)
                        Text(_errorMessage,
                            style: TextStyle(fontSize: 15, color: Colors.red)),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF014191),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('LOGIN',
                              style: TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
void _clearErrorMessageAfterDelay() {
  Future.delayed(Duration(seconds: 4), () {
    if (mounted) {
      setState(() {
        _errorMessage = "";
      });
    }
  });
}
  Widget _buildToggleButton(String role) {
    bool isActive = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF014191) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            role,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
