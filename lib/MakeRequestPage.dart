import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeRequestPage extends StatefulWidget {
  final String projectId;

  const MakeRequestPage({super.key, required this.projectId});

  @override
  _MakeRequestPageState createState() => _MakeRequestPageState();
}

class _MakeRequestPageState extends State<MakeRequestPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _submitRequest() async {
    if (itemNameController.text.isEmpty ||
        amountController.text.isEmpty ||
        reasonController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('SuperAdminRequests').add({
        'projectId': widget.projectId,
        'name': itemNameController.text,
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'reason': reasonController.text,
        'description': descriptionController.text,
        'status': "Pending",
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Request submitted successfully!"),
        backgroundColor: Colors.green,
      ));

      itemNameController.clear();
      amountController.clear();
      reasonController.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error submitting request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("Raise Inventory Request"),
        backgroundColor: Color(0xFF014191),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Inventory Request Form",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF014191),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),

                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Required Amount",
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: "Purpose / Usage",
                        prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description / Notes",
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.send),
                        label: Text("Submit Request"),
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF014191),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
