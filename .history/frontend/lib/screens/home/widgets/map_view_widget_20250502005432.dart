import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final List<Marker> markers;
  final Widget header;

  const MapViewWidget({
    super.key,
    required this.mapController,
    required this.center,
    required this.markers,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.myapp',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        header,
      ],
    );
  }
}
