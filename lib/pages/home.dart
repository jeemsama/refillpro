// lib/pages/home.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:refillproo/navs/bottom_nav.dart';
import 'package:refillproo/navs/header.dart';
import 'package:refillproo/pages/activity.dart';
import 'package:refillproo/pages/map.dart';
import 'package:refillproo/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// A simple data‐class to hold store information and computed distance.
class Store {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  double distanceInMeters;

  Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distanceInMeters,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      distanceInMeters: 0.0, // will compute later
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // int _selectedQuizOption = -1;
  String? _customerName;

  int? _tappedStationId;

  // **NEW**: customer’s current position
  // ignore: unused_field
  Position? _currentPosition;

  // **NEW**: list of stores (with computed distance)
  List<Store> _stores = [];
  bool _isLoadingStores = true;
  String? _storesError;

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
    _determinePositionAndFetchStores();
  }

  /// Fetches the authenticated customer’s name, exactly as before.
  Future<void> _fetchCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.22:8000/api/customer/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _customerName = data['name'] as String?;
      });
    }
  }

  /// 1. Requests location permission
  /// 2. Gets current Position
  /// 3. Calls _fetchStoresFromApi() to load + sort stores by distance
  Future<void> _determinePositionAndFetchStores() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _storesError = 'Location services are disabled.';
        _isLoadingStores = false;
      });
      return;
    }

    // 2. Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _storesError = 'Location permissions are denied.';
          _isLoadingStores = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _storesError = 'Location permissions are permanently denied.';
        _isLoadingStores = false;
      });
      return;
    }

    // 3. If permission granted, get current position:
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });

      // 4. With position in hand, fetch and process stores:
      await _fetchStoresFromApi(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _storesError = 'Failed to get location: $e';
        _isLoadingStores = false;
      });
    }
  }

  /// Fetches all stores from backend, computes distance, sorts list.
  Future<void> _fetchStoresFromApi(double userLat, double userLng) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) {
      setState(() {
        _storesError = 'No auth token found.';
        _isLoadingStores = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:8000/api/customer/stores'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Store> fetchedStores = jsonList
            .map((item) => Store.fromJson(item as Map<String, dynamic>))
            .toList();

        // Compute distance for each store and sort
        for (var store in fetchedStores) {
          final distMeters = Geolocator.distanceBetween(
            userLat,
            userLng,
            store.latitude,
            store.longitude,
          );
          store.distanceInMeters = distMeters;
        }
        fetchedStores.sort((a, b) => a.distanceInMeters
            .compareTo(b.distanceInMeters)); // nearest→farthest

        setState(() {
          _stores = fetchedStores;
          _isLoadingStores = false;
        });
      } else {
        setState(() {
          _storesError = 'Failed to load stores (code ${response.statusCode}).';
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      setState(() {
        _storesError = 'Error fetching stores: $e';
        _isLoadingStores = false;
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final formatted = DateFormat('h:mm a • EEEE, MMMM d, y').format(now);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_greeting()}, ${_customerName ?? ''}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'PoppinsExtraBold',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatted,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    final tip = [
      'Drink at least 8 glasses of water each day to stay hydrated.',
      'Cold water can help boost your metabolism slightly.',
      'Carry a reusable bottle to track and increase your intake.',
      'Infuse your water with fruits for added flavor and nutrients.',
      'Drinking water before meals can help with digestion and appetite control.',
    ][DateTime.now().day % 5];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(90),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tip of the Day',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **NEW**: Renders the list of stores sorted by distance.
  Widget _buildStoreList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always show this title:
          const Text(
            'Nearby Stores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'PoppinsExtraBold',
            ),
          ),
          const SizedBox(height: 8),

          // Now show one of: loader, error, “no stores”, or the list itself:
          if (_isLoadingStores)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_storesError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _storesError!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_stores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No stores found.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stores.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final store = _stores[index];
                final distKm =
                    (store.distanceInMeters / 1000).toStringAsFixed(2);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  title: Text(
                    store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    '${store.address}\n$distKm km away',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                  isThreeLine: true,
                  leading: const Icon(Icons.store, color: Colors.teal),
                  onTap: () {
                    setState(() {
                      _tappedStationId = null;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _tappedStationId = store.id;
                        _selectedIndex = 1;
                      });
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // Widget _buildFeatureCard({
  //   required String title,
  //   required String subtitle,
  //   required IconData icon,
  //   required Color baseColor,
  // }) {
  //   return Container(
  //     width: 220,
  //     margin: const EdgeInsets.only(right: 12),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [baseColor.withAlpha(150), baseColor.withAlpha(60)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withAlpha(60),
  //           blurRadius: 6,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withAlpha(80),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, size: 28, color: baseColor),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //               fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
  //         ),
  //         const SizedBox(height: 6),
  //         Text(
  //           subtitle,
  //           style: const TextStyle(fontSize: 13, color: Colors.white70),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFlashcardRow() {
  //   return SizedBox(
  //     height: 180,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       children: [
  //         _buildFeatureCard(
  //           title: 'Water Refill',
  //           subtitle:
  //               'Order purified or alkaline water for delivery or pickup.',
  //           icon: Icons.water_drop,
  //           baseColor: Colors.blue,
  //         ),
  //         _buildFeatureCard(
  //           title: 'Container Pickup',
  //           subtitle: 'We collect used containers based on your schedule.',
  //           icon: Icons.recycling,
  //           baseColor: Colors.green,
  //         ),
  //         _buildFeatureCard(
  //           title: 'Sanitizing',
  //           subtitle: 'Ensure your containers are safe and hygienic.',
  //           icon: Icons.cleaning_services,
  //           baseColor: Colors.purple,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildQuizCard() {
  //   const question = 'How many glasses have you drunk today?';
  //   final options = ['0', '1', '2', '3', '4', '5+'];
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Colors.orange.shade400, Colors.orange.shade200],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withAlpha(90),
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withAlpha(80),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(Icons.quiz, size: 28, color: Colors.orange),
  //             ),
  //             const SizedBox(width: 12),
  //             const Text(
  //               'Quick Poll',
  //               style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 18,
  //                   color: Colors.white),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           question,
  //           style: const TextStyle(fontSize: 15, color: Colors.white),
  //         ),
  //         const SizedBox(height: 12),
  //         Wrap(
  //           spacing: 8,
  //           children: List.generate(options.length, (i) {
  //             final selected = _selectedQuizOption == i;
  //             return ChoiceChip(
  //               label: Text(
  //                 options[i],
  //                 style: TextStyle(
  //                     color: selected
  //                         ? Colors.orange.shade900
  //                         : const Color.fromARGB(255, 19, 19, 19)),
  //               ),
  //               selected: selected,
  //               backgroundColor: Colors.white.withAlpha(60),
  //               selectedColor: Colors.white.withAlpha(150),
  //               onSelected: (_) =>
  //                   setState(() => _selectedQuizOption = selected ? -1 : i),
  //             );
  //           }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// **NEW**: Called when user pulls down to refresh on Home.
  /// Called when user pulls down to refresh on Home.
  Future<void> _refreshHome() async {
    setState(() {
      // show the loading spinner and clear out any previous errors
      _isLoadingStores = true;
      _storesError = null;

      // clear the store list so the old items go away immediately (optional)
      _stores = [];

      // reset the tappedStationId so the next onTap will fire even if it's the same id
      _tappedStationId = null;
    });

    // re‐fetch both name and stores
    await _fetchCustomerName();
    await _determinePositionAndFetchStores();
  }

  Widget _buildHomeContent() {
    // Wrap the entire scrollable column in a RefreshIndicator:
    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // AlwaysScrollableScrollPhysics makes sure pull works even if content < viewport.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            _buildTipCard(),
            // **NEW**: store list
            _buildStoreList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      MapPage(initialStationId: _tappedStationId),
      const ActivityPage(),
      Profile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEC),
      appBar: _selectedIndex != 3
          ? const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppHeader(),
            )
          : null,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          if (_selectedIndex != 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
        ],
      ),
    );
  }
}
