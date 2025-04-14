import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'real_time_tracking_page.dart';
import 'health_monitoring_page.dart';

class PilgrimDashboardPage extends StatelessWidget {
  final String pilgrimId;
  final String pilgrimName;

  const PilgrimDashboardPage({
    Key? key,
    required this.pilgrimId,
    required this.pilgrimName,
  }) : super(key: key);

  final Color primaryColor = const Color(0xFF0D4A45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - $pilgrimName",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle("Pilgrim Overview"),
            _buildOverviewCard(),
            const SizedBox(height: 16),
            _buildSectionTitle("Health Status"),
            _buildHealthSnapshot(),
            const SizedBox(height: 16),
            _buildSectionTitle("Last Known Location"),
            _buildLocationCard(context),
            const SizedBox(height: 16),
            _buildSectionTitle("Quick Actions"),
            _buildDashboardTile(
              icon: Icons.chat,
              title: "Chat with $pilgrimName",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      motawifId: "MOTAWIF_ID", // Replace if needed
                      pilgrimId: pilgrimId,
                      pilgrimName: pilgrimName,
                    ),
                  ),
                );
              },
            ),
            _buildDashboardTile(
              icon: Icons.location_on,
              title: "Real-Time Location",
              onTap: () {
                // TODO: Enable this after adding pilgrimId to RealTimeTrackingPage
                _showComingSoon(context, "Real-Time Tracking not set up yet.");
              },
            ),
            _buildDashboardTile(
              icon: Icons.health_and_safety,
              title: "Health Monitoring",
              onTap: () {
                // TODO: Enable this after adding pilgrimId to HealthMonitoringPage
                _showComingSoon(
                    context, "Health Monitoring not connected yet.");
              },
            ),
            _buildDashboardTile(
              icon: Icons.person,
              title: "View Profile",
              onTap: () {
                _showComingSoon(context, "Pilgrim profile page coming soon!");
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Overview Card
  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _overviewRow("👤 Name", pilgrimName),
            const SizedBox(height: 8),
            _overviewRow("🆔 Pilgrim ID", pilgrimId),
            const SizedBox(height: 8),
            _overviewRow("📞 Contact", "+966-5XXXXXXX"),
            const SizedBox(height: 8),
            _overviewRow("🕌 Tent", "Zone A - Tent 12"),
          ],
        ),
      ),
    );
  }

  Widget _overviewRow(String label, String value) {
    return Row(
      children: [
        Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }

  // ❤️ Health Snapshot
  Widget _buildHealthSnapshot() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _vitalMetric("❤️", "HR", "82 bpm"),
            _vitalMetric("🌬️", "O2", "98%"),
            _vitalMetric("🌡️", "Temp", "36.7°C"),
          ],
        ),
      ),
    );
  }

  Widget _vitalMetric(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  // 📍 Location Snapshot
  Widget _buildLocationCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🗺️ Last Seen:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Arafat Entrance Gate - 5 min ago"),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _showComingSoon(context, "Live map not implemented yet.");
              },
              icon: const Icon(Icons.map),
              label: const Text("Track on Map"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Section Title
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  // ⚡ Dashboard Tile
  Widget _buildDashboardTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: Icon(icon, color: primaryColor, size: 28),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  // 🔔 Placeholder Toast
  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
