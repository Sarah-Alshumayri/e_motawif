import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'help_page.dart'; // Make sure this import is present

class CustomerSupportPage extends StatefulWidget {
  @override
  _CustomerSupportPageState createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact Support",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _supportButton(Icons.phone, "Call",
                    () => print("Call Support Placeholder")),
                _supportButton(Icons.email, "Email", _showEmailPopup),
                _supportButton(Icons.chat, "Live Chat", _showLiveChat),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Need help? Start a chat to get quick answers!",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40, color: Colors.teal),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  void _showEmailPopup() {
    final email = 'emotawif@gmail.com';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contact via Email"),
        content: GestureDetector(
          onTap: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: email,
              query: Uri.encodeFull('subject=Support Request'),
            );
            final url = emailUri.toString();
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No email app found")),
              );
            }
          },
          child: Row(
            children: [
              Icon(Icons.email, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                email,
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  void _showLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: HelpPage(isEmbedded: true),
      ),
    );
  }
}
