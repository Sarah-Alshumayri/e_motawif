import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResidencyAllocationPage extends StatefulWidget {
  final String userType;

  ResidencyAllocationPage({required this.userType});

  @override
  _ResidencyAllocationPageState createState() =>
      _ResidencyAllocationPageState();
}

class _ResidencyAllocationPageState extends State<ResidencyAllocationPage> {
  List<Map<String, dynamic>> pilgrimLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userType == 'Pilgrim') {
      fetchLocationsForPilgrim();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLocationsForPilgrim() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      print("❌ No user_id found in SharedPreferences");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/e_motawif_new/get_locations_by_pilgrim.php'),
        body: {'pilgrim_id': userId},
      );

      print("🔁 STATUS CODE: ${response.statusCode}");
      print("🔁 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            pilgrimLocations =
                List<Map<String, dynamic>>.from(data['locations']);
            isLoading = false;
          });
        } else {
          print("❌ Backend error: ${data['message'] ?? 'Unknown error'}");
          setState(() => isLoading = false);
        }
      } else {
        print("❌ Failed to fetch locations. HTTP ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception during fetch: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Location Tracking',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: widget.userType == 'Pilgrim'
            ? _buildPilgrimView()
            : Center(child: Text("This page is only for Pilgrims.")),
      ),
    );
  }

  Widget _buildPilgrimView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (pilgrimLocations.isEmpty) {
      return Center(child: Text('No accommodation found.'));
    }

    return ListView(
      children: [
        Text('Your Accommodation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...pilgrimLocations.map((loc) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hotel: ${loc['hotel_name']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Location: ${loc['hotel_location']}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _openGoogleMaps(
                          loc['hotel_name'], loc['hotel_location']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      child: Text("View on Map",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _openGoogleMaps(String hotel, String location) async {
    final query = Uri.encodeComponent("$hotel $location Makkah");
    final url = "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch Google Maps")),
      );
    }
  }
}
