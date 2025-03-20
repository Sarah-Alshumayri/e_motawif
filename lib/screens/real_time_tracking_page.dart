import 'package:flutter/material.dart';

class RealTimeTrackingPage extends StatefulWidget {
  final String userRole; // 'Pilgrim' or 'Motawif'

  RealTimeTrackingPage({required this.userRole});

  @override
  _RealTimeTrackingPageState createState() => _RealTimeTrackingPageState();
}

class _RealTimeTrackingPageState extends State<RealTimeTrackingPage> {
  bool isTrackingActive = false;
  bool isOutOfBounds = false;
  String locationStatus = "Within safe zone";

  void toggleTracking() {
    setState(() {
      isTrackingActive = !isTrackingActive;
    });
  }

  void checkOutOfBounds() {
    setState(() {
      isOutOfBounds = !isOutOfBounds;
      locationStatus = isOutOfBounds
          ? "Out of bounds! Return to the safe zone."
          : "Within safe zone";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Real-Time Tracking', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracking Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                locationStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOutOfBounds ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Updated Tracking Button
            ElevatedButton(
              onPressed: toggleTracking,
              style: ElevatedButton.styleFrom(
                  backgroundColor: isTrackingActive ? Colors.red : Colors.teal),
              child: Text(
                isTrackingActive ? "Stop Tracking" : "Start Tracking",
                style: TextStyle(
                    color: Colors.white), // Text color changed to white
              ),
            ),
            SizedBox(height: 10),

            // Updated Simulate Out of Bounds Button
            ElevatedButton(
              onPressed: checkOutOfBounds,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                "Simulate Out of Bounds",
                style: TextStyle(
                    color: Colors.white), // Text color changed to white
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: widget.userRole == 'Pilgrim'
                  ? _buildPilgrimView()
                  : _buildMotawifView(),
            ),
          ],
        ),
      ),
    );
  }

  // UI for Pilgrims
  Widget _buildPilgrimView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Movement History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.teal),
                title: Text("Tawaf Completed"),
                subtitle: Text("10:30 AM - Masjid Al-Haram"),
              ),
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.teal),
                title: Text("Arrived at Mina"),
                subtitle: Text("1:00 PM - Mina Tents"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI for Motawif Guides
  Widget _buildMotawifView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilgrims You Are Tracking',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.person_pin_circle, color: Colors.teal),
                title: Text("Ahmed Ali"),
                subtitle: Text("Last seen: Masjid Al-Haram, 10:30 AM"),
                trailing: ElevatedButton(
                  onPressed: () => print("Track Ahmed Placeholder"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text(
                    "Track",
                    style: TextStyle(
                        color: Colors.white), // Text color changed to white
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person_pin_circle, color: Colors.teal),
                title: Text("Fatima Noor"),
                subtitle: Text("Last seen: Mina, 1:00 PM"),
                trailing: ElevatedButton(
                  onPressed: () => print("Track Fatima Placeholder"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text(
                    "Track",
                    style: TextStyle(
                        color: Colors.white), // Text color changed to white
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
