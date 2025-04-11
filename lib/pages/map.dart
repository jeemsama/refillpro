import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:refillproo/navs/bottom_nav.dart';
import 'package:http/http.dart' as http;  // Don't forget to import http
import 'dart:convert';  // Import for JSON decoding

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late MapController mapController;
  LatLng _userLocation = LatLng(17.6600, 121.7484);
  bool _locationLoaded = false;
  List<LatLng> _routePoints = []; // Changed to final

  final LatLng _sampleTagLocation = LatLng(17.63395589239909, 121.73370455773755);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationAndShow();
    });
  }

  Future<void> _checkLocationAndShow() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
        mapController.move(_userLocation, 17.0);
      } else {
        _showLocationServiceDialog();
      }
    } else {
      _showLocationPermissionDialog();
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Services Disabled"),
        content: Text("Please enable location services to view your location."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Denied"),
        content: Text("Please grant location permission to view your location."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text("Open Settings"),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ],
      ),
    );
  }

  // Fetch the route from OpenRouteService API
  Future<void> _getRouteFromApi(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248a6164b7235ef4e3f860b56fb548d5a35&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
    );
  
    final response = await http.get(url);
  
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
  
      List<LatLng> route = coords.map((c) => LatLng(c[1], c[0])).toList();
  
      if (mounted) {
        setState(() {
          _routePoints = route;
        });
      }
    } else {
      debugPrint('Failed to get route: ${response.body}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch route from API')),
        );
      }
    }
  }


  // Show route when tag is tapped
  void _showRouteTo(LatLng destination) {
    _getRouteFromApi(_userLocation, destination);
  }

  // The function that runs when a tag is tapped
  void _onTagTapped(LatLng tagLocation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 363,
            height: 206,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF0F1A2B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 59,
                  child: Container(
                    width: 121,
                    height: 121,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(86),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: -17,
                          top: 0,
                          child: Container(
                            width: 178.67,
                            height: 134,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/location1.jpeg"),
                                fit: BoxFit.cover,
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 38,
                  top: 20,
                  child: SizedBox(
                    width: 234,
                    height: 16,
                    child: Text(
                      'Nhorlen’s water station',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 182,
                  top: 73,
                  child: Container(
                    width: 139,
                    height: 41,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD1CFC9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _showRouteTo(tagLocation);  // Trigger showing the route
                        Navigator.pop(context);
                      },
                      child: Text('Show route', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
                Positioned(
                  left: 182,
                  top: 120,
                  child: Container(
                    width: 139,
                    height: 41,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFBDC4D4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Inquire', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _userLocation,
          initialZoom: 17.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (_locationLoaded)
                Marker(
                  point: _userLocation,
                  width: 20,
                  height: 20,
                  child: GestureDetector(
                    onTap: () => _showUserLocationDialog(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              Marker(
                point: _sampleTagLocation,
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: () => _onTagTapped(_sampleTagLocation),
                  child: Icon(Icons.location_on, color: Colors.red, size: 30),
                ),
              ),
            ],
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  color: Color(0xFF034C53),
                  strokeWidth: 15,
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }

  void _showUserLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Your Location"),
        content: Text("Latitude: ${_userLocation.latitude}\nLongitude: ${_userLocation.longitude}"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        break;
    }
  }
}
