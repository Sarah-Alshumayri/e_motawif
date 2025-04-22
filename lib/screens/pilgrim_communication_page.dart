import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_motawif_new/database_helper.dart';
import 'chat_page.dart';

class PilgrimCommunicationPage extends StatefulWidget {
  @override
  _PilgrimCommunicationPageState createState() =>
      _PilgrimCommunicationPageState();
}

class _PilgrimCommunicationPageState extends State<PilgrimCommunicationPage> {
  List<dynamic> assignedPilgrims = [];
  String motawifId = '';

  @override
  void initState() {
    super.initState();
    _loadMotawifIdAndPilgrims();
  }

  Future<void> _loadMotawifIdAndPilgrims() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      motawifId = userId;
      var response = await DatabaseHelper.getAssignedPilgrims(motawifId);
      setState(() {
        // Add fallback if 'data' is null or not a list
        assignedPilgrims = response['data'] ?? [];
      });
    }
  }

  void _openChat(String pilgrimId, String pilgrimName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          motawifId: motawifId,
          pilgrimId: pilgrimId,
          pilgrimName: pilgrimName,
          userRole: 'motawif',
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0D4A45);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Pilgrim Communication",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Broadcast feature coming soon")),
              );
            },
          ),
        ],
      ),
      body: assignedPilgrims.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: assignedPilgrims.length,
              itemBuilder: (context, index) {
                final pilgrim = assignedPilgrims[index];
                final String? pilgrimId = pilgrim['pilgrim_id']?.toString();
                final String? pilgrimName = pilgrim['name'];

                return GestureDetector(
                  onTap: () {
                    print("👤 Selected pilgrim: $pilgrim");
                    if (pilgrimId != null && pilgrimName != null) {
                      _openChat(pilgrimId, pilgrimName);
                    } else {
                      print("⚠️ Missing pilgrimId or name");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid pilgrim data.')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.purple[100],
                        child: const Icon(Icons.person, color: Colors.purple),
                      ),
                      title: Text(
                        pilgrimName ?? 'Unnamed',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: const Text(
                        'Tap to start chatting',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chat_bubble_outline,
                          color: Colors.purple),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
