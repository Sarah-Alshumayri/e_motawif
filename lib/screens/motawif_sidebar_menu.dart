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
import 'task_schedule_page.dart'; // ✅ Import the Task & Schedule Page
import 'tracking_page.dart';

class MotawifSidebarMenu extends StatelessWidget {
  final Color primaryColor = const Color(0xFF0D4A45);

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
          // ✅ Settings Icon
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Motawif!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D4A45),
              ),
            ),
            const SizedBox(height: 20),
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
