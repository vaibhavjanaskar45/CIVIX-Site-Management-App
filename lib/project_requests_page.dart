import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectRequestsPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectRequestsPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  _ProjectRequestsPageState createState() => _ProjectRequestsPageState();
}

class _ProjectRequestsPageState extends State<ProjectRequestsPage> {
  String _selectedFilter = "Pending";

  Stream<QuerySnapshot> _fetchProjectRequests() {
    return FirebaseFirestore.instance
        .collection('Requests')
        .where('projectId', isEqualTo: widget.projectId)
        .where('status', isEqualTo: _selectedFilter)
        .snapshots();
  }

  Future<void> _updateRequestStatus(String requestId, String status, dynamic price) async {
    try {
      double parsedPrice = 0.0;
      if (price is num) {
        parsedPrice = price.toDouble();
      } else if (price is String) {
        parsedPrice = double.tryParse(price) ?? 0.0;
      }

      await FirebaseFirestore.instance.collection('Requests').doc(requestId).update({
        'status': status,
      });

      if (status == "Approved") {
        DocumentSnapshot projectSnapshot =
            await FirebaseFirestore.instance.collection('Projects').doc(widget.projectId).get();

        double currentBudget = 0.0;
        double totalSpent = 0.0;

        if (projectSnapshot.exists) {
          var data = projectSnapshot.data() as Map<String, dynamic>;
          currentBudget = (data['estimatedBudget'] is num)
              ? (data['estimatedBudget'] as num).toDouble()
              : 0.0;
          totalSpent = (data['totalSpent'] is num)
              ? (data['totalSpent'] as num).toDouble()
              : 0.0;
        }

        await FirebaseFirestore.instance.collection('Projects').doc(widget.projectId).update({
          'estimatedBudget': currentBudget + parsedPrice,
          'totalSpent': totalSpent + parsedPrice,
        });

        setState(() {});
      }
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project Requests"),
        backgroundColor: Color(0xFF014191),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Project: ${widget.projectName}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Text("Filter: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: ["Pending", "Approved", "Rejected"].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchProjectRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var requests = snapshot.data!.docs;
                  if (requests.isEmpty) return Center(child: Text("No requests found."));

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      var request = requests[index];
                      var price = request['price'];

                     return Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 4,
  margin: EdgeInsets.only(bottom: 16),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Project: ",
                style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: widget.projectName,
                style: TextStyle(color: Colors.blue.shade800,fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text("Material: ${request['material']}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),                          
         Text("Quantity: ${request['quantity']}"),
                              Text("Price: ₹${request['price']}"),
                              Text("Contractor: ${request['contractorName'] ?? 'N/A'}"),
                              Text("Reason: ${request['reason'] ?? 'N/A'}"),
        SizedBox(height: 10),
        Row(
          children: [
            Text("Status: ",
                style: TextStyle(fontWeight: FontWeight.w600)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: request['status'] == 'Approved'
                    ? Colors.green.shade100
                    : request['status'] == 'Rejected'
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request['status'],
                style: TextStyle(
                  color: request['status'] == 'Approved'
                      ? Colors.green
                      : request['status'] == 'Rejected'
                          ? Colors.red
                          : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            if (request['status'] == "Pending") ...[
              IconButton(
                icon: Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _updateRequestStatus(request.id, "Approved", price),
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _updateRequestStatus(request.id, "Rejected", 0),
              ),
            ],
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
            ),
          ],
        ),
      ),
    );
  }
}
