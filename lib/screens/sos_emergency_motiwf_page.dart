import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'sos_map_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSEmergencyMotawifPage extends StatefulWidget {
  @override
  _SOSEmergencyMotawifPageState createState() =>
      _SOSEmergencyMotawifPageState();
}

class _SOSEmergencyMotawifPageState extends State<SOSEmergencyMotawifPage> {
  List<Map<String, dynamic>> sosRequests = [];
  Position? motawifLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await _getMotawifLocation(); // Step 1: Get location
    await fetchSOSAlerts(); // Step 2: Get SOS alerts
  }

  Future<void> _getMotawifLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("❌ Location permissions denied.");
        return;
      }

      motawifLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
          "📍 Got location: ${motawifLocation!.latitude}, ${motawifLocation!.longitude}");
    } catch (e) {
      print("⚠️ Error getting location: $e");
    }
  }

  Future<void> fetchSOSAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final motawifId = prefs.getInt('user_id');

      if (motawifId == null) {
        print("❌ No Motawif ID found");
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse("http://10.0.2.2/e_motawif_new/get_sos_alerts.php");
      final response = await http.post(url, body: {
        'motawif_id': motawifId.toString(),
      });

      final jsonResponse = jsonDecode(response.body);
      print("📦 SOS Alerts Response: $jsonResponse");
      if (!jsonResponse['success']) {
        throw Exception("Failed to fetch alerts");
      }

      final List<dynamic> alerts = jsonResponse['data'];

      // 🌍 Calculate distance if location is available
      if (motawifLocation != null) {
        for (var alert in alerts) {
          final double lat =
              double.tryParse(alert['latitude'].toString()) ?? 0.0;
          final double lng =
              double.tryParse(alert['longitude'].toString()) ?? 0.0;

          double distanceInMeters = Geolocator.distanceBetween(
            motawifLocation!.latitude,
            motawifLocation!.longitude,
            lat,
            lng,
          );
          alert['distance'] = (distanceInMeters / 1000).toStringAsFixed(2);
        }
      } else {
        for (var alert in alerts) {
          alert['distance'] = "Unknown";
        }
      }

      setState(() {
        sosRequests = List<Map<String, dynamic>>.from(alerts);
        isLoading = false;
      });
    } catch (e) {
      print("🔥 Error fetching alerts: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> resolveSOS(int index) async {
    final alert = sosRequests[index];
    final alertId = alert['id'];

    final url =
        Uri.parse("http://10.0.2.2/e_motawif_new/resolve_sos_alert.php");

    try {
      final response = await http.post(url, body: {'id': alertId.toString()});
      final json = jsonDecode(response.body);

      if (json['success']) {
        setState(() {
          sosRequests[index]['status'] = "Resolved";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ SOS marked as resolved")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${json['message']}")),
        );
      }
    } catch (e) {
      print("❌ Error resolving SOS: $e");
    }
  }

  void trackOnMap(int index) {
    final sos = sosRequests[index];
    final lat = double.tryParse(sos['latitude']);
    final lng = double.tryParse(sos['longitude']);
    final message = sos['message'];

    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SOSMapView(
            latitude: lat,
            longitude: lng,
            message: message,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Invalid coordinates")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("SOS Emergency - Motawif",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : sosRequests.isEmpty
              ? Center(child: Text("No active SOS alerts."))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Active SOS Requests",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: sosRequests.length,
                          itemBuilder: (context, index) {
                            final sos = sosRequests[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.red, size: 30),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Pilgrim ID: ${sos['pilgrim_id']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text("Message: ${sos['message']}"),
                                    Text("Time: ${sos['timestamp']}"),
                                    Text(
                                        "Location: ${sos['latitude']}, ${sos['longitude']}"),
                                    Text("Distance: ${sos['distance']} km",
                                        style: TextStyle(color: Colors.teal)),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => trackOnMap(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                          ),
                                          child: Text("View",
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                        SizedBox(width: 8),
                                        sos['status'] == "Resolved"
                                            ? Icon(Icons.check_circle,
                                                color: Colors.green)
                                            : ElevatedButton(
                                                onPressed: () =>
                                                    resolveSOS(index),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                ),
                                                child: Text("Resolve",
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                              ),
                                      ],
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
