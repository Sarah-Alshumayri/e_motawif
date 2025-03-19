import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page

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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Redirect to login page when logout is clicked
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

            // ✅ 1. Real-Time Tracking (For Pilgrims)
            _buildMenuItem(
              context,
              icon: Icons.map,
              title: "Pilgrim Tracking",
              subtitle: "Monitor and track assigned pilgrims in real-time",
              onTap: () {},
            ),

            // ✅ 2. Health Monitoring
            _buildMenuItem(
              context,
              icon: Icons.health_and_safety,
              title: "Health Monitoring",
              subtitle: "Monitor pilgrims' health status and receive alerts",
              onTap: () {},
            ),

            // ✅ 3. Residency Management
            _buildMenuItem(
              context,
              icon: Icons.hotel,
              title: "Residency Management",
              subtitle: "Oversee and update accommodation assignments",
              onTap: () {},
            ),

            // ✅ 4. SOS Emergency Requests (Received from Pilgrims)
            _buildMenuItem(
              context,
              icon: Icons.sos,
              title: "Emergency Requests",
              subtitle: "Handle SOS alerts from pilgrims",
              onTap: () {},
            ),

            // ✅ 5. Notifications (Received from Pilgrims)
            _buildMenuItem(
              context,
              icon: Icons.notifications_active,
              title: "Pilgrim Notifications",
              subtitle: "View urgent messages and updates from pilgrims",
              onTap: () {},
            ),

            // ✅ 6. Task & Schedule Management
            _buildMenuItem(
              context,
              icon: Icons.schedule,
              title: "Task & Schedule",
              subtitle: "Manage and organize daily responsibilities",
              onTap: () {},
            ),

            // ✅ 7. Communication with Pilgrims
            _buildMenuItem(
              context,
              icon: Icons.chat,
              title: "Pilgrim Communication",
              subtitle: "Contact and assist assigned pilgrims",
              onTap: () {},
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
