import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  final String userRole;

  NotificationsPage({required this.userRole});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Color primaryColor = const Color(0xFF0D4A45);
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    print("🔍 Checking notifications for user_id: $userId");
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://10.0.2.2/e_motawif_new/get_notifications.php'),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        print("📦 Raw notification data: ${data['notifications']}");

        setState(() {
          notifications =
              List<Map<String, dynamic>>.from(data['notifications']);
          notifications.sort((a, b) =>
              b['timestamp'].compareTo(a['timestamp'])); // Sort by latest
        });
      }
    } else {
      print("❌ Failed to fetch notifications.");
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat("MMM d, h:mm a").format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchNotifications(); // refresh manually
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? const Center(child: Text("No notifications yet."))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final sender = notif['sender_name'] ?? 'System';
                  final seen = notif['seen'] == "1" || notif['seen'] == 1;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          const Icon(Icons.notifications, color: Colors.teal),
                          if (!seen)
                            const Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(Icons.circle,
                                  size: 10, color: Colors.green),
                            )
                        ],
                      ),
                      title: Text(
                        notif['title'] ?? 'Notification',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("From: $sender",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(notif['message'] ?? ''),
                          const SizedBox(height: 6),
                          Text(
                            _formatTimestamp(notif['timestamp'] ?? ''),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
