import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // ✅ Initialize notifications
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Motawif',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SplashScreen(), // Always start with SplashScreen
    );
  }
}
