import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PilgrimProfilePage extends StatefulWidget {
  @override
  _PilgrimProfilePageState createState() => _PilgrimProfilePageState();
}

class _PilgrimProfilePageState extends State<PilgrimProfilePage> {
  String name = "";
  String email = "";
  String phone = "";
  String idType = "";
  String idNumber = "";
  String dob = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "Unknown";
      email = prefs.getString("email") ?? "Unknown";
      phone = prefs.getString("phone") ?? "Unknown";
      idType = prefs.getString("idType") ?? "Unknown";
      idNumber = prefs.getString("idNumber") ?? "Unknown";
      dob = prefs.getString("dob") ?? "Unknown";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF0D4A45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.account_circle, size: 100, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            _buildInfoRow("Name:", name),
            _buildInfoRow("Email:", email),
            _buildInfoRow("Phone:", phone),
            _buildInfoRow("ID Type:", idType),
            _buildInfoRow("ID Number:", idNumber),
            _buildInfoRow("Date of Birth:", dob),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
