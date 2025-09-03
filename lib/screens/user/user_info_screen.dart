import 'package:flutter/material.dart';

class UserInfoScreen extends StatelessWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String email;
  final String gradeLevel;
  final String section;
  final String quarter;

  const UserInfoScreen({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.gradeLevel,
    required this.section,
    required this.quarter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with avatar and name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      fullName[0],
                      style: const TextStyle(fontSize: 32, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Info card section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.badge, 'First Name', firstName),
                      _buildDivider(),
                      _buildInfoTile(Icons.person_outline, 'Middle Name', middleName),
                      _buildDivider(),
                      _buildInfoTile(Icons.person, 'Last Name', lastName),
                      _buildDivider(),
                      _buildInfoTile(Icons.school, 'Grade Level', gradeLevel),
                      _buildDivider(),
                      _buildInfoTile(Icons.class_, 'Section', section),
                      _buildDivider(),
                      _buildInfoTile(Icons.calendar_today, 'Quarter', quarter),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade100),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      height: 8,
      indent: 16,
      endIndent: 16,
    );
  }
}
