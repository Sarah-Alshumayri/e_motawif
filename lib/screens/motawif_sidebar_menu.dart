import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sos_emergency_user.dart';
import 'lost_found_page.dart';
import 'customer_support_page.dart';
import 'startup_session_page.dart';
import 'ritual_guidance_page.dart';
import 'residency_allocation.dart';
import 'real_time_tracking_page.dart';
import 'health_monitoring_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'task_schedule_page.dart';
import 'tracking_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MotawifSidebarMenu extends StatefulWidget {
  @override
  _MotawifSidebarMenuState createState() => _MotawifSidebarMenuState();
}

class _MotawifSidebarMenuState extends State<MotawifSidebarMenu> {
  final Color primaryColor = const Color(0xFF0D4A45);
  List<Map<String, dynamic>> assignedPilgrims = [];
  String? motawifId;

  @override
  void initState() {
    super.initState();
    fetchAssignedPilgrims();
  }

  Future<void> fetchAssignedPilgrims() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    motawifId = prefs.getString('user_id');

    if (motawifId == null) return;

    final url = Uri.parse(
        'http://192.168.56.1/e_motawif_new/get_assigned_pilgrims.php');
    final response = await http.post(url, body: {
      'motawif_id': motawifId!,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        setState(() {
          assignedPilgrims = List<Map<String, dynamic>>.from(jsonData['data']);
        });
        print('✅ Assigned Pilgrims: $assignedPilgrims');
      } else {
        print('❌ Failed to fetch: ${jsonData['message']}');
      }
    } else {
      print('❌ Server error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Motawif Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SettingsPage(userRole: 'motawif')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Welcome, Motawif!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D4A45),
              ),
            ),
            const SizedBox(height: 10),
            if (assignedPilgrims.isNotEmpty) ...[
              const Text(
                "Assigned Pilgrims:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...assignedPilgrims.map((p) => Text("- ${p['name']}")).toList(),
              const SizedBox(height: 20),
            ],
            _buildMenuItem(
              context,
              icon: Icons.map,
              title: "Pilgrim Tracking",
              subtitle: "Monitor and track assigned pilgrims in real-time",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RealTimeTrackingPage(userRole: 'motawif'),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.health_and_safety,
              title: "Health Monitoring",
              subtitle: "Monitor pilgrims' health status and receive alerts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthMonitoringPage(userRole: 'motawif'),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.hotel,
              title: "Residency Management",
              subtitle: "Oversee and update accommodation assignments",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResidencyAllocationPage(userType: 'motawif'),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.sos,
              title: "Emergency Requests",
              subtitle: "Handle SOS alerts from pilgrims",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SOSEmergencyPage()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_active,
              title: "Pilgrim Notifications",
              subtitle: "View urgent messages and updates from pilgrims",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(userRole: 'motawif'),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.schedule,
              title: "Task & Schedule",
              subtitle: "Manage and organize daily responsibilities",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskSchedulePage()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.chat,
              title: "Pilgrim Communication",
              subtitle: "Contact and assist assigned pilgrims",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerSupportPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }
}
