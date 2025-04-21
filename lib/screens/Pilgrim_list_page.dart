import 'package:flutter/material.dart';
import 'health_monitoring_page.dart';
import 'real_time_tracking_page.dart';
import 'sos_emergency_motiwf_page.dart';
import 'notifications_page.dart';

class PilgrimListPage extends StatefulWidget {
  @override
  _PilgrimListPageState createState() => _PilgrimListPageState();
}

class _PilgrimListPageState extends State<PilgrimListPage> {
  // Sample Pilgrim Data
  List<Map<String, dynamic>> pilgrims = [
    {
      "name": "Ahmed Ali",
      "healthStatus": "Needs Attention",
      "location": "Near Kaaba",
      "sosActive": true,
    },
    {
      "name": "Fatima Noor",
      "healthStatus": "Stable",
      "location": "Mina Tents",
      "sosActive": false,
    },
    {
      "name": "Omar Hasan",
      "healthStatus": "Critical",
      "location": "Gate 5, Masjid Al-Haram",
      "sosActive": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _sortPilgrims();
  }

  void _sortPilgrims() {
    pilgrims.sort((a, b) {
      List<String> priority = ["Critical", "Needs Attention", "Stable"];
      return priority
          .indexOf(a["healthStatus"])
          .compareTo(priority.indexOf(b["healthStatus"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilgrim List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned Pilgrims',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: pilgrims.length,
                itemBuilder: (context, index) {
                  final pilgrim = pilgrims[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.person,
                          color: pilgrim['sosActive'] ||
                                  pilgrim['healthStatus'] == "Critical"
                              ? Colors.red
                              : Colors.teal,
                          size: 30),
                      title: Text(pilgrim['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Health: ${pilgrim['healthStatus']}",
                              style: TextStyle(
                                  color: pilgrim['healthStatus'] == "Critical"
                                      ? Colors.red
                                      : Colors.black54)),
                          Text("Location: ${pilgrim['location']}",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "Health") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HealthMonitoringPage(
                                      userRole: "Motawif")),
                            );
                          } else if (value == "Tracking") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RealTimeTrackingPage(
                                      userRole: "Motawif")),
                            );
                          } else if (value == "Emergency") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SOSEmergencyMotawifPage()),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: "Health",
                            child: Text("View Health Status"),
                          ),
                          PopupMenuItem<String>(
                            value: "Tracking",
                            child: Text("View Real-Time Location"),
                          ),
                          PopupMenuItem<String>(
                            value: "Emergency",
                            child: Text("Emergency Requests"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
