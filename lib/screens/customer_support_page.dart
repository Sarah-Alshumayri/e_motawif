import 'package:flutter/material.dart';

class CustomerSupportPage extends StatefulWidget {
  @override
  _CustomerSupportPageState createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to settings and click on reset password.'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can call, email, or use live chat.'
    },
    {
      'question': 'Where can I track my requests?',
      'answer': 'Your support tickets can be found in the support section.'
    },
  ];

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
                _supportButton(Icons.email, "Email",
                    () => print("Email Support Placeholder")),
                _supportButton(Icons.chat, "Live Chat",
                    () => print("Live Chat Placeholder")),
              ],
            ),
            SizedBox(height: 20),
            Text("FAQs",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ExpansionTile(
                      title: Text(faqs[index]['question']!),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(faqs[index]['answer']!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => print("Submit Ticket Placeholder"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text(
                "Submit a Support Ticket",
                style: TextStyle(
                    color: Colors.white), // Text color changed to white
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => print("Emergency Contact Placeholder"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                "Emergency Contact",
                style: TextStyle(
                    color: Colors.white), // Text color changed to white
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
}
