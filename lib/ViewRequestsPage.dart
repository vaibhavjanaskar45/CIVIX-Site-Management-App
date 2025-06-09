import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewRequestsPage extends StatelessWidget {
  final String projectId;

  const ViewRequestsPage({super.key, required this.projectId, required String projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Requests"),
        backgroundColor: Color(0xFF014191),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('SuperAdminRequests')
            .where('projectId', isEqualTo: projectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var requests = snapshot.data!.docs;
          if (requests.isEmpty) return Center(child: Text("No requests found."));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];


              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${request['name']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text("Amount: ₹${request['amount']}"),
                      Text("Reason: ${request['reason']}"),
                      Text("Description: ${request['description']}"),
                      SizedBox(height: 8),

                      Row(
                            children: [
                              const Text(
                                "Status: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                label: Text(request['status']),
                                backgroundColor:
                                    request['status'] == "Approved"
                                        ? Colors.green.shade100
                                        : request['status'] == "Rejected"
                                            ? Colors.red.shade100
                                            : Colors.orange.shade100,
                                labelStyle: TextStyle(
                                  color: request['status'] == "Approved"
                                      ? Colors.green
                                      : request['status'] == "Rejected"
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
