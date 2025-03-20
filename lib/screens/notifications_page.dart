import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final String userRole; // 'Pilgrim' or 'Motawif'

  NotificationsPage({required this.userRole});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Sample data for Pilgrim notifications
  final List<String> pilgrimNotifications = [
    "You're location is out of bounds.",
    "You will receive help immediately.",
    "Your next step is to proceed to the gathering area.",
  ];

  // Sample data for Motawif notifications
  final List<Map<String, dynamic>> motawifNotifications = [
    {
      "pilgrim": "Ahmed Ali",
      "notification": "Please ensure Ahmed Ali reaches Mina."
    },
    {
      "pilgrim": "Fatima Noor",
      "notification": "Fatima Noor needs medical attention."
    },
    {
      "pilgrim": "Omar Hasan",
      "notification": "Omar Hasan is ready for his next step."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            widget.userRole == 'Pilgrim'
                ? _buildPilgrimNotifications()
                : _buildMotawifNotifications(),
          ],
        ),
      ),
    );
  }

  // For Pilgrims, show a list of general notifications
  Widget _buildPilgrimNotifications() {
    return Expanded(
      child: ListView.builder(
        itemCount: pilgrimNotifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(pilgrimNotifications[index],
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  // For Motawif, show a list of assigned pilgrim notifications
  Widget _buildMotawifNotifications() {
    return Expanded(
      child: ListView.builder(
        itemCount: motawifNotifications.length,
        itemBuilder: (context, index) {
          final notification = motawifNotifications[index];
          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text(notification['pilgrim'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(notification['notification'],
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            ),
          );
        },
      ),
    );
  }
}
