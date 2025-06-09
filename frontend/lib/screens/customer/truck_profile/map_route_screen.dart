import 'dart:async'; // For StreamSubscription
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_compass/flutter_compass.dart';

// --- Styles ---
const Color ffPrimaryColor = Color(0xFFFF6B35);
const Color ffOnPrimaryColor = Color(0xFFFFFFFF);
const Color ffOnSurfaceColor = Color(0xFF2D2D2D);
// ---

class MapRouteScreen extends StatefulWidget {
  final LatLng truckPosition;
  final String truckName;

  const MapRouteScreen({
    super.key,
    required this.truckPosition,
    required this.truckName,
  });

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> with TickerProviderStateMixin {
  // Your OpenRouteService API Key
  final String _orsApiKey = '5b3ce3597851110001cf6248f8616c270ca14ab89dcc5495a548f5d9';

  late final MapController _mapController;
  final List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // --- MODIFIED: State for live values ---
  // Store raw numeric values for calculations
  double _totalDistanceMeters = 0;
  double _totalDurationSeconds = 0;
  // Store formatted strings for display
  String _displayDistance = '';
  String _displayDuration = '';

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;
  LatLng? _currentPosition;
  double _currentHeading = 0.0;
  bool _isNavigating = false;

  List<dynamic> _steps = [];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _generateRoute();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- NEW: Helper to format seconds into a readable string ---
  String _formatDuration(double seconds) {
    if (seconds < 0) seconds = 0;
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    } else {
      return '${minutes.ceil()} min';
    }
  }

  Future<void> _generateRoute() async {
    if (_orsApiKey == 'YOUR_OPENROUTESERVICE_API_KEY_HERE') {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API Key is missing.\nPlease add your OpenRouteService API key.';
      });
      return;
    }

    final userStartPos = await _determinePosition();
    if (userStartPos == null) {
      // Error message is set within _determinePosition
      if(mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _currentPosition = LatLng(userStartPos.latitude, userStartPos.longitude));

    try {
      final response = await http.get(Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_orsApiKey&start=${_currentPosition!.longitude},${_currentPosition!.latitude}&end=${widget.truckPosition.longitude},${widget.truckPosition.latitude}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'] as List;
        final points = coordinates.map((p) => LatLng(p[1] as double, p[0] as double)).toList();

        final segments = data['features'][0]['properties']['segments'] as List;
        if(segments.isNotEmpty) _steps = segments[0]['steps'];

        // *** MODIFIED: Store raw totals and set initial display values ***
        final summary = data['features'][0]['properties']['summary'];
        _totalDistanceMeters = summary['distance'];
        _totalDurationSeconds = summary['duration'];

        if (mounted) {
          setState(() {
            _routePoints.addAll(points);
            _displayDistance = '${(_totalDistanceMeters / 1000).toStringAsFixed(1)} km';
            _displayDuration = _formatDuration(_totalDurationSeconds);
            _isLoading = false;
          });
          _mapController.fitCamera(CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([_currentPosition!, widget.truckPosition]),
            padding: const EdgeInsets.all(100.0),
          ));
        }
      } else {
        throw Exception('Failed to load route: ${response.body}');
      }
    } catch (e) {
      if(mounted) setState(() {
        _isLoading = false;
        _errorMessage = 'Could not get route. Please check connection and API key.';
      });
    }
  }

  void _toggleNavigation() {
    setState(() => _isNavigating = !_isNavigating);
    if (_isNavigating) {
      _startListeningToLocation();
    } else {
      _positionStream?.cancel();
      _compassStream?.cancel();
      if(_currentPosition != null) _animatedMapMove(_currentPosition!, 15.0, 0.0);

      // *** MODIFIED: Reset display values when stopping navigation ***
      setState(() {
        _displayDistance = '${(_totalDistanceMeters / 1000).toStringAsFixed(1)} km';
        _displayDuration = _formatDuration(_totalDurationSeconds);
        _currentStepIndex = 0; // Reset step index
      });
    }
  }

  void _startListeningToLocation() {
    _positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((Position position) {
      if(!mounted) return;
      setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
      _updateNavigationStep(); // Check for step completion and update UI
      if (_isNavigating) _animatedMapMove(_currentPosition!, 17.0, _currentHeading);
    });

    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) setState(() => _currentHeading = event.heading ?? 0);
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom, double destRotation) {
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);
    final rotateTween = Tween<double>(begin: _mapController.camera.rotation, end: destRotation);
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.addListener(() => _mapController.moveAndRotate(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation), rotateTween.evaluate(animation)));
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) controller.dispose();
    });
    controller.forward();
  }

  void _updateNavigationStep() {
    if (_currentStepIndex >= _steps.length - 1 || _currentPosition == null) return;
    final nextStep = _steps[_currentStepIndex + 1];
    final nextStepLocation = _routePoints[nextStep['way_points'][0]];
    final distance = const Distance().as(LengthUnit.Meter, _currentPosition!, nextStepLocation);

    if(distance < 25) {
      if(mounted) {
        // *** MODIFIED: Update remaining distance and duration ***
        double remainingSeconds = _totalDurationSeconds;
        double remainingMeters = _totalDistanceMeters;
        // Sum up the values of all completed steps
        for(int i = 0; i <= _currentStepIndex; i++){
          remainingSeconds -= _steps[i]['duration'];
          remainingMeters -= _steps[i]['distance'];
        }

        setState(() {
          _currentStepIndex++; // Advance to the next step
          _displayDistance = '${(remainingMeters / 1000).toStringAsFixed(1)} km';
          _displayDuration = _formatDuration(remainingSeconds);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNavigating ? "Navigating..." : 'Route to ${widget.truckName}'),
        backgroundColor: ffPrimaryColor,
        foregroundColor: ffOnPrimaryColor,
      ),
      // *** REMOVED: floatingActionButton from here to prevent overlap ***
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: widget.truckPosition, initialZoom: 14),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.app'),
              if (_routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _routePoints, color: ffPrimaryColor, strokeWidth: 5)]),
              if (_currentPosition != null)
                MarkerLayer(markers: [
                  Marker(point: widget.truckPosition, child: const Icon(Icons.location_on, size: 50, color: ffPrimaryColor)),
                  Marker(point: _currentPosition!, width: 80, height: 80, child: Transform.rotate(angle: (_currentHeading * (3.14159 / 180)),
                    child: _isNavigating ? const Icon(Icons.navigation, size: 40, color: Colors.blue) : const Icon(Icons.my_location, size: 40, color: Colors.blueAccent),
                  )),
                ]),
            ],
          ),

          // --- UI OVERLAYS ---
          if (_isLoading) const Center(child: CircularProgressIndicator(color: ffPrimaryColor)),
          if (_errorMessage.isNotEmpty) Center(child: Container(padding: const EdgeInsets.all(20), color: Colors.white.withOpacity(0.8),
            child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
          )),

          // Top turn-by-turn instruction card
          if (_isNavigating && _steps.isNotEmpty)
            Positioned(top: 0, left: 0, right: 0, child: Card(margin: const EdgeInsets.all(12), elevation: 8,
              child: Padding(padding: const EdgeInsets.all(12.0),
                child: Text(_steps[_currentStepIndex]['instruction'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            )),

          // *** ADDED: Bottom distance and duration card that is always visible when a route is loaded ***
          if (_routePoints.isNotEmpty)
            Positioned(bottom: 20, left: 20, right: 20, child: Card(elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(padding: const EdgeInsets.all(16.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(Icons.timer_rounded, _displayDuration, 'Time Left'),
                    _buildInfoColumn(Icons.directions_car_filled_rounded, _displayDistance, 'Distance Left'),
                  ],
                ),
              ),
            )),

          // *** MODIFIED: Positioned "Start/Stop" button to prevent overlap ***
          if (_routePoints.isNotEmpty && !_isLoading)
            Positioned(
              bottom: 120, // Positioned above the bottom card
              right: 20,
              child: FloatingActionButton(
                onPressed: _toggleNavigation,
                backgroundColor: _isNavigating ? Colors.red : ffPrimaryColor,
                child: Icon(_isNavigating ? Icons.stop_rounded : Icons.navigation_rounded, color: ffOnPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: ffPrimaryColor, size: 30),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ffOnSurfaceColor)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
    ]);
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) setState(() => _errorMessage = 'Location services are disabled.');
      return null;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() => _errorMessage = 'Location permissions are denied.');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if(mounted) setState(() => _errorMessage = 'Location permissions are permanently denied.');
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }
}