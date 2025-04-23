import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:refillproo/navs/bottom_nav.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/refilling_station.dart';




import 'package:permission_handler/permission_handler.dart'; 

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  List<RefillingStation> _stations = [];
  List<LatLng> _routePoints = []; // Added missing declaration



  @override
  void initState() {
    super.initState();
    _determinePosition();
  }


Future<void> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    _showLocationServiceDialog();
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showLocationPermissionDialog();
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    _showLocationPermissionDialog();
    return;
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high
    )
  );
  
  setState(() {
    _userLocation = LatLng(position.latitude, position.longitude);
    // If you want to include the _locationLoaded flag as in your old code
    // _locationLoaded = true;
  });

  // If you want to move the map to the user's location as in your old code
  // mapController.move(_userLocation, 17.0);

  await _fetchRefillStations();
}

void _showLocationServiceDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Location Services Disabled"),
      content: Text("Please enable location services to view your location."),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
          child: Text("Open Settings"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
    ),
  );
}

  Future<void> _fetchRefillStations() async {
    final url = Uri.parse('http://192.168.43.167:8000/api/v1/refill-stations'); // <- Replace with your actual API endpoint
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _stations = data.map((json) => RefillingStation.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      debugPrint("Error fetching stations: $e");
    }
  }

  //Refilling station dialog style
  Future<void> _showStationDialog(RefillingStation station) async {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        backgroundColor: const Color(0xFF0F1A2B),
        child: SizedBox(
          width: 363,
          height: 206,
          child: Stack(
            children: [
              // Station Name
              Positioned(
                left: 38,
                top: 20,
                child: SizedBox(
                  width: 234,
                  height: 20,
                  child: Text(
                    station.shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // Address
              Positioned(
                left: 40,
                top: 41,
                child: Text(
                  station.address,
                  style: const TextStyle(
                    color: Color(0xFFB2B2B2),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Shop Image - Circular
              Positioned(
                left: 38,
                top: 71,
                child: Container(
                  width: 116,
                  height: 110,
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
                              image: NetworkImage(station.shopPhoto),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Show Route Button
              Positioned(
                left: 182,
                top: 82,
                child: GestureDetector(
                  onTap: () {
                    if (_userLocation != null) {
                      _showRouteTo(LatLng(station.latitude, station.longitude));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User location not available')),
                      );
                    }
                  },
                  child: Container(
                    width: 139,
                    height: 41,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD1CFC9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Show route',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF0F1A2B),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Inquire Button
              Positioned(
                left: 182,
                top: 128,
                child: GestureDetector(
                  onTap: () {
                    
                    Navigator.pop(context); // Close the dialog
                    _showGallonBottomSheet(station);
                  },
                  child: Container(
                    width: 139,
                    height: 41,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFBDC4D4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Inquire',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF0F1A2B),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // Fetch the route from OpenRouteService API
  Future<void> _getRouteFromApi(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248a6164b7235ef4e3f860b56fb548d5a35&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
    );
  
    try {
      final response = await http.get(url);
    
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;
    
        List<LatLng> route = coords.map<LatLng>((c) => LatLng(c[1] as double, c[0] as double)).toList();
    
        if (mounted) {
          setState(() {
            _routePoints = route;
          });
          
          // Center the map to show the route
          if (route.isNotEmpty) {
            _mapController.move(route[0], 15);
          }
        }
      } else {
        debugPrint('Failed to get route: ${response.statusCode} - ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch route: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Show route when tag is tapped
  void _showRouteTo(LatLng destination) {
    if (_userLocation != null) {
      _getRouteFromApi(_userLocation!, destination);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User location not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: _userLocation != null
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: 19.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Route polyline - Fixed position in layer stack
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: const Color(0xFF034C53),
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // User marker
                    Marker(
                      point: _userLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    // Red markers for stations
                    ..._stations.map((station) => Marker(
                          point: LatLng(station.latitude, station.longitude),
                          width: 30,
                          height: 30,
                          child: GestureDetector(
                            onTap: () => _showStationDialog(station),
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 30),
                          ),
                        )),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
  
void _showGallonBottomSheet(RefillingStation station) {
  // Counter variables for each gallon type
  int regularGallonCount = 0;
  int dispenserGallonCount = 0;
  int smallGallonCount = 0;
  bool borrowGallon = false;
  bool swapGallon = false;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Calculate total based on selections
          double total = (regularGallonCount * (station.regularGallonPrice ?? 0)) +
                        (dispenserGallonCount * (station.dispenserGallonPrice ?? 0)) +
                        (smallGallonCount * (station.smallGallonPrice ?? 0));
          
          // Get screen dimensions for responsive layout
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          
          // Create a list of available gallon widgets
          List<Widget> gallonWidgets = [];
          
          // Add Regular Gallon if available
          if (station.hasRegularGallon) {
            gallonWidgets.add(
              _buildGallonWidget(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                imagePath: 'assets/images/regular_gallon.png',
                count: regularGallonCount,
                price: station.regularGallonPrice,
                title: 'Regular Gallon',
                onIncrement: () {
                  setState(() {
                    regularGallonCount++;
                  });
                },
                onDecrement: () {
                  if (regularGallonCount > 0) {
                    setState(() {
                      regularGallonCount--;
                    });
                  }
                },
              ),
            );
          }
          
          // Add Dispenser Gallon if available
          if (station.hasDispenserGallon) {
            gallonWidgets.add(
              _buildGallonWidget(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                imagePath: 'assets/images/dispenser_gallon.png',
                count: dispenserGallonCount,
                price: station.dispenserGallonPrice,
                title: 'Dispenser Gallon',
                onIncrement: () {
                  setState(() {
                    dispenserGallonCount++;
                  });
                },
                onDecrement: () {
                  if (dispenserGallonCount > 0) {
                    setState(() {
                      dispenserGallonCount--;
                    });
                  }
                },
              ),
            );
          }
          
          // Add Small Gallon if available
          if (station.hasSmallGallon) {
            gallonWidgets.add(
              _buildGallonWidget(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                imagePath: 'assets/images/small_gallon.png',
                count: smallGallonCount,
                price: station.smallGallonPrice,
                title: 'Small Gallon',
                onIncrement: () {
                  setState(() {
                    smallGallonCount++;
                  });
                },
                onDecrement: () {
                  if (smallGallonCount > 0) {
                    setState(() {
                      smallGallonCount--;
                    });
                  }
                },
              ),
            );
          }
          
          return Container(
            width: screenWidth,
            height: screenHeight * 0.5, // Take up about half the screen
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              color: Color(0xFF455567),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
            child: Column(
              children: [
                // Handle bar at the top
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    width: screenWidth * 0.3,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Title
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: const Text(
                    'Gallon Available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                
                // Gallon Options - Automatically centered and spaced
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: gallonWidgets,
                  ),
                ),
                
                Spacer(),
                
                // Bottom Section - Checkboxes & Total
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    bottom: screenHeight * 0.01,
                  ),
                  child: Row(
                    children: [
                      // Checkbox for "Borrow gallon"
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            borrowGallon = !borrowGallon;
                            if (borrowGallon) swapGallon = false;
                          });
                        },
                        child: Container(
                          width: 14,
                          height: 11,
                          decoration: ShapeDecoration(
                            color: borrowGallon ? Color(0xFFD9D9D9) : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF0F1A2B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Borrow gallon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 10,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                      SizedBox(width: 15),
                      // Checkbox for "Swap gallon"
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            swapGallon = !swapGallon;
                            if (swapGallon) borrowGallon = false;
                          });
                        },
                        child: Container(
                          width: 14,
                          height: 11,
                          decoration: ShapeDecoration(
                            color: swapGallon ? Color(0xFFD9D9D9) : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF0F1A2B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Swap gallon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 10,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Total and button row
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    right: screenWidth * 0.04,
                    bottom: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Total: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '₱${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Button - Review payment and address
                      GestureDetector(
                        onTap: () {
                          // Implement review and payment logic
                          if (regularGallonCount > 0 || dispenserGallonCount > 0 || smallGallonCount > 0) {
                            // Navigate to payment page or handle payment logic
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Proceeding to payment...'))
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select at least one gallon'))
                            );
                          }
                        },
                        child: Container(
                          width: screenWidth * 0.48,
                          height: 33,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF0F1A2B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Review payment and address',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper method to build gallon widget
Widget _buildGallonWidget({
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String imagePath,
  required int count,
  required double? price,
  required String title,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
}) {
  return Column(
    children: [
      // Image container
      Container(
        width: screenWidth * 0.29,
        height: screenHeight * 0.20,
        decoration: ShapeDecoration(
          color: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return Text('Image failed to load');
          },
        ),
      ),
      
      // Counter
      Container(
        width: screenWidth * 0.18,
        height: screenHeight * 0.024,
        margin: EdgeInsets.only(top: 8),
        decoration: ShapeDecoration(
          color: const Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decrement button
            GestureDetector(
              onTap: onDecrement,
              child: Container(
                width: screenWidth * 0.05,
                alignment: Alignment.center,
                child: Text('-', style: TextStyle(fontSize: 16)),
              ),
            ),
            // Counter
            Text(
              '$count',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Righteous',
                fontWeight: FontWeight.w400,
              ),
            ),
            // Increment button
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: screenWidth * 0.05,
                alignment: Alignment.center,
                child: Text('+', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      
      // Price
      SizedBox(height: 5),
      Text(
        '₱${price?.toStringAsFixed(2) ?? '0.00'}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFFE5E7EB),
          fontSize: 10,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          height: 2,
        ),
      ),
      
      // Title
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFFE5E7EB),
          fontSize: 10,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          height: 2,
        ),
      ),
    ],
  );
}
  
}