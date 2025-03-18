import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/services_page.dart';
import '../database_helper.dart';
import 'screens/login_page.dart';
import 'screens/startup_session_page.dart';
import 'screens/splash_screen.dart'; // ✅ Added import for Splash Screen
import 'screens/motawif_sidebar_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userRole = prefs.getString('userRole');

  runApp(MyApp(userRole: userRole));
}

class MyApp extends StatelessWidget {
  final String? userRole;
  MyApp({this.userRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Motawif',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SplashScreen(), // ✅ Show Splash Screen first
    );
  }
}
