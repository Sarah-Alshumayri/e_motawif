import 'package:flutter/material.dart';
import 'login_page.dart';
import 'services_page.dart'; // ✅ Import Services Page
import 'motawif_sidebar_menu.dart'; // ✅ Import Sidebar Menu Hub for Motawif

class StartupSessionPage extends StatefulWidget {
  final String userRole;
  final String motawifName;
  final List<String> assignedPilgrims;

  const StartupSessionPage({
    Key? key,
    required this.userRole,
    this.motawifName = "Motawif Ahmed",
    this.assignedPilgrims = const ["Pilgrim A", "Pilgrim B", "Pilgrim C"],
  }) : super(key: key);

  @override
  StartupSessionPageState createState() => StartupSessionPageState();
}

class StartupSessionPageState extends State<StartupSessionPage> {
  final Color primaryColor = const Color(0xFF0D4A45);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text("Welcome, ${widget.userRole}!", // ✅ Role correctly displayed
                style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(),
              const SizedBox(height: 20),
              if (widget.userRole == "motawif")
                _buildPilgrimsList(), // ✅ Ensure Motawif sees only this
              if (widget.userRole == "motawif") _buildCreateSessionButton(),
              if (widget.userRole == "pilgrim") _buildMotawifInfo(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _navigateToNextPage(
                      context), // ✅ Ensure button triggers navigation
                  child: const Text("Start My Journey",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Text(
      widget.userRole == "Pilgrim"
          ? "Welcome! Your Motawif is ${widget.motawifName}."
          : "Welcome! Ready to assist the pilgrims today?",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }

  Widget _buildPilgrimsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Assigned Pilgrims:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...widget.assignedPilgrims.map((pilgrim) => ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(pilgrim,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }

  Widget _buildCreateSessionButton() {
    return ElevatedButton.icon(
      onPressed: _createNewSession,
      icon: const Icon(Icons.group_add, color: Colors.white),
      label: const Text("Create New Session",
          style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    );
  }

  Widget _buildMotawifInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Your Assigned Motawif",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: Text(widget.motawifName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _createNewSession() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController pilgrimController = TextEditingController();
        return AlertDialog(
          title: const Text("Add Pilgrim to Session"),
          content: TextField(
            controller: pilgrimController,
            decoration: const InputDecoration(hintText: "Enter pilgrim name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (pilgrimController.text.isNotEmpty) {
                  setState(() {
                    widget.assignedPilgrims.add(pilgrimController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Updated: Navigates Pilgrims to Service Page & Motawifs to Sidebar Menu Hub
  void _navigateToNextPage(BuildContext context) {
    print("🔹 User Role: ${widget.userRole}"); // ✅ Debugging to check role
    if (widget.userRole == "pilgrim") {
      print("✅ Navigating to ServicesPage");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ServicesPage(userRole: widget.userRole),
        ),
      );
    } else if (widget.userRole == "motawif") {
      print("✅ Navigating to MotawifSidebarMenu");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MotawifSidebarMenu(),
        ),
      );
    } else {
      print("❌ Error: Unknown user role");
    }
  }
}
