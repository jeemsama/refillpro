import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:http/http.dart' as http;
// import 'package:refillproo/models/order.dart';
// import 'package:refillproo/models/order.dart';
import 'package:refillproo/pages/order_form.dart'; // Ensure this import is correct and the OrderForm class exists in this file
import 'dart:convert';
import '../models/refilling_station.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/owner_shop_details.dart'; // ← add this import
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  final int? initialStationId;
  const MapPage({super.key, this.initialStationId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _locationSaved = false;
  LatLng? _userLocation;
  String? _userAddress;
  final MapController _mapController = MapController();
  List<RefillingStation> _stations = [];
  List<LatLng> _routePoints = [];

  /// Track whether we've already auto‐shown the dialog for a given station ID.
  int? _alreadyShownForStationId;

  @override
  void initState() {
    super.initState();
    _checkIfLocationAlreadySaved();
    _determinePosition();
  }

  Future<void> _checkIfLocationAlreadySaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locationSaved = prefs.getBool('location_saved') ?? false;
    });
  }

  /// Whenever the widget is rebuilt with a new initialStationId, we want to
  /// re‐run the “center + show dialog” logic—provided we’ve already loaded _stations.
  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If Home has reset initialStationId to null, clear our “already shown” marker:
    if (widget.initialStationId == null) {
      _alreadyShownForStationId = null;
    }

    // Now, if Home has given us a non-null ID we haven’t shown yet, run it:
    if (widget.initialStationId != null &&
        widget.initialStationId != oldWidget.initialStationId &&
        _stations.isNotEmpty) {
      _centerAndShowDialog(widget.initialStationId!);
    }
  }

  Future<void> _determinePosition() async {
    // 1) Ensure GPS is enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      return _showLocationServiceDialog();
    }
    // 2) Request/check permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        return _showLocationPermissionDialog();
      }
    }
    if (perm == LocationPermission.deniedForever) {
      return _showLocationPermissionDialog();
    }
    // 3) Get current GPS coords
    final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
    final ll = LatLng(pos.latitude, pos.longitude);
    setState(() => _userLocation = ll);

    // 4) Reverse-geocode into street address
    await _getAddressFor(ll);

    // 5) Fetch your refill-station markers
    await _fetchRefillStations();
  }

  Future<void> _getAddressFor(LatLng ll) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(ll.latitude, ll.longitude);
      final pm = placemarks.first;
      setState(() {
        _userAddress = "${pm.street}, ${pm.locality}, ${pm.administrativeArea}";
      });
    } catch (e) {
      debugPrint("Reverse‐geocode failed: $e");
      setState(() => _userAddress = "Unknown location");
    }
  }

  Future<void> _saveLocation() async {
    if (_userLocation == null || _userAddress == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saved_lat', _userLocation!.latitude);
    await prefs.setDouble('saved_lng', _userLocation!.longitude);
    await prefs.setString('saved_address', _userAddress!);
    await prefs.setBool('location_saved', true);

    if (!mounted) return;
    setState(() => _locationSaved = true); // ← this hides the check button

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location saved!')),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text(
            "Please enable location services to view your location."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Geolocator.openLocationSettings();
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text(
            "Please grant location permission to view your location."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

// Future<void> _fetchRefillStations() async {
//   final url = Uri.parse('http://192.168.1.22:8000/api/v1/refill-stations');
//   try {
//     final response = await http.get(
//       url,
//       headers: {'Accept': 'application/json'},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to load stations (${response.statusCode})');
//     }

//     final decoded = json.decode(response.body);
//       // handle both: plain List or { data: List }
//       final List<dynamic> list =
//           decoded is List ? decoded : (decoded['data'] as List<dynamic>);

//       setState(() {
//         _stations = list
//             .map((item) =>
//                 RefillingStation.fromJson(item as Map<String, dynamic>))
//             .toList();
//       });
//       debugPrint('Stations loaded: ${_stations.map((s) => s.id).join(', ')}');
//     } catch (e) {
//       debugPrint('Error fetching stations: $e');
//     }
//   }

  Future<void> _fetchRefillStations() async {
    final url = Uri.parse('http://192.168.1.22:8000/api/v1/refill-stations');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load stations (${response.statusCode})');
      }

      final decoded = json.decode(response.body);
      // handle both: plain List or { data: List }
      final List<dynamic> list =
          decoded is List ? decoded : (decoded['data'] as List<dynamic>);

      setState(() {
        _stations = list
            .map((item) =>
                RefillingStation.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      debugPrint('Stations loaded: ${_stations.map((s) => s.id).join(', ')}');
      // ——— NEW: after stations load, if initialStationId was provided, open its dialog:

      // If initState provided an initialStationId, and we haven’t shown it yet,
      // center & show that dialog now:
      if (widget.initialStationId != null) {
        _centerAndShowDialog(widget.initialStationId!);
      }
    } catch (e) {
      debugPrint('Error fetching stations: $e');
    }
  }

  /// Centers the map on [stationId] and shows its dialog exactly once.
  void _centerAndShowDialog(int stationId) {
    // Avoid showing twice if the same ID comes in again
    if (_alreadyShownForStationId == stationId) return;
    _alreadyShownForStationId = stationId;

    // Find the station in the loaded list
    final station = _stations.firstWhere(
      (s) => s.id == stationId,
      orElse: () => _stations.first,
    );

    final center = LatLng(station.latitude, station.longitude);
    _mapController.move(center, 17.0);

    // Wait one frame for the map to move, then pop up the dialog:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStationDialog(station);
    });
  }

// Refilling station dialog style
  Future<void> _showStationDialog(
    RefillingStation station,
  ) async {
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
                  width: 280,
                  height: 25,
                  child: Text(
                    station.shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'PoppinsExtraBold',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // Address
              Positioned(
                left: 37,
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
              // Address
              Positioned(
                left: 37,
                top: 60,
                child: Text(
                  'OPEN',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 9, 255, 0),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              // Shop Image
              Positioned(
                left: 38,
                top: 83,
                child: Container(
                  width: 100,
                  height: 94,
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
                        const SnackBar(
                            content: Text('User location not available')),
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
                    child: const Center(
                      child: Text(
                        'Show route',
                        style: TextStyle(
                          color: Color(0xFF0F1A2B),
                          fontSize: 16,
                          fontFamily: 'PoppinsExtraBold',
                          fontWeight: FontWeight.w900,
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
                    Navigator.pop(context);
                    _fetchOwnerShopDetails(station.ownerId).then((details) {
                      final missingGallons = !details.hasRegularGallon &&
                          !details.hasDispenserGallon;
                      final missingSlots = details.deliveryTimeSlots.isEmpty;
                      final missingDays = details.collectionDays.isEmpty;

                      if (missingGallons || missingSlots || missingDays) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Not yet available. Coming soon.')),
                        );
                        return; // stop here
                      }

                      _showGallonBottomSheet(details, station);
                    }).catchError((e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not available. Coming soon.')),
                      );
                    });
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
                    child: const Center(
                      child: Text(
                        'Inquire',
                        style: TextStyle(
                          color: Color(0xFF0F1A2B),
                          fontSize: 16,
                          fontFamily: 'PoppinsExtraBold',
                          fontWeight: FontWeight.w900,
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

  // void _onTapNav(int index, BuildContext context) {
  //   switch (index) {
  //     case 0:
  //       Navigator.pushReplacementNamed(context, '/home');
  //       break;
  //     case 1:
  //       break;
  //     case 2:
  //       Navigator.pushReplacementNamed(context, '/activity');
  //       break;
  //     case 3:
  //       Navigator.pushReplacementNamed(context, '/profile');
  //       break;
  //   }
  // }

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

        List<LatLng> route = coords
            .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
            .toList();

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
        debugPrint(
            'Failed to get route: ${response.statusCode} - ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to fetch route: ${response.statusCode}')),
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
      body: _userLocation != null
          ? RefreshIndicator(
              onRefresh: _fetchRefillStations, // only reload stations
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        // ——— Your existing map ———
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _userLocation!,
                            initialZoom: 19.0,
                            maxZoom: 25.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            if (_routePoints.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _routePoints,
                                    color: const Color(0xFF034C53),
                                    strokeWidth: 9.0,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                // user marker
                                Marker(
                                  point: _userLocation!,
                                  width: 20,
                                  height: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                                // station markers
                                ..._stations.map((station) => Marker(
                                      point: LatLng(
                                          station.latitude, station.longitude),
                                      width: 60,
                                      height: 60,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showStationDialog(station),
                                        child: Image.asset(
                                          'images/store_tag1.png',
                                          width: 60,
                                          height: 60,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),

                        // ——— Floating Address Bar ———
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xff0F1A2B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.place, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _userAddress ?? 'Retrieving address…',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!_locationSaved)
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.white),
                                    onPressed: _saveLocation,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // Final updated _showGallonBottomSheet method
  void _showGallonBottomSheet(
    OwnerShopDetails station,
    RefillingStation details,
  ) {
    int regularGallon = 0;
    int dispenserGallon = 0;

    double getTotal() {
      return (regularGallon * station.regularGallonPrice) +
          (dispenserGallon * station.dispenserGallonPrice);
    }

    final double borrowPrice = station.borrowPrice;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 0,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF455567),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 129,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        'Select gallon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGallonCard(
                            label: 'Regular Gallon',
                            image: 'images/regular_gallon.png',
                            price: station.regularGallonPrice,
                            count: regularGallon,
                            onInc: () => setState(() => regularGallon++),
                            onDec: () => setState(() {
                              if (regularGallon > 0) regularGallon--;
                            }),
                          ),
                          _buildGallonCard(
                            label: 'Dispenser Gallon',
                            image: 'images/dispenser_gallon.png',
                            price: station.dispenserGallonPrice,
                            count: dispenserGallon,
                            onInc: () => setState(() => dispenserGallon++),
                            onDec: () => setState(() {
                              if (dispenserGallon > 0) dispenserGallon--;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Subtotal: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '₱${getTotal().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F1A2B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final totalGallons =
                                    regularGallon + dispenserGallon;
                                if (totalGallons == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Select at least 1 gallon')),
                                  );
                                  return;
                                }
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final customerId = prefs.getInt('customer_id');
                                if (customerId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please log in again')),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderForm(
                                      shopName: details.shopName,
                                      ownerName: details.ownerName,
                                      ownerShopDetails: station,
                                      borrowPrice: borrowPrice,
                                      regularGallon: regularGallon,
                                      dispenserGallon: dispenserGallon,
                                      borrow: false,
                                      swap: false,
                                      total: getTotal(),
                                      shopId: station.id,
                                      customerId: customerId,
                                      stationId: station.id,
                                      regularGallonImage:
                                          'images/regular_gallon.png',
                                      dispenserGallonImage:
                                          'images/dispenser_gallon.png',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGallonCard({
    required String label,
    required String image,
    required double price,
    required int count,
    required VoidCallback onInc,
    required VoidCallback onDec,
  }) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 170,
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        const SizedBox(height: 5),
        Container(
          width: 100,
          height: 25,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onTap: onDec, child: const Icon(Icons.remove, size: 12)),
              Text('$count',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                  onTap: onInc, child: const Icon(Icons.add, size: 12)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text('₱${price.toStringAsFixed(2)}',
            style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 10)),
        Text(label,
            style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 10)),
      ],
    );
  }

  Future<OwnerShopDetails> _fetchOwnerShopDetails(int ownerId) async {
    final url = Uri.parse(
      'http://192.168.1.22:8000/api/v1/shop-details/owner/$ownerId',
    );
    final resp = await http.get(url, headers: {
      'Accept': 'application/json',
    });
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body)['data'] as Map<String, dynamic>;
      return OwnerShopDetails.fromJson(data);
    }
    throw Exception('Failed to load shop details (${resp.statusCode})');
  }
}
