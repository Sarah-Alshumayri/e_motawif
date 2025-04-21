import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../theme_provider.dart';
import '../l10n/locale_provider.dart';
import 'login_page.dart';
import 'help_page.dart';
import 'pilgrim_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final String userRole;

  const SettingsPage({required this.userRole, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  void toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showPrivacyDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🔒 ${t.privacySecurity}"),
        content: SingleChildScrollView(
          child: Text(
            "At E-Motawif, the privacy and security of our pilgrims' data is our top priority. "
            "We utilize modern encryption techniques, including SHA-1 and advanced cryptographic methods, "
            "to protect all personal and sensitive information.\n\n"
            "Your data is securely stored and handled according to industry best practices.",
            style: const TextStyle(fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: const TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLang = provider.locale.languageCode;
    final t = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.teal),
      title: Text(t.language),
      subtitle: Text(currentLang == 'ar' ? 'العربية' : 'English'),
      trailing: DropdownButton<String>(
        value: currentLang,
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
        ],
        onChanged: (langCode) {
          if (langCode != null) {
            provider.setLocale(Locale(langCode));
          }
        },
      ),
    );
  }

  Widget _buildCommonSettings() {
    final t = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        _buildLanguageDropdown(),
        SwitchListTile(
          title: Text(t.darkMode),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) =>
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value),
          secondary: const Icon(Icons.brightness_6, color: Colors.teal),
        ),
        ListTile(
          leading: const Icon(Icons.security, color: Colors.teal),
          title: Text(t.privacySecurity),
          subtitle: Text(t.privacyHint),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showPrivacyDialog,
        ),
        ListTile(
          leading: const Icon(Icons.help, color: Colors.teal),
          title: Text(t.helpSupport),
          subtitle: Text(t.helpHint),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPilgrimSettings() {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: Colors.teal),
          title: Text(t.profileManagement),
          subtitle: Text(t.editProfile),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PilgrimProfilePage()),
            );
          },
        ),
        SwitchListTile(
          title: Text(t.enableNotifications),
          value: notificationsEnabled,
          onChanged: toggleNotifications,
          secondary: const Icon(Icons.notifications, color: Colors.teal),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(t.logOut),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildMotawifSettings() {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard_customize, color: Colors.teal),
          title: const Text("Motawif Dashboard"),
          subtitle: const Text("Manage assigned pilgrims"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => print("Motawif Dashboard Placeholder"),
        ),
        SwitchListTile(
          title: Text(t.enableNotifications),
          value: notificationsEnabled,
          onChanged: toggleNotifications,
          secondary: const Icon(Icons.notifications, color: Colors.teal),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(t.logOut),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D4A45),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.userRole.toLowerCase() == 'pilgrim')
              _buildPilgrimSettings(),
            if (widget.userRole.toLowerCase() == 'motawif')
              _buildMotawifSettings(),
            const Divider(height: 40),
            _buildCommonSettings(),
          ],
        ),
      ),
    );
  }
}
