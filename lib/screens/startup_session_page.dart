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
import 'package:e_motawif_new/database_helper.dart';
import 'package:geolocator/geolocator.dart';

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
  String motawifId = "";
  String userName = ""; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _loadUserName();
    if (widget.userRole.toLowerCase() == "motawif") {
      fetchAssignedPilgrims();
    } else if (widget.userRole.toLowerCase() == "pilgrim") {
      fetchMotawifNameForPilgrim();
      _startLocationTracking(); // ✅ Starts tracking immediately for Pilgrims
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? widget.userRole;
    });
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
          motawifId = data['motawif_id'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.userRole.toLowerCase() == 'pilgrim'
              ? "Welcome, $userName!"
              : userName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          ? "E-Motawif is here to ensure your Hajj experience is clear, safe, and connected."
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

  void _showChatDropdown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentMotawifId = prefs.getString('user_id');

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
                if (selectedPilgrimId != null && currentMotawifId != null) {
                  final selectedPilgrim = assignedPilgrims
                      .firstWhere((p) => p['user_id'] == selectedPilgrimId);

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        motawifId: currentMotawifId,
                        pilgrimId: selectedPilgrim['user_id'],
                        pilgrimName: selectedPilgrim['name'],
                        userRole: "motawif",
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
            GestureDetector(
              onTap: _showMotawifOptions,
              child: ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blue),
                title: Text(
                  motawifName.isNotEmpty ? motawifName : "Loading...",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
                subtitle: const Text("Tap to interact"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMotawifOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pilgrimId = prefs.getString('user_id');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Motawif Options"),
        content: const Text("What would you like to do?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMotawifSummary();
            },
            child:
                const Text("View Info", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    motawifId: motawifId,
                    pilgrimId: pilgrimId ?? "",
                    pilgrimName: "Motawif",
                    userRole: "pilgrim",
                  ),
                ),
              );
            },
            child:
                const Text("Start Chat", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showMotawifSummary() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/e_motawif_new/get_user_profile.php'),
      body: {'user_id': motawifId},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        final user = json['data'];
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(user['name'],
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D4A45))),
                  const SizedBox(height: 10),
                  _buildProfileRow("📧 Email", user['email'] ?? ''),
                  _buildProfileRow("📞 Phone", user['phone'] ?? ''),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D4A45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: const Text("Close",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        _showErrorDialog("Motawif not found.");
      }
    } else {
      _showErrorDialog("Failed to fetch motawif data.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
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
    if (widget.userRole.toLowerCase() == "pilgrim") {
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

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _startLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _sendLocationToBackend(position.latitude, position.longitude);
      });
    }
  }

  void _sendLocationToBackend(double lat, double lon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('${DatabaseHelper.serverUrl}/save_movement.php'),
      body: {
        'user_id': userId,
        'latitude': lat.toString(),
        'longitude': lon.toString(),
      },
    );

    if (response.statusCode == 200) {
      print("📍 Location saved: ($lat, $lon)");
    } else {
      print("❌ Failed to save location");
    }
  }
}
