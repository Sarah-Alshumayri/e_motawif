import 'package:e_motawif_new/screens/pilgrim_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'chat_page.dart';
import 'login_page.dart';
import 'services_page.dart';
import 'motawif_sidebar_menu.dart';
import 'pilgrim_dashboard_page.dart';

class StartupSessionPage extends StatefulWidget {
  final String userRole;

  const StartupSessionPage({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  StartupSessionPageState createState() => StartupSessionPageState();
}

class StartupSessionPageState extends State<StartupSessionPage> {
  final Color primaryColor = const Color(0xFF0D4A45);
  List<Map<String, dynamic>> assignedPilgrims = [];
  String? selectedPilgrimId;
  String motawifName = "";

  @override
  void initState() {
    super.initState();
    if (widget.userRole.toLowerCase() == "motawif") {
      fetchAssignedPilgrims();
    } else if (widget.userRole.toLowerCase() == "pilgrim") {
      fetchMotawifNameForPilgrim();
    }
  }

  Future<void> fetchAssignedPilgrims() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? motawifId = prefs.getString('user_id');
    if (motawifId == null) return;

    final response = await http.post(
      Uri.parse('http://10.0.2.2/e_motawif_new/get_assigned_pilgrims.php'),
      body: {'motawif_id': motawifId},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        assignedPilgrims = data
            .map((e) => {
                  'user_id': e['user_id'],
                  'name': e['name'],
                })
            .toList();
      });
      print('✅ Assigned Pilgrims Loaded: $assignedPilgrims');
    } else {
      print('❌ Failed to load pilgrims: ${response.statusCode}');
    }
  }

  Future<void> fetchMotawifNameForPilgrim() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pilgrimId = prefs.getString('user_id');
    if (pilgrimId == null) return;

    final response = await http.post(
      Uri.parse('http://10.0.2.2/e_motawif_new/get_motawif_for_pilgrim.php'),
      body: {'pilgrim_id': pilgrimId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          motawifName = data['motawif_name'];
        });
      }
    } else {
      print('❌ Failed to fetch motawif name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome, ${widget.userRole}!",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PilgrimProfilePage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeMessage(),
            const SizedBox(height: 20),
            if (widget.userRole.toLowerCase() == "motawif")
              _buildPilgrimsList(),
            if (widget.userRole.toLowerCase() == "motawif")
              _buildCreateSessionButton(),
            if (widget.userRole.toLowerCase() == "pilgrim") _buildMotawifInfo(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _navigateToNextPage(context),
                child: Text(
                  widget.userRole.toLowerCase() == "motawif"
                      ? "Go to Dashboard"
                      : "Start My Journey",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Text(
      widget.userRole.toLowerCase() == "pilgrim"
          ? "Welcome! Your Motawif is ${motawifName.isNotEmpty ? motawifName : "Loading..."}."
          : "Welcome back, Motawif. Ready to guide your pilgrims?",
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
        if (assignedPilgrims.isEmpty)
          const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("No pilgrims assigned yet.")),
        ...assignedPilgrims.map((p) => ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(p['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PilgrimDashboardPage(
                      pilgrimId: p['user_id'],
                      pilgrimName: p['name'],
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildCreateSessionButton() {
    return ElevatedButton.icon(
      onPressed: _showChatDropdown,
      icon: const Icon(Icons.chat, color: Colors.white),
      label: const Text("Create New Session",
          style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    );
  }

  void _showChatDropdown() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Start Chat with Pilgrim"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: selectedPilgrimId,
                hint: const Text("Select a pilgrim"),
                isExpanded: true,
                items: assignedPilgrims.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['user_id'],
                    child: Text(p['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPilgrimId = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPilgrimId != null) {
                  final selectedPilgrim = assignedPilgrims
                      .firstWhere((p) => p['user_id'] == selectedPilgrimId);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        motawifId: "MOTAWIF_ID",
                        pilgrimId: selectedPilgrim['user_id'],
                        pilgrimName: selectedPilgrim['name'],
                      ),
                    ),
                  );
                }
              },
              child: const Text("Start Chat"),
            ),
          ],
        );
      },
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
              title: Text(
                motawifName.isNotEmpty ? motawifName : "Loading...",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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

  void _navigateToNextPage(BuildContext context) {
    if (widget.userRole == "pilgrim") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ServicesPage(userRole: widget.userRole),
        ),
      );
    } else if (widget.userRole == "motawif") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MotawifSidebarMenu(),
        ),
      );
    }
  }
}
