import 'package:flutter/material.dart';

class SOSEmergencyMotiwfPage extends StatefulWidget {
  @override
  _SOSEmergencyMotiwfPageState createState() => _SOSEmergencyMotiwfPageState();
}

class _SOSEmergencyMotiwfPageState extends State<SOSEmergencyMotiwfPage> {
  List<Map<String, dynamic>> sosRequests = [
    {
      "name": "Ali Ahmed",
      "time": "2 mins ago",
      "location": "Near Kaaba",
      "resolved": false
    },
    {
      "name": "Fatima Khan",
      "time": "5 mins ago",
      "location": "Gate 5, Masjid Al-Haram",
      "resolved": false
    },
    {
      "name": "Omar Abdullah",
      "time": "10 mins ago",
      "location": "Mina Tents",
      "resolved": false
    },
  ];

  void respondToSOS(int index) {
    setState(() {
      sosRequests[index]['resolved'] = true;
    });
    // TODO: Implement response functionality (e.g., navigate to map, call user)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("SOS Emergency - Motiwf",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Active SOS Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sosRequests.length,
                itemBuilder: (context, index) {
                  final sos = sosRequests[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.red, size: 30),
                      title: Text(sos['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Time: ${sos['time']}",
                              style: TextStyle(color: Colors.black54)),
                          Text("Location: ${sos['location']}",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      trailing: sos['resolved']
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => respondToSOS(index),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: Text("Respond"),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
