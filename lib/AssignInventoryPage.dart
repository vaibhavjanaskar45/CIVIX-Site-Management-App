import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignInventoryPage extends StatefulWidget {
  @override
  _AssignInventoryPageState createState() => _AssignInventoryPageState();
}

class _AssignInventoryPageState extends State<AssignInventoryPage> {
  String? selectedInventoryId;
  String? selectedProjectId;
  final TextEditingController _assignQuantityController = TextEditingController();

  Future<void> _assignInventory() async {
    int assignQuantity = int.tryParse(_assignQuantityController.text.trim()) ?? 0;

    if (selectedInventoryId == null || selectedProjectId == null || assignQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select valid details")),
      );
      return;
    }

    DocumentSnapshot inventoryDoc = await FirebaseFirestore.instance
        .collection('Inventory')
        .doc(selectedInventoryId)
        .get();

    if (!inventoryDoc.exists) return;

    int availableQuantity = inventoryDoc['availableQuantity'];

    if (assignQuantity > availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough inventory available")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Inventory').doc(selectedInventoryId).update({
      'availableQuantity': availableQuantity - assignQuantity,
      'assignedToProjects': FieldValue.arrayUnion([
        {'projectId': selectedProjectId, 'quantityAssigned': assignQuantity}
      ])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Inventory Assigned Successfully!")),
    );

    _assignQuantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Inventory"),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📦 Assign Inventory",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Inventory Dropdown
                  Text("Select Inventory"),
                  const SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Inventory').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DropdownMenuItem<String>> items = snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList();

                      return DropdownButton<String>(
                        value: selectedInventoryId,
                        isExpanded: true,
                        hint: Text("Choose Inventory"),
                        items: items,
                        onChanged: (value) => setState(() => selectedInventoryId = value),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Project Dropdown
                  Text("Select Project"),
                  const SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Projects').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DropdownMenuItem<String>> items = snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList();

                      return DropdownButton<String>(
                        value: selectedProjectId,
                        isExpanded: true,
                        hint: Text("Choose Project"),
                        items: items,
                        onChanged: (value) => setState(() => selectedProjectId = value),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Quantity Field
                  Text("Quantity to Assign"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _assignQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Quantity",
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Assign Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _assignInventory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014191),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: Icon(Icons.check),
                      label: Text("Assign Inventory"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
