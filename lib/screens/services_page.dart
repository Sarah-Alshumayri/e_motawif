import 'package:flutter/material.dart';
import 'pilgrim_profile_page.dart';
import 'sos_emergency_user.dart';
import 'lost_found_page.dart';
import 'customer_support_page.dart';
import 'startup_session_page.dart';
import 'ritual_guidance_page.dart';
import 'residency_allocation.dart';
import 'real_time_tracking_page.dart';
import 'health_monitoring_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'sos_emergency_user.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key, required String userRole}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<Map<String, dynamic>> services = [
    {
      "title": "Startup Session",
      "icon": Icons.lightbulb,
      "page": StartupSessionPage(userRole: 'Pilgrim'),
    },
    {
      "title": "Ritual Guidance",
      "icon": Icons.menu_book,
      "page": RitualGuidancePage(),
    },
    {
      "title": "Customer Support",
      "icon": Icons.support_agent,
      "page": CustomerSupportPage(),
    },
    {
      "title": "Report Lost & Found Items",
      "icon": Icons.report,
      "page": LostFoundPage(),
    },
    {
      "title": "Residency Allocation Tracking",
      "icon": Icons.hotel,
      "page": ResidencyAllocationPage(userType: 'Pilgrim'),
    },
    {
      "title": "Real-Time Tracking",
      "icon": Icons.location_on,
      "page": RealTimeTrackingPage(userRole: 'Pilgrim'),
    },
    {
      "title": "Health Monitoring",
      "icon": Icons.health_and_safety,
      "page": HealthMonitoringPage(userRole: 'Pilgrim'),
    },
    {
      "title": "Notifications",
      "icon": Icons.notifications,
      "page": NotificationsPage(userRole: 'Pilgrim'),
    },
    {
      "title": "Emergency Service",
      "icon": Icons.emergency,
      "page": SOSEmergencyPage(), // ✅ Correct
    },
  ];

  List<Map<String, dynamic>> filteredServices = [];
  List<String> pinnedServices = [];
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    filteredServices = List.from(services);
    _startNotificationListener();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationListener() {
    _notificationTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      if (userId == null) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2/e_motawif_new/get_notifications.php'),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final notifications =
              List<Map<String, dynamic>>.from(data['notifications']);
          if (notifications.isNotEmpty) {
            final latest = notifications.first;
            await NotificationService.showNotification(
              title: latest['title'] ?? 'Notification',
              body: latest['message'] ?? '',
            );
          }
        }
      }
    });
  }

  void filterServices(String query) {
    setState(() {
      filteredServices = services
          .where((service) =>
              service['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void togglePin(String title) {
    setState(() {
      if (pinnedServices.contains(title)) {
        pinnedServices.remove(title);
      } else {
        pinnedServices.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4A45),
        title: const Text("Services", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsPage(userRole: 'Pilgrim'),
                    ),
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: const Text("3",
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PilgrimProfilePage()),
              );
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filterServices,
              decoration: InputDecoration(
                hintText: "Search for a service...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                final bool isPinned = pinnedServices.contains(service['title']);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => service['page']),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(service['icon'], size: 50, color: Colors.teal),
                        const SizedBox(height: 10),
                        Text(
                          service['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPinned ? Icons.star : Icons.star_border,
                            color: isPinned ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => togglePin(service['title']),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SOSEmergencyPage()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(userRole: 'Pilgrim'),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
        ],
      ),
    );
  }
}
