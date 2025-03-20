import 'package:flutter/material.dart';

class SOSEmergencyPage extends StatefulWidget {
  @override
  _SOSEmergencyPageState createState() => _SOSEmergencyPageState();
}

class _SOSEmergencyPageState extends State<SOSEmergencyPage> {
  bool isAlertSent = false;

  void triggerSOS() {
    setState(() {
      isAlertSent = true;
    });
    // Simulate sending location or contacting emergency services
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isAlertSent = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("SOS Emergency", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Emergency Assistance",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              "If you are in danger or need urgent help, press the button below.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: triggerSOS,
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(50),
                backgroundColor: Colors.red,
              ),
              child: Icon(Icons.warning, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            isAlertSent
                ? Text("SOS Alert Sent! Help is on the way.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red))
                : Container(),
            SizedBox(height: 40),
            Divider(),
            SizedBox(height: 20),
            Text("Quick Contacts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                contactButton(Icons.local_hospital, "Medical Help"),
                contactButton(Icons.security, "Security"),
                contactButton(Icons.support_agent, "Support"),
              ],
            ),
            SizedBox(height: 30),
            Text("Quick Emergency Messages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            emergencyMessageButton("I am lost"),
            emergencyMessageButton("I need medical help"),
            emergencyMessageButton("I am in danger"),
          ],
        ),
      ),
    );
  }

  Widget contactButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40, color: Colors.teal),
          onPressed: () {
            // TODO: Implement call functionality
          }, // Implement call functionality
        ),
        Text(label),
      ],
    );
  }

  Widget emergencyMessageButton(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement call functionality
        }, // Implement sending message functionality
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: Text(message),
      ),
    );
  }
}
