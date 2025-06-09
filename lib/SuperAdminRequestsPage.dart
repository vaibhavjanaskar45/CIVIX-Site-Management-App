import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminRequestsPage extends StatelessWidget {
  const SuperAdminRequestsPage({super.key});

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await FirebaseFirestore.instance.collection('SuperAdminRequests').doc(requestId).update({
      'status': status,
    });
  }

  Future<String> _fetchProjectName(String projectId) async {
    try {
      DocumentSnapshot projectDoc =
          await FirebaseFirestore.instance.collection('Projects').doc(projectId).get();
      return projectDoc.exists ? projectDoc['name'] ?? "Unknown Project" : "Unknown Project";
    } catch (e) {
      return "Unknown Project";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Super Admin Requests"),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('SuperAdminRequests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var requests = snapshot.data!.docs;
          if (requests.isEmpty) return const Center(child: Text("No requests found."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              String projectId = request['projectId'];

              return FutureBuilder<String>(
                future: _fetchProjectName(projectId),
                builder: (context, projectSnapshot) {
                  String projectName = projectSnapshot.data ?? "Loading...";

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header: Project Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Project: $projectName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF014191),
                                ),
                              ),
                              if (request['status'] == "Pending")
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      tooltip: "Approve",
                                      onPressed: () =>
                                          _updateRequestStatus(request.id, "Approved"),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      tooltip: "Reject",
                                      onPressed: () =>
                                          _updateRequestStatus(request.id, "Rejected"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          /// Name
                          _infoRow("Name", request['name']),

                          /// Amount
                          _infoRow("Amount", "₹${request['amount']}"),

                          /// Reason
                          _infoRow("Reason", request['reason']),

                          /// Description
                          _infoRow("Description", request['description']),

                          /// Status
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
          );
        },
      ),
    );
  }

  /// Helper Widget for Cleaner Info Rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
