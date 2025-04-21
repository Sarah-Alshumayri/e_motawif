import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SOSMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String message;

  const SOSMapView({
    required this.latitude,
    required this.longitude,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng sosLocation = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('SOS Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: sosLocation,
          zoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: sosLocation,
                width: 80,
                height: 80,
                builder: (ctx) => Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
