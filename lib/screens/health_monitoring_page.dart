import 'package:flutter/material.dart';

class HealthMonitoringPage extends StatefulWidget {
  final String userRole; // 'Pilgrim' or 'Motawif'

  HealthMonitoringPage({required this.userRole});

  @override
  _HealthMonitoringPageState createState() => _HealthMonitoringPageState();
}

class _HealthMonitoringPageState extends State<HealthMonitoringPage> {
  bool isEmergency = false;

  // Simulated wearable device data
  double heartRate = 75;
  double oxygenLevel = 98;
  double temperature = 36.5;

  void triggerEmergency() {
    setState(() {
      isEmergency = !isEmergency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Monitoring', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vital Signs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildVitalSignCard('Heart Rate', '$heartRate bpm', Icons.favorite),
            _buildVitalSignCard('Oxygen Level', '$oxygenLevel%', Icons.air),
            _buildVitalSignCard(
                'Temperature', '$temperature°C', Icons.thermostat),
            SizedBox(height: 20),
            widget.userRole == 'Pilgrim'
                ? _buildPilgrimView()
                : _buildMotawifView(),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
      ),
    );
  }

  // UI for Pilgrims
  Widget _buildPilgrimView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: triggerEmergency,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("Call for Medical Help",
              style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 10),
        Text("Health History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildHealthHistory(),
      ],
    );
  }

  // UI for Motawif
  Widget _buildMotawifView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("Pilgrims Under Your Supervision",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SizedBox(
          height: 300, // Define a fixed height
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildPilgrimHealthCard("Ahmed Ali", "Normal"),
              _buildPilgrimHealthCard("Fatima Noor", "Needs Attention"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPilgrimHealthCard(String name, String status) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.teal, size: 30),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Health Status: $status",
            style: TextStyle(
                fontSize: 16,
                color:
                    status == "Needs Attention" ? Colors.red : Colors.green)),
        trailing: ElevatedButton(
          onPressed: () => print("View Health Details Placeholder"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: Text(
            "View",
            style:
                TextStyle(color: Colors.white), // Text color changed to white
          ),
        ),
      ),
    );
  }

  Widget _buildHealthHistory() {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.history, color: Colors.orange, size: 30),
            title: Text("Last Check-up"),
            subtitle: Text("Feb 10, 2025 - No issues detected"),
          ),
        ),
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.history, color: Colors.orange, size: 30),
            title: Text("Previous Alert"),
            subtitle: Text("Feb 5, 2025 - Low Oxygen Level"),
          ),
        ),
      ],
    );
  }
}
