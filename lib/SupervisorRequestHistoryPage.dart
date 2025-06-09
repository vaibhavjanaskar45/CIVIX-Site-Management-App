import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:intl/intl.dart'; // For date formatting

class SupervisorRequestHistoryPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String supervisorName;

  const SupervisorRequestHistoryPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.supervisorName,
  });

  @override
  _SupervisorRequestHistoryPageState createState() =>
      _SupervisorRequestHistoryPageState();
}

class _SupervisorRequestHistoryPageState
    extends State<SupervisorRequestHistoryPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestHistory();
  }

  /// Fetch the material requests for this project
  Future<void> _fetchRequestHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Requests')
          .where('projectId', isEqualTo: widget.projectId)
          .get();

      setState(() {
        _requests = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'material': data['material'],
            'quantity': data['quantity'],
            'price': data['price'],
            'contractorName': data['contractorName'],
            'reason': data['reason'],
            'status': data['status'],
            'requestedAt': data['requestedAt'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      log("Error fetching request history: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.projectName} - Requests"),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _requests.isEmpty
                        ? const Center(child: Text("No requests found for this project."))
                        : ListView.builder(
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${request['material']} (Qty: ${request['quantity']})",
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Price: ₹${request['price']}"),
                                      Text("Contractor: ${request['contractorName']}"),
                                      Text("Reason: ${request['reason']}"),
                                      Text("Date: ${_formatTimestamp(request['requestedAt'])}"),
                                      const SizedBox(height: 8),
                                    






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
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add,color: Colors.white,),
                      label: const Text("Create New Request"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014191),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Go back
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
