import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'splash_screen.dart';
import 'services_page.dart'; // Import the new screen
import 'sos_emergency_user.dart'; // Import the SOS page1
import 'sos_emergency_motiwf_page.dart';
import 'lost_found_page.dart';
import 'startup_session_page.dart'; // Import the Startup Session Page
import 'ritual_guidance_page.dart';
import 'customer_support_page.dart';
import 'residency_allocation.dart'; // Adjust based on your file structure
import 'real_time_tracking_page.dart';
import 'health_monitoring_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart'; // Import Notifications Page
import 'pilgrim_list_page.dart'; // Import the Pilgrim List Page

class DebugScreen extends StatelessWidget {
  final List<Map<String, dynamic>> screens = [
    {'name': 'Splash Screen', 'widget': SplashScreen()},
    {'name': 'Login Page', 'widget': LoginPage()},
    {'name': 'Sign-Up Page', 'widget': SignUpPage()},
    {'name': 'Forgot Password Page', 'widget': ForgotPasswordPage()},
    //{'name': 'Services Page', 'widget': ServicesPage()},
    {'name': 'SOS Emergency Page', 'widget': SOSEmergencyPage()},
    {
      'name': 'SOS Emergency Page (Motiwf)',
      'widget': SOSEmergencyMotawifPage()
    },
    //{'name': 'Lost & Found Page', 'widget': LostFoundPage()},
    {
      'name': 'Startup Session Page',
      'widget': const StartupSessionPage(userRole: 'Pilgrim'),
    },
    {'name': 'Ritual Guidance Page', 'widget': RitualGuidancePage()},
    {'name': 'Customer Support Page', 'widget': CustomerSupportPage()},
    {
      'name': 'Residency Allocation Page',
      'widget': ResidencyAllocationPage(
        userType: 'Pilgrim',
      )
    },
    {
      'name': 'Real Time Tracking Page',
      'widget': RealTimeTrackingPage(
        userRole: 'Pilgrim',
      )
    },
    {
      'name': 'Health Monitoring Page',
      'widget': HealthMonitoringPage(
        userRole: 'Pilgrim',
      )
    },
    {
      'name': 'Settings Page',
      'widget': SettingsPage(
        userRole: 'Motawif',
      )
    },
    {
      'name': 'Notifications Page',
      'widget': NotificationsPage(
        userRole: 'Pilgrim', // Adjust dynamically based on user role
      )
    },
    {
      'name': 'Pilgrim List Page',
      'widget': PilgrimListPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
      ),
      body: ListView.builder(
        itemCount: screens.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(screens[index]['name'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.arrow_forward, color: Colors.teal),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => screens[index]['widget']),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
