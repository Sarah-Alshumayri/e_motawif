import 'package:flutter/material.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final String userRole; // 'Pilgrim' or 'Motawif'

  const SettingsPage({required this.userRole, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedLanguage = "English";

  void toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
  }

  void toggleDarkMode(bool value) {
    setState(() {
      darkModeEnabled = value;
    });
  }

  void changeLanguage(String? language) {
    setState(() {
      selectedLanguage = language ?? "English";
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Widget _buildCommonSettings() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.language, color: Colors.teal),
          title: Text("Language"),
          subtitle: Text(selectedLanguage),
          trailing: DropdownButton<String>(
            value: selectedLanguage,
            items: ["English", "Arabic", "French"]
                .map((lang) => DropdownMenuItem(
                      child: Text(lang),
                      value: lang,
                    ))
                .toList(),
            onChanged: changeLanguage,
          ),
        ),
        SwitchListTile(
          title: Text("Dark Mode"),
          value: darkModeEnabled,
          onChanged: toggleDarkMode,
          secondary: Icon(Icons.brightness_6, color: Colors.teal),
        ),
        ListTile(
          leading: Icon(Icons.security, color: Colors.teal),
          title: Text("Privacy & Security"),
          subtitle: Text("Manage password & 2FA"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Privacy & Security Placeholder"),
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text("Delete Account"),
          onTap: () => print("Delete Account Placeholder"),
        ),
        ListTile(
          leading: Icon(Icons.help, color: Colors.teal),
          title: Text("Help & Support"),
          subtitle: Text("FAQs and Customer Support"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Help & Support Placeholder"),
        ),
      ],
    );
  }

  Widget _buildPilgrimSettings() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: Colors.teal),
          title: Text("Profile Management"),
          subtitle: Text("Edit name, email, and profile picture"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Profile Management Placeholder"),
        ),
        SwitchListTile(
          title: Text("Enable Notifications"),
          value: notificationsEnabled,
          onChanged: toggleNotifications,
          secondary: Icon(Icons.notifications, color: Colors.teal),
        ),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text("Log Out"),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildMotawifSettings() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.dashboard_customize, color: Colors.teal),
          title: Text("Motawif Dashboard"),
          subtitle: Text("Manage assigned pilgrims"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Motawif Dashboard Placeholder"),
        ),
        SwitchListTile(
          title: Text("Enable Notifications"),
          value: notificationsEnabled,
          onChanged: toggleNotifications,
          secondary: Icon(Icons.notifications, color: Colors.teal),
        ),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text("Log Out"),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.userRole.toLowerCase() == 'pilgrim')
              _buildPilgrimSettings(),
            if (widget.userRole.toLowerCase() == 'motawif')
              _buildMotawifSettings(),
            Divider(height: 40),
            _buildCommonSettings(),
          ],
        ),
      ),
    );
  }
}
