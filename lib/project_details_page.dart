import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final formattedDate = project['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a')
            .format((project['createdAt'] as Timestamp).toDate())
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project['name'] ?? 'Project Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF014191),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.title,
                  label: 'Project Name',
                  value: project['name'],
                  isTitleBold: true,
                ),
                _buildDetailRow(
                  icon: Icons.admin_panel_settings,
                  label: 'Assigned Admin',
                  value: project['assignedAdmin'],
                ),
                _buildDetailRow(
                  icon: Icons.supervisor_account,
                  label: 'Supervisor',
                  value: project['assignedSupervisor'],
                ),
                _buildDetailRow(
                  icon: Icons.info_outline,
                  label: 'Project Overview',
                  value: project['overview'] ?? "No description available",
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Created At',
                  value: formattedDate,
                ),
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: 'Estimated Budget',
                  value: '₹${project['estimatedBudget'] ?? "N/A"}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String? value,
    bool isTitleBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF014191)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: value ?? 'N/A',
                    style: TextStyle(
                      fontWeight:
                          isTitleBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
