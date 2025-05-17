import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/services/truckOwner_service.dart';

class CustomerMapPage extends StatefulWidget {
  const CustomerMapPage({super.key});

  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {
  LatLng? _currentLatLng;
  LatLng _mapCenter = LatLng(0, 0); // default initial value
  String? selectedCity;
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();
  double _currentZoom = 14.0;

  final List<String> supportedCities = [
    'Ramallah',
    'Nablus',
    'Bethlehem',
    'Hebron',
    'Jericho',
    'Tulkarm',
    'Jenin',
    'Qalqilya',
    'Salfit',
    'Tubas',
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await Permission.location.request();

    if (permission.isGranted) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final current = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = current;
        _mapCenter = current;
      });

      await _loadTruckMarkers();
      _flyTo(current);
    } else {
      _showCitySelector();
    }
  }

  Future<void> _loadTruckMarkers() async {
    try {
      final trucks =
          await TruckOwnerService.getPublicTrucks(city: selectedCity);
      _markers.clear();

      for (var truck in trucks) {
        final lat = truck['location']['latitude'];
        final lng = truck['location']['longitude'];
        final name = truck['truck_name'];

        _markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 60,
            height: 60,
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.orange, size: 36),
                Text(name, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      }

      setState(() {});
    } catch (e) {
      print('❌ Error loading trucks: $e');
    }
  }

  Future<void> _showCitySelector() async {
    final city = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: supportedCities.map((city) {
            return ListTile(
              title: Text(city),
              onTap: () => Navigator.pop(context, city),
            );
          }).toList(),
        );
      },
    );

    if (city != null) {
      selectedCity = city;
      final locations = await locationFromAddress('$city, Palestine');

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _currentLatLng = latLng;
          _mapCenter = latLng;
        });

        _flyTo(latLng);
        await _loadTruckMarkers();
      }
    }
  }

  void _flyTo(LatLng target) {
    _mapCenter = target;
    _mapController.move(target, _currentZoom);
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(4.0, 18.0);
    _mapController.move(_mapCenter, _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(4.0, 18.0);
    _mapController.move(_mapCenter, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCity != null
              ? 'Trucks in $selectedCity'
              : 'Nearby Food Trucks',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            tooltip: 'Choose City',
            onPressed: _showCitySelector,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              if (_currentLatLng != null) {
                _loadTruckMarkers();
              }
            },
          ),
        ],
      ),
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLatLng!,
                    initialZoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        onPressed: _zoomIn,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        onPressed: _zoomOut,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
