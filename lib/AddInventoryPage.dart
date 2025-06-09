import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInventoryPage extends StatefulWidget {
  @override
  _AddInventoryPageState createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  int _totalInventory = 0;
  int _totalAssigned = 0;
  int _totalAvailable = 0;
  List<Map<String, dynamic>> _inventoryList = [];

  final Color primaryColor = Color(0xFF014191);

  @override
  void initState() {
    super.initState();
    _fetchInventoryData();
  }

  Future<void> _deleteInventory(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Inventory').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inventory Deleted Successfully!")),
      );

      _fetchInventoryData();
    } catch (e) {
      print("Error deleting inventory: $e");
    }
  }

  Future<void> _fetchInventoryData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Inventory').get();

      int total = 0;
      int assigned = 0;
      int available = 0;
      List<Map<String, dynamic>> inventoryList = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        int quantity = (data['quantity'] ?? 0) as int;
        int availableQty = (data['availableQuantity'] ?? 0) as int;
        int assignedQty = quantity - availableQty;
        String assignedProject = data['assignedProject'] ?? "Not Assigned";

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
          'assignedProject': assignedProject,
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

  Future<void> _addInventory() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Inventory').add({
      'name': name,
      'description': description,
      'quantity': quantity,
      'availableQuantity': quantity,
      'assignedProject': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Inventory Added Successfully!")),
    );

    _nameController.clear();
    _descriptionController.clear();
    _quantityController.clear();

    _fetchInventoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Inventory"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Inventory Summary Card
            Card(
              elevation: 1,
              color: const Color(0xFFFAFAFA),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("📊 Inventory Summary",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                    SizedBox(height: 8),
                    _buildSummaryRow("Total Inventory", _totalInventory.toString()),
                    _buildSummaryRow("Assigned Inventory", _totalAssigned.toString(),
                        color: Colors.red),
                    _buildSummaryRow("Available Inventory", _totalAvailable.toString(),
                        color: Colors.green),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Add Inventory Form
            Card(
              elevation: 1,
              color: const Color(0xFFFAFAFA),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("➕ Add New Inventory",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Inventory Name"),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Quantity"),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          ),
                      onPressed: _addInventory,
                      child: Text("Add Inventory"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Inventory List
            Text("📦 Inventory List",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _inventoryList.length,
              itemBuilder: (context, index) {
                var item = _inventoryList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Qty: ${item['quantity']}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteInventory(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color ?? primaryColor)),
        ],
      ),
    );
  }
}
