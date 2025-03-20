import 'package:flutter/material.dart';

class ResidencyAllocationPage extends StatefulWidget {
  final String userType; // 'Pilgrim' or 'Motawif'

  ResidencyAllocationPage({required this.userType});

  @override
  _ResidencyAllocationPageState createState() =>
      _ResidencyAllocationPageState();
}

class _ResidencyAllocationPageState extends State<ResidencyAllocationPage> {
  // Sample data (Placeholder until backend is implemented)
  final Map<String, dynamic> pilgrimResidence = {
    'residenceID': 'H12345',
    'hotelName': 'Makkah Grand Hotel',
    'hotelLocation': 'Near Masjid Al-Haram',
    'motawifGuide': 'Ali Abdullah',
  };

  final List<Map<String, dynamic>> motawifResidences = [
    {
      'residenceID': 'R001',
      'hotelName': 'Mina Tent 5A',
      'hotelLocation': 'Mina Camp Area 5',
      'pilgrims': ['Ahmed Ali', 'Fatima Noor', 'Omar Hasan'],
    },
    {
      'residenceID': 'R002',
      'hotelName': 'Hilton Makkah Suites',
      'hotelLocation': 'Opposite Masjid Al-Haram',
      'pilgrims': ['Aisha Khan', 'Yusuf Kareem'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Location Tracking',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: widget.userType == 'Pilgrim'
            ? _buildPilgrimView()
            : _buildMotawifView(),
      ),
    );
  }

  // UI for Pilgrims
  Widget _buildPilgrimView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Accommodation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hotel: ${pilgrimResidence['hotelName']}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Location: ${pilgrimResidence['hotelLocation']}',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                Text('Motawif Guide: ${pilgrimResidence['motawifGuide']}',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => print("View Hotel Location Placeholder"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text("View on Map"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI for Motawif Guides
  Widget _buildMotawifView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Residences You Manage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: motawifResidences.length,
            itemBuilder: (context, index) {
              final residence = motawifResidences[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(residence['hotelName'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location: ${residence['hotelLocation']}',
                          style: TextStyle(color: Colors.black54)),
                      Text('Pilgrims: ${residence['pilgrims'].join(', ')}',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => print("Update Residency Placeholder"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(
                      "Manage",
                      style: TextStyle(
                          color: Colors.white), // Text color changed to white
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
