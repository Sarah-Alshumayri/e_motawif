import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_motawif_new/database_helper.dart';

class RealTimeTrackingPage extends StatefulWidget {
  final String userRole;

  RealTimeTrackingPage({required this.userRole});

  @override
  _RealTimeTrackingPageState createState() => _RealTimeTrackingPageState();
}

class _RealTimeTrackingPageState extends State<RealTimeTrackingPage> {
  bool isTrackingActive = false;
  bool isOutOfBounds = false;
  String locationStatus = "Within safe zone";

  LatLng currentLocation = LatLng(21.3891, 39.8579);
  late final MapController _mapController;
  Timer? _timer;
  bool hasShownAlert = false;

  List<Map<String, dynamic>> movementHistory = [];
  String? userId;

  List<Map<String, dynamic>> assignedPilgrims = [];
  String? selectedPilgrimId;
  LatLng? selectedPilgrimLocation;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loadedId = prefs.getString('user_id');

    print("👤 Loaded user ID: $loadedId");
    print("🧾 Role on RealTimeTrackingPage: ${widget.userRole}");

    setState(() {
      userId = loadedId;
    });

    if (widget.userRole.toLowerCase() == 'motawif' && userId != null) {
      fetchAssignedPilgrims();

      _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        fetchAssignedPilgrims();
      });
    }
  }

  void toggleTracking() {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please wait, user ID not loaded yet."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isTrackingActive = !isTrackingActive;
      if (isTrackingActive) {
        _startSimulatedTracking();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startSimulatedTracking() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentLocation = LatLng(
          currentLocation.latitude + 0.0005,
          currentLocation.longitude + 0.0005,
        );

        movementHistory.add({
          'time': DateTime.now(),
          'lat': currentLocation.latitude,
          'lng': currentLocation.longitude,
        });

        if (userId != null) {
          print(
              "📡 Saving movement: user=$userId lat=${currentLocation.latitude} lng=${currentLocation.longitude}");
          DatabaseHelper.saveMovement(
            userId: userId!,
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
          );
        }

        isOutOfBounds = currentLocation.latitude < 21.3850 ||
            currentLocation.latitude > 21.3950 ||
            currentLocation.longitude < 39.8500 ||
            currentLocation.longitude > 39.8650;

        locationStatus = isOutOfBounds
            ? "Out of bounds! Return to the safe zone."
            : "Within safe zone";

        if (isOutOfBounds && !hasShownAlert) {
          hasShownAlert = true;
          _showOutOfBoundsAlert();
        }
      });
    });
  }

  void _showOutOfBoundsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("⚠️ Out of Bounds"),
          content: const Text("You have exited the safe zone. Please return."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _clearMovementHistory() {
    setState(() {
      movementHistory.clear();
    });
  }

  Future<void> fetchAssignedPilgrims() async {
    if (userId == null) {
      print("❌ No user ID found yet.");
      return;
    }

    print("📢 fetchAssignedPilgrims() called — userId = $userId");

    try {
      final response = await DatabaseHelper.postData(
        url: "get_pilgrims_for_tracking.php",
        body: {"motawif_id": userId!},
      );

      print("📥 API Response: $response");

      if (response != null &&
          response['success'] == true &&
          response['data'] is List) {
        List<dynamic> data = response['data'];

        setState(() {
          assignedPilgrims = data.map<Map<String, dynamic>>((p) {
            return {
              "id": p['pilgrim_id'].toString(),
              "name": p['name'] ?? "Unknown",
              "lastLat":
                  double.tryParse(p['latitude']?.toString() ?? '0') ?? 0.0,
              "lastLng":
                  double.tryParse(p['longitude']?.toString() ?? '0') ?? 0.0,
              "lastSeen": p['lastSeen'] ?? "Unknown",
              "status": "Unknown"
            };
          }).toList();
        });

        print("✅ Assigned pilgrims loaded: ${assignedPilgrims.length}");
      } else {
        print("⚠️ API returned no data or wrong format.");
      }
    } catch (e) {
      print("❌ Error fetching assigned pilgrims: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Real-Time Tracking', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Colors.white), // ✅ Makes back arrow white
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
            if (widget.userRole.toLowerCase() == 'pilgrim')
              ElevatedButton(
                onPressed: toggleTracking,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTrackingActive ? Colors.red : Colors.teal),
                child: Text(
                  isTrackingActive ? "Stop Tracking" : "Start Tracking",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            Expanded(
              child: widget.userRole.toLowerCase() == 'pilgrim'
                  ? _buildPilgrimView()
                  : _buildMotawifView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPilgrimView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FlutterMap(
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
                    builder: (ctx) => const Icon(Icons.location_on,
                        color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Movement History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _clearMovementHistory,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Clear History",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: movementHistory.isEmpty
              ? const Center(child: Text("No movement history yet."))
              : ListView.builder(
                  itemCount: movementHistory.length,
                  itemBuilder: (context, index) {
                    final entry = movementHistory[index];
                    return ListTile(
                      leading: const Icon(Icons.navigation, color: Colors.teal),
                      title: Text(
                          "Lat: ${entry['lat'].toStringAsFixed(5)}, Lng: ${entry['lng'].toStringAsFixed(5)}"),
                      subtitle: Text(
                          "Time: ${entry['time'].toString().substring(0, 19)}"),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMotawifView() {
    if (assignedPilgrims.isEmpty) {
      return Center(child: Text("⛔ No pilgrims assigned to you."));
    }

    return selectedPilgrimLocation != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracking: ${assignedPilgrims.firstWhere((p) => p["id"] == selectedPilgrimId)["name"]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options:
                      MapOptions(center: selectedPilgrimLocation, zoom: 15),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.e_motawif',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedPilgrimLocation!,
                          width: 80,
                          height: 80,
                          builder: (ctx) => const Icon(Icons.location_on,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPilgrimId = null;
                    selectedPilgrimLocation = null;
                  });
                },
                child: Text("← Back to list"),
              )
            ],
          )
        : ListView.builder(
            itemCount: assignedPilgrims.length,
            itemBuilder: (context, index) {
              final pilgrim = assignedPilgrims[index];
              return ListTile(
                leading: Icon(Icons.person_pin_circle, color: Colors.teal),
                title: Text(pilgrim["name"]),
                subtitle: Text("Last seen: ${pilgrim["lastSeen"]}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    LatLng newLocation = LatLng(
                      pilgrim["lastLat"],
                      pilgrim["lastLng"],
                    );

                    setState(() {
                      selectedPilgrimId = pilgrim["id"];
                      selectedPilgrimLocation = newLocation;
                    });

                    _mapController.move(newLocation, 15);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text("Track", style: TextStyle(color: Colors.white)),
                ),
              );
            },
          );
  }
}
