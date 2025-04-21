import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SOSEmergencyPage extends StatefulWidget {
  @override
  _SOSEmergencyPageState createState() => _SOSEmergencyPageState();
}

class _SOSEmergencyPageState extends State<SOSEmergencyPage> {
  bool isAlertSent = false;

  Future<void> _sendSosAlert(String message) async {
    setState(() {
      isAlertSent = true;
    });

    try {
      // 🔐 Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      // 📲 Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Location permissions are permanently denied.")),
        );
        return;
      }

      // ✅ Now safe to get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      dynamic rawId = prefs.get('user_id');
      int? userId = rawId is int ? rawId : int.tryParse(rawId.toString());

      if (userId == null) {
        throw Exception("User ID not found in local storage");
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2/e_motawif_new/send_emergency_alert.php'),
        body: {
          'user_id': userId.toString(), // updated from 'user_id'
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          'message': message,
        },
      );

      final json = jsonDecode(response.body);
      if (json['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🚨 SOS sent: $message")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send SOS")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isAlertSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("SOS Emergency", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Colors.white), // ✅ Makes back arrow white
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
              onPressed: () => _sendSosAlert("General SOS"),
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
            // Later: implement emergency call or contact info
          },
        ),
        Text(label),
      ],
    );
  }

  Widget emergencyMessageButton(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () => _sendSosAlert(message),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: Text(message),
      ),
    );
  }
}
