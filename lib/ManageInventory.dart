import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageInventoryScreen extends StatefulWidget {
  @override
  _ManageInventoryScreenState createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends State<ManageInventoryScreen> {
  List<Map<String, dynamic>> _inventoryList = [];
  int _totalInventory = 0;
  int _totalAssigned = 0;
  int _totalAvailable = 0;

  @override
  void initState() {
    super.initState();
    _fetchInventoryData();
  }

  Future<void> _fetchInventoryData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Inventory').get();

      int total = 0, assigned = 0, available = 0;
      List<Map<String, dynamic>> inventoryList = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        int quantity = data['quantity'] ?? 0;
        int availableQty = data['availableQuantity'] ?? 0;
        int assignedQty = quantity - availableQty;

        // Fetch assigned project name
        List assignedProjects = data['assignedToProjects'] ?? [];
        String assignedProjectName = "Not Assigned";

        if (assignedProjects.isNotEmpty) {
          String projectId = assignedProjects.first['projectId'];
          DocumentSnapshot projectDoc = await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .get();

          assignedProjectName =
              projectDoc.exists ? projectDoc['name'] ?? "Unknown Project" : "Unknown Project";
        }

        total += quantity;
        available += availableQty;
        assigned += assignedQty;

        inventoryList.add({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'description': data['description'] ?? '',
          'quantity': quantity,
          'availableQuantity': availableQty,
          'assignedQuantity': assignedQty,
          'assignedProject': assignedProjectName,
        });
      }

      setState(() {
        _totalInventory = total;
        _totalAssigned = assigned;
        _totalAvailable = available;
        _inventoryList = inventoryList;
      });
    } catch (e) {
      print("Error fetching inventory data: $e");
    }
  }

  Future<void> _unassignInventory(String inventoryId) async {
    try {
      DocumentReference inventoryRef =
          FirebaseFirestore.instance.collection('Inventory').doc(inventoryId);

      DocumentSnapshot inventoryDoc = await inventoryRef.get();
      var data = inventoryDoc.data() as Map<String, dynamic>;
      int totalQuantity = data['quantity'] ?? 0;

      await inventoryRef.update({
        'assignedToProjects': [],
        'availableQuantity': totalQuantity,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inventory Unassigned Successfully!")),
      );

      _fetchInventoryData();
    } catch (e) {
      print("Error unassigning inventory: $e");
    }
  }

Widget _buildSummaryCard() {
  return Container(
    width: double.infinity, // full width
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 Inventory Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Total Inventory: $_totalInventory"),
            Text("Assigned: $_totalAssigned", style: TextStyle(color: Colors.red)),
            Text("Available: $_totalAvailable", style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    ),
  );
}


Widget _buildInventoryItem(Map<String, dynamic> item) {
  bool isAssigned = item['assignedProject'] != "Not Assigned";

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['description']),
                Text("Assigned to: ${item['assignedProject']}"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total: ${item['quantity']}", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Assigned: ${item['assignedQuantity']}", style: TextStyle(color: Colors.red)),
                  Text("Available: ${item['availableQuantity']}", style: TextStyle(color: Colors.green)),
                ],
              ),
              if (isAssigned)
                ElevatedButton(
                  onPressed: () => _unassignInventory(item['id']),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF014191),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text("Unassign"),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF014191),
        title: Text("Manage Inventory", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            SizedBox(height: 16),
            Expanded(
              child: _inventoryList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _inventoryList.length,
                      itemBuilder: (context, index) =>
                          _buildInventoryItem(_inventoryList[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
