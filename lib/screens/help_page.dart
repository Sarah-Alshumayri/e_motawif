import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text("Help & Support", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D4A45),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(icon: Icon(Icons.smartphone), text: "Using App"),
            Tab(icon: Icon(Icons.help), text: "FAQ"),
            Tab(icon: Icon(Icons.settings), text: "Tech Help"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsingAppSection(),
          _buildFAQSection(),
          _buildTechHelpSection(),
        ],
      ),
    );
  }

  /// 📲 Section 1: Using This App (Guides & How-to Tutorials)
  Widget _buildUsingAppSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildHelpCard(Icons.login, "How to Log In",
              "Step-by-step guide to logging in."),
          _buildHelpCard(Icons.location_on, "Tracking Location",
              "Find your assigned location."),
          _buildHelpCard(Icons.people, "Contact Your Motawif",
              "Reach your Motawif easily."),
          _buildHelpCard(Icons.report, "Report Lost Items",
              "How to report lost & found items."),
          _buildHelpCard(
              Icons.sos, "Using the SOS Button", "Emergency assistance guide."),
        ],
      ),
    );
  }

  /// 📖 Section 2: Frequently Asked Questions (Expandable List)
  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildFAQItem("How do I log in?",
              "Use your registered ID (National ID, Passport, or Iqama) and password."),
          _buildFAQItem("What should I do if I get lost?",
              "Use the real-time tracking feature or contact your Motawif."),
          _buildFAQItem("How do I report a lost item?",
              "Go to the 'Report Lost & Found' section and fill out the form."),
          _buildFAQItem("Where can I find my assigned residence?",
              "Check the 'Residency Allocation' tracking service."),
        ],
      ),
    );
  }

  /// 🛠️ Section 3: Technical Help (Troubleshooting & Support)
  Widget _buildTechHelpSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildHelpCard(Icons.wifi_off, "Connectivity Issues",
              "Make sure you have internet access."),
          _buildHelpCard(
              Icons.notifications_off,
              "Not Receiving Notifications?",
              "Enable app notifications in settings."),
          _buildHelpCard(Icons.lock, "Forgot Password?",
              "Reset your password from the login screen."),
          _buildHelpCard(
              Icons.phone, "Need More Help?", "Contact customer support."),
        ],
      ),
    );
  }

  /// 🔹 Widget: Help Card (For Using App & Technical Help Sections)
  Widget _buildHelpCard(IconData icon, String title, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0D4A45)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showDetailsDialog(title, description);
        },
      ),
    );
  }

  /// 🔹 Widget: Expandable FAQ Item
  Widget _buildFAQItem(String question, String answer) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ExpansionTile(
        title:
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(answer, style: const TextStyle(fontSize: 14)),
          )
        ],
      ),
    );
  }

  /// 🏆 Dialog for Help Card Details
  void _showDetailsDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
