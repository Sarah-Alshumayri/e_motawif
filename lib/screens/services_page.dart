import 'package:flutter/material.dart';
import 'sos_emergency_user.dart'; // Pilgrims' SOS Emergency Page
import 'lost_found_page.dart'; // Lost & Found Page
import 'customer_support_page.dart'; // Customer Support Page
import 'startup_session_page.dart'; // Startup Session Page
import 'ritual_guidance_page.dart';
import 'residency_allocation.dart';
import 'real_time_tracking_page.dart';
import 'health_monitoring_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart'; // Notifications Page

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<Map<String, dynamic>> services = [
    {
      "title": "Startup Session",
      "icon": Icons.lightbulb,
      "page": const StartupSessionPage(userRole: 'Motawif'),
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
      "page": LostFoundPage(), // Re-enabled navigation to Lost & Found page
    },
    {
      "title": "Residency Allocation Tracking",
      "icon": Icons.hotel,
      "page": ResidencyAllocationPage(userType: 'Motawif'),
    },
    {
      "title": "SOS Emergency",
      "icon": Icons.warning,
      "page": SOSEmergencyPage(),
    },
    {
      "title": "Real-Time Tracking",
      "icon": Icons.location_on,
      "page": RealTimeTrackingPage(userRole: 'Motawif'),
    },
    {
      "title": "Health Monitoring",
      "icon": Icons.health_and_safety,
      "page": HealthMonitoringPage(userRole: 'Motawif'),
    },
    {
      "title": "Notifications",
      "icon": Icons.notifications,
      "page": NotificationsPage(userRole: 'Motawif'),
    },
  ];

  List<Map<String, dynamic>> filteredServices = [];
  final Set<String> pinnedServices = {}; // Optimized pinning logic

  @override
  void initState() {
    super.initState();
    filteredServices = List.from(services);
  }

  // Function to filter services based on user input
  void filterServices(String query) {
    setState(() {
      filteredServices = services
          .where((service) =>
              service['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Function to pin/unpin services for quick access
  void togglePin(String title) {
    setState(() {
      pinnedServices.contains(title)
          ? pinnedServices.remove(title)
          : pinnedServices.add(title);
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
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsPage(userRole: 'Motawif'),
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
          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
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
                    if (service.containsKey('page')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => service['page']),
                      );
                    }
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(userRole: 'Motawif'),
              ),
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

      // Floating action button for emergency SOS action
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
    );
  }
}
