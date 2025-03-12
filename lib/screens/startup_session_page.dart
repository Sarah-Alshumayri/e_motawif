import 'package:flutter/material.dart';

class StartupSessionPage extends StatefulWidget {
  final String userRole;
  final String motawifName; // Added Motawif information for Pilgrims
  final List<String>
      assignedPilgrims; // Added list of assigned pilgrims for Motawif

  const StartupSessionPage({
    Key? key,
    required this.userRole,
    this.motawifName = "Motawif Ahmed", // Example Motawif name
    this.assignedPilgrims = const [
      "Pilgrim A",
      "Pilgrim B",
      "Pilgrim C"
    ], // Example pilgrims
  }) : super(key: key);

  @override
  StartupSessionPageState createState() => StartupSessionPageState();
}

class StartupSessionPageState extends State<StartupSessionPage> {
  final Color primaryColor = const Color(0xFF0D4A45);
  late String userRole;
  bool enableGuidance = false;
  bool enableNotifications = false;
  bool enableTracking = false;
  bool isAvailable = true;
  String selectedLanguage = "English";

  List<String> sessionPilgrims = [];

  @override
  void initState() {
    super.initState();
    userRole = widget.userRole;
    sessionPilgrims = List.from(widget.assignedPilgrims);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome, $userRole!",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userRole == "Pilgrim"
                    ? "Welcome! Your Motawif is ${widget.motawifName}."
                    : "Welcome! Ready to assist the pilgrims today?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              const SizedBox(height: 20),
              if (userRole == "Motawif") ...[
                _buildPilgrimsList(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _createNewSession,
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  label: const Text("Create New Session",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
              ],
              if (userRole == "Pilgrim") ...[
                _buildMotawifInfo(),
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _navigateToDashboard(context),
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

  Widget _buildPilgrimsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Assigned Pilgrims:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...sessionPilgrims.map((pilgrim) => ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(pilgrim,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
      ],
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
                    sessionPilgrims.add(pilgrimController.text);
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

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => userRole == "Pilgrim"
            ? const Placeholder() // Replace with Pilgrim Dashboard
            : const Placeholder(), // Replace with Motawif Dashboard
      ),
    );
  }
}
