// lib/pages/home.dart

import 'dart:async';
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
import 'package:refillproo/models/order.dart';
import 'package:refillproo/services/api_service.dart';

import 'package:refillproo/pages/order_form.dart';
// import 'package:refillproo/services/api_service.dart';


/// Simple data‐class to hold store information and computed distance.
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
      distanceInMeters: 0.0,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _customerName;
  int? _tappedStationId;

  List<Store> _stores = [];
  bool _isLoadingStores = true;
  String? _storesError;

  /// Controller for the autocomplete field
  late TextEditingController _autocompleteController;

  /// For cycling “Tip of the Day”
  late Timer _tipTimer;
  int _currentTipIndex = 0;
  int _currentColorIndex = 0;

  /// The list of tip strings to cycle through
  final List<String> _tipTexts = [
    'Drink at least 8 glasses of water each day to stay hydrated.',
    'Cold water can help boost your metabolism slightly.',
    'Carry a reusable bottle to track and increase your intake.',
    'Infuse your water with fruits for added flavor and nutrients.',
    'Drinking water before meals can help with digestion and appetite control.',
  ];

  /// A list of gradient‐pairs to cycle through for the container background
  final List<List<Color>> _tipGradients = [
    [Colors.teal.shade400, Colors.teal.shade200],
    [Colors.purple.shade400, Colors.purple.shade200],
    [Colors.orange.shade400, Colors.orange.shade200],
    [Colors.blue.shade400, Colors.blue.shade200],
    [Colors.green.shade400, Colors.green.shade200],
  ];

  /// Holds the most recent completed order, if any
  Order? _lastCompletedOrder;
  bool _isLoadingLastOrder = true;

  @override
  void initState() {
    super.initState();
    _autocompleteController = TextEditingController();
    _autocompleteController.addListener(() {
      // Trigger rebuild when autocomplete text changes
      setState(() {});
    });

    _fetchCustomerName();
    _determinePositionAndFetchStores();
    _fetchLastCompletedOrder();

    // Start the timer that rotates tips + colors every 10 seconds
    _tipTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _tipTexts.length;
        _currentColorIndex = (_currentColorIndex + 1) % _tipGradients.length;
      });
    });
  }

  @override
  void dispose() {
    _autocompleteController.dispose();
    _tipTimer.cancel(); // Cancel our tip‐rotation timer
    super.dispose();
  }

  /// Fetches the authenticated customer’s name.
  Future<void> _fetchCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.36:8000/api/customer/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _storesError = 'Location services are disabled.';
        _isLoadingStores = false;
      });
      return;
    }

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

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
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
        Uri.parse('http://192.168.1.36:8000/api/customer/stores'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        final List<Store> fetchedStores = jsonList
            .map((item) => Store.fromJson(item as Map<String, dynamic>))
            .toList();

        // Compute distance for each store
        for (var store in fetchedStores) {
          final distMeters = Geolocator.distanceBetween(
            userLat,
            userLng,
            store.latitude,
            store.longitude,
          );
          store.distanceInMeters = distMeters;
        }

        // Sort by distance (nearest → farthest)
        fetchedStores.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

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

  /// Fetches the last “completed” order for this customer (if any), by calling
  /// the same API that `ActivityPage` uses, then filtering for `status == 'completed'`
  /// and taking the most‐recent one (by assumed order in the returned list).
  Future<void> _fetchLastCompletedOrder() async {
    setState(() {
      _isLoadingLastOrder = true;
      _lastCompletedOrder = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customer_id');
    if (customerId == null) {
      setState(() {
        _isLoadingLastOrder = false;
      });
      return;
    }

    try {
      final allOrders = await ApiService.fetchMyOrders(customerId.toString());
      // Filter those whose status is 'completed'
      final completed = allOrders.where((o) => o.status.toLowerCase() == 'completed');
      if (completed.isNotEmpty) {
        // If your API returns them sorted descending by time, just take first:
        _lastCompletedOrder = completed.first;
      }
    } catch (_) {
      // ignore errors here for now
    } finally {
      setState(() {
        _isLoadingLastOrder = false;
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
  // Pick the current tip text and gradient by index:
  final String tip = _tipTexts[_currentTipIndex];
  final List<Color> gradientColors = _tipGradients[_currentColorIndex];

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(90),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(90),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lightbulb,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Refill Pro Tip of the Day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



  
Widget _buildLastCompletedOrderCard() {
  if (_isLoadingLastOrder) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  if (_lastCompletedOrder == null) return const SizedBox.shrink();
  final o = _lastCompletedOrder!;

  // screen width minus horizontal padding on both sides
  final screenW = MediaQuery.of(context).size.width;
  final cardW    = screenW - 32;

  // We'll display the product images at a fixed height (50px)
  const imageH = 50.0;
  // preserve your assets' aspect ratios
  final regularW   = imageH * (310.0 / 442.0);
  final dispenserW = imageH * (287.0 / 497.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // “Previous order” title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Previous order',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontFamily: 'PoppinsExtraBold',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // The dark card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: cardW,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A2B),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─ Left: Shop name + images + counts ─────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop name
                    Text(
                      o.shopName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Product images + counts
                    Row(
                      children: [
                        if (o.regularCount > 0) ...[
                          Image.asset(
                            'images/regular_gallon.png',
                            width: regularW,
                            height: imageH,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x${o.regularCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                        if (o.dispenserCount > 0) ...[
                          Image.asset(
                            'images/dispenser_gallon.png',
                            width: dispenserW,
                            height: imageH,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x${o.dispenserCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ─ Right: Reorder button + total ─────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // fetch shop details then navigate:
                      final details = await ApiService
                        .fetchOwnerShopDetails(o.shopId.toString());
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderForm(
                            shopName:             o.shopName,
                            customerId:           o.customerId,
                            stationId:            o.shopId,
                            ownerName:            o.ownerName,
                            ownerShopDetails:     details,
                            regularGallon:        o.regularCount,
                            dispenserGallon:      o.dispenserCount,
                            borrow:               o.borrow,
                            swap:                 o.swap,
                            total:                o.total,
                            shopId:               o.shopId,
                            regularGallonImage:   'images/regular_gallon.png',
                            dispenserGallonImage: 'images/dispenser_gallon.png',
                            borrowPrice:          details.borrowPrice,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CB338),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Order again?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // total price
                  Text(
                    '₱${o.total.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),
    ],
  );
}








  /// Renders a dropdown of nearby store–names. As soon as the user selects
  /// one, we record that station’s ID and jump to the Map tab.
  Widget _buildStoreAutocomplete() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Autocomplete<Store>(
        displayStringForOption: (Store s) => s.name,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
          // Tie our controller into the Autocomplete
          textEditingController.text = _autocompleteController.text;
          return TextField(
            controller: _autocompleteController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search station shops...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => onFieldSubmitted(),
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          final input = textEditingValue.text.trim().toLowerCase();
          if (input.isEmpty) return const Iterable<Store>.empty();

          return _stores.where((Store store) {
            final lowerName = store.name.toLowerCase();
            final lowerAddress = store.address.toLowerCase();
            return lowerName.contains(input) || lowerAddress.contains(input);
          });
        },
        onSelected: (Store selectedStore) {
          // When user taps a suggestion, switch to Map tab for that store:
          setState(() {
            _tappedStationId = selectedStore.id;
            _selectedIndex = 1;
          });
        },
        optionsViewBuilder: (context, onSelected, options) {
          final totalWidth = MediaQuery.of(context).size.width - 32;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: totalWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200, // scroll if more items
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Store s = options.elementAt(index);
                        return ListTile(
                          title: Text(s.name),
                          subtitle: Text(
                            s.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            onSelected(s);
                            _autocompleteController.text = s.name;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  /// Renders the list of nearby stores (with distance) in a scrollable list.
  Widget _buildStoreList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby Stores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'PoppinsExtraBold',
            ),
          ),
          const SizedBox(height: 8),
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
                final distKm = (store.distanceInMeters / 1000).toStringAsFixed(2);
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
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
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

  /// Called when user pulls down to refresh on Home.
  Future<void> _refreshHome() async {
    setState(() {
      _isLoadingStores = true;
      _storesError = null;
      _stores = [];
      _tappedStationId = null;
      _autocompleteController.clear();
      _lastCompletedOrder = null;
      _isLoadingLastOrder = true;
    });

    await Future.wait([
      _fetchCustomerName(),
      _determinePositionAndFetchStores(),
      _fetchLastCompletedOrder(),
    ]);
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreAutocomplete(),
            _buildGreeting(),
            _buildTipCard(),
            // ← SEARCH BAR IS NOW HERE, AFTER THE TIP CARD
            _buildLastCompletedOrderCard(),
            
            // ← LAST COMPLETED ORDER SECTION
            
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
      const Profile(),
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
