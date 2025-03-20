import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/services_page.dart';
import 'screens/login_page.dart';
import 'screens/startup_session_page.dart'; // ✅ Pilgrim redirection
import 'screens/motawif_sidebar_menu.dart'; // ✅ Motawif redirection
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole'); // ✅ Fetch stored user role
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Motawif',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (userRole == null) {
      return SplashScreen(); // ✅ Show splash, then Login
    } else if (userRole == "pilgrim") {
      return StartupSessionPage(userRole: 'pilgrim'); // ✅ Pilgrim redirection
    } else if (userRole == "motawif") {
      return MotawifSidebarMenu(); // ✅ Motawif redirection
    } else {
      return LoginPage(); // ✅ Default to login if role is unknown
    }
  }
}
