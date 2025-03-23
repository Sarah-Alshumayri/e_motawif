import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  LatLng currentLocation = LatLng(21.3891, 39.8579); // Start in Makkah
  late final MapController _mapController;
  Timer? _timer;
  bool hasShownAlert = false; // To avoid multiple alerts

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        // Move a little each time
        currentLocation = LatLng(
          currentLocation.latitude + 0.0005,
          currentLocation.longitude + 0.0005,
        );

        _mapController.move(currentLocation, _mapController.zoom);

        // 🚨 Out-of-bounds detection
        bool isOutOfBounds = currentLocation.latitude < 21.3850 ||
            currentLocation.latitude > 21.3950 ||
            currentLocation.longitude < 39.8500 ||
            currentLocation.longitude > 39.8650;

        if (isOutOfBounds && !hasShownAlert) {
          hasShownAlert = true; // Prevent repeated alerts
          _showOutOfBoundsAlert();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showOutOfBoundsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("⚠️ Out of Bounds"),
          content: const Text(
              "You have exited the safe zone. Please return immediately."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Tracking'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D4A45),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: currentLocation,
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.e_motawif',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentLocation,
                width: 80,
                height: 80,
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
