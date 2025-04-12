import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:refillproo/navs/bottom_nav.dart';
import 'package:http/http.dart' as http;  // Don't forget to import http
import 'dart:convert';  // Import for JSON decoding
import 'package:refillproo/pages/order_form.dart';


class MapPage extends StatefulWidget {
  final bool showDialogOnLoad;

  const MapPage({super.key, this.showDialogOnLoad = false});

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
  _checkLocationAndShow();
  mapController = MapController();
  

  // Only show the dialog if this page was pushed with showDialogOnLoad = true
  if (widget.showDialogOnLoad) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialog();
    });
  }
}

void _showDialog() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Image.asset(
        'images/order_msg.png',
        width: MediaQuery.of(context).size.width * 0.8,
        fit: BoxFit.contain,
      ),
    ),
  );

  // Auto-close after 1 seconds if still mounted
  Future.delayed(const Duration(milliseconds: 1000), () {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
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
                                image: AssetImage("images/location1.jpg"),
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
                        Navigator.pop(context); 
                        _showInquirySheet(context);// Close the dialog
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

  void _showInquirySheet(BuildContext context) {
  // Variables to track state
  bool borrowGallon = false;
  bool ownedGallon = false;
  int regularGallonCount = 1;
  int dispenserGallonCount = 0;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      // Get MediaQuery data for responsive sizing
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      
      // Calculate responsive dimensions
      final sheetHeight = screenHeight * 0.4; // 40% of screen height
      final sheetWidth = screenWidth;
      final gallonContainerWidth = screenWidth * 0.35;
      final gallonContainerHeight = sheetHeight * 0.55;
      
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          // Calculate total based on selected items
          double total = (regularGallonCount + dispenserGallonCount) * 30.00;
          
          return Container(
            width: sheetWidth,
            height: sheetHeight,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF455567),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
            child: Stack(
              children: [
                // Top handle indicator
                Positioned(
                  left: sheetWidth * 0.3,
                  top: sheetHeight * 0.012,
                  child: Container(
                    width: sheetWidth * 0.4,
                    height: sheetHeight * 0.012,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Title - Gallon Available
                Positioned(
                  left: sheetWidth * 0.25,
                  top: sheetHeight * 0.1,
                  child: SizedBox(
                    width: sheetWidth * 0.5,
                    height: sheetHeight * 0.12,
                    child: Text(
                      'Gallon Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.06,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                
                // Regular Gallon Container
                Positioned(
                  left: sheetWidth * 0.13,
                  top: sheetHeight * 0.23,
                  child: Container(
                    width: gallonContainerWidth,
                    height: gallonContainerHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1F2937),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                
                // Regular Gallon Image
                Positioned(
                  left: sheetWidth * 0.18,
                  top: sheetHeight * 0.24,
                  child: Container(
                    width: gallonContainerWidth * 0.7,
                    height: gallonContainerHeight * 0.87,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/regular_gallon.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Regular Gallon Counter
                Positioned(
                  left: sheetWidth * 0.18,
                  top: sheetHeight * 0.71,
                  child: Container(
                    width: gallonContainerWidth * 0.7,
                    height: sheetHeight * 0.04,
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
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.remove, size: screenWidth * 0.03),
                          onPressed: () {
                            setState(() {
                              if (regularGallonCount > 0) {
                                regularGallonCount--;
                              }
                            });
                          },
                        ),
                        
                        // Count display
                        Text(
                          '$regularGallonCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.025,
                            fontFamily: 'Righteous',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        
                        // Increment button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.add, size: screenWidth * 0.03),
                          onPressed: () {
                            setState(() {
                              regularGallonCount++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Regular Gallon Price
                Positioned(
                  left: sheetWidth * 0.2,
                  top: sheetHeight * 0.77,
                  child: SizedBox(
                    width: gallonContainerWidth * 0.6,
                    height: sheetHeight * 0.06,
                    child: Text(
                      '₱30.00',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFE5E7EB),
                        fontSize: screenWidth * 0.025,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                  ),
                ),
                
                // Regular Gallon Text
                Positioned(
                  left: sheetWidth * 0.2,
                  top: sheetHeight * 0.81,
                  child: SizedBox(
                    width: gallonContainerWidth * 0.6,
                    height: sheetHeight * 0.06,
                    child: Text(
                      'Regular Gallon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFE5E7EB),
                        fontSize: screenWidth * 0.025,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                  ),
                ),
                
                // Dispenser Gallon Container
                Positioned(
                  left: sheetWidth * 0.53,
                  top: sheetHeight * 0.23,
                  child: Container(
                    width: gallonContainerWidth,
                    height: gallonContainerHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1F2937),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                
                // Dispenser Gallon Image
                Positioned(
                  left: sheetWidth * 0.6,
                  top: sheetHeight * 0.24,
                  child: Container(
                    width: gallonContainerWidth * 0.57,
                    height: gallonContainerHeight * 0.87,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/dispenser_gallon.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Dispenser Gallon Counter
                Positioned(
                  left: sheetWidth * 0.58,
                  top: sheetHeight * 0.71,
                  child: Container(
                    width: gallonContainerWidth * 0.7,
                    height: sheetHeight * 0.04,
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
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.remove, size: screenWidth * 0.03),
                          onPressed: () {
                            setState(() {
                              if (dispenserGallonCount > 0) {
                                dispenserGallonCount--;
                              }
                            });
                          },
                        ),
                        
                        // Count display
                        Text(
                          '$dispenserGallonCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.025,
                            fontFamily: 'Righteous',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        
                        // Increment button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.add, size: screenWidth * 0.03),
                          onPressed: () {
                            setState(() {
                              dispenserGallonCount++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Dispenser Gallon Price
                Positioned(
                  left: sheetWidth * 0.6,
                  top: sheetHeight * 0.77,
                  child: SizedBox(
                    width: gallonContainerWidth * 0.6,
                    height: sheetHeight * 0.06,
                    child: Text(
                      '₱30.00',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFE5E7EB),
                        fontSize: screenWidth * 0.025,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                  ),
                ),
                
                // Dispenser Gallon Text
                Positioned(
                  left: sheetWidth * 0.6,
                  top: sheetHeight * 0.81,
                  child: SizedBox(
                    width: gallonContainerWidth * 0.6,
                    height: sheetHeight * 0.06,
                    child: Text(
                      'Dispenser Gallon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFE5E7EB),
                        fontSize: screenWidth * 0.025,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                  ),
                ),
                
                // Total text
                Positioned(
                  left: sheetWidth * 0.19,
                  top: sheetHeight * 0.91,
                  child: SizedBox(
                    width: sheetWidth * 0.35,
                    height: sheetHeight * 0.05,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Total: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: '₱${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Borrow gallon checkbox
                Positioned(
                  left: sheetWidth * 0.04,
                  top: sheetHeight * 0.87,
                  child: Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.035,
                        height: screenHeight * 0.017,
                        child: Checkbox(
                          value: borrowGallon,
                          onChanged: (value) {
                            setState(() {
                              borrowGallon = value!;
                              if (borrowGallon) {
                                ownedGallon = false;
                              }
                            });
                          },
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF0F1A2B),
                          ),
                          checkColor: Colors.black,
                          fillColor: WidgetStateProperty.resolveWith(
                            (states) => const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      SizedBox(
                        width: screenWidth * 0.18,
                        child: Text(
                          'Borrow gallon',
                          style: TextStyle(
                            color: const Color(0xFFE5E7EB),
                            fontSize: screenWidth * 0.025,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Owned a gallon checkbox
                Positioned(
                  left: sheetWidth * 0.04,
                  top: sheetHeight * 0.92,
                  child: Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.035,
                        height: screenHeight * 0.017,
                        child: Checkbox(
                          value: ownedGallon,
                          onChanged: (value) {
                            setState(() {
                              ownedGallon = value!;
                              if (ownedGallon) {
                                borrowGallon = false;
                              }
                            });
                          },
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF0F1A2B),
                          ),
                          checkColor: Colors.black,
                          fillColor: WidgetStateProperty.resolveWith(
                            (states) => const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      SizedBox(
                        width: screenWidth * 0.18,
                        child: Text(
                          'Owned a gallon',
                          style: TextStyle(
                            color: const Color(0xFFE5E7EB),
                            fontSize: screenWidth * 0.025,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Review payment and address button
                Positioned(
                  left: sheetWidth * 0.47,
                  top: sheetHeight * 0.88,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderForm()),
                      );
                    },
                    child: Container(
                      width: sheetWidth * 0.5,
                      height: sheetHeight * 0.09,
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
                            fontSize: screenWidth * 0.025,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
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

