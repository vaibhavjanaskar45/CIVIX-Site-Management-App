import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'SupervisorRequestHistoryPage.dart';

class SupervisorRequestPage extends StatefulWidget {
  final String supervisorName;
  final String projectId;
  final String projectName;

  const SupervisorRequestPage({
    super.key,
    required this.supervisorName,
    required this.projectId,
    required this.projectName,
  });

  @override
  _SupervisorRequestPageState createState() => _SupervisorRequestPageState();
}

class _SupervisorRequestPageState extends State<SupervisorRequestPage> {
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contractorNameController = TextEditingController();
  bool _isSubmitting = false;

  /// Submit Request to Firestore
  Future<void> _submitRequest() async {
    if (_materialNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _contractorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (double.tryParse(_priceController.text) == null ||
        int.tryParse(_quantityController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid numeric values for price and quantity")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('Requests').add({
        'projectId': widget.projectId,
        'projectName': widget.projectName,
        'material': _materialNameController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'reason': _reasonController.text.trim(),
        'price': _priceController.text.trim(),
        'contractorName': _contractorNameController.text.trim(),
        'requestedBy': widget.supervisorName,
        'status': 'Pending',
        'requestedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Submitted Successfully")),
      );

      // Clear fields
      _materialNameController.clear();
      _quantityController.clear();
      _reasonController.clear();
      _priceController.clear();
      _contractorNameController.clear();

      Navigator.pop(context); // Navigate back
    } catch (e) {
      log("Error submitting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit request")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raise Request"),
        backgroundColor: const Color(0xFF014191),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Project: ${widget.projectName}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildLabel("Material Name"),
              _buildInputField(_materialNameController, "Enter material name"),

              _buildLabel("Quantity"),
              _buildInputField(_quantityController, "Enter quantity", TextInputType.number),

              _buildLabel("Price"),
              _buildInputField(_priceController, "Enter price", TextInputType.number),

              _buildLabel("Contractor Name"),
              _buildInputField(_contractorNameController, "Enter contractor name"),

              _buildLabel("Reason"),
              _buildInputField(_reasonController, "Enter reason"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send,color: Colors.white,),
                  label: Text(_isSubmitting ? "Submitting..." : "Submit Request"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014191),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : _submitRequest,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text("View Request History"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupervisorRequestHistoryPage(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          supervisorName: widget.supervisorName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Helper Widget for Input Fields
  Widget _buildInputField(
    TextEditingController controller,
    String hintText, [
    TextInputType inputType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
