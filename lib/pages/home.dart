import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:refillproo/navs/bottom_nav.dart';

class Store {
  final String name;
  final double latitude;
  final double longitude;
  final String collectionDay;

  Store({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.collectionDay,
  });

  double distanceFrom(Position userLocation) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((latitude - userLocation.latitude) * p) / 2 +
        cos(userLocation.latitude * p) *
            cos(latitude * p) *
            (1 - cos((longitude - userLocation.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _userLocation;

  final List<Store> _stores = [
    Store(
      name: 'Nhonlen’s Water Station',
      latitude: 17.608,
      longitude: 121.728,
      collectionDay: 'Every Monday',
    ),
    Store(
      name: 'Crystal Water Refilling',
      latitude: 17.610,
      longitude: 121.726,
      collectionDay: 'Every Wednesday',
    ),
    Store(
      name: 'Pure Aqua Station',
      latitude: 17.606,
      longitude: 121.730,
      collectionDay: 'Every Friday',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = position;
      _stores.sort((a, b) =>
          a.distanceFrom(position).compareTo(b.distanceFrom(position)));
    });
  }

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Widget _buildPickupReminder(Store nearestStore) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.recycling, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '♻️ Pickup is scheduled ${nearestStore.collectionDay} at ${nearestStore.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardRow() {
  return Container(
    height: 150, // Adjust height as needed
    margin: const EdgeInsets.only(top: 8, bottom: 8),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildInfoCard(
          'Water Refill',
          'Order purified or alkaline water for delivery or pickup.',
          Icons.water_drop,
          Colors.blue,
        ),
        _buildInfoCard(
          'Container Pickup',
          'We collect used containers based on your schedule.',
          Icons.recycling,
          Colors.green,
        ),
        _buildInfoCard(
          'Sanitizing',
          'Ensure your containers are safe and hygienic.',
          Icons.cleaning_services,
          Colors.purple,
        ),
      ],
    ),
  );
}
  Widget _buildInfoCard(
      String title, String description, IconData icon, Color iconColor) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withAlpha((255 * 0.3).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPickupReminder(_stores.first),
                _buildFlashcardRow(), // 👈 Flashcards placed here after the reminder
                Expanded(
                  child: ListView.builder(
                    itemCount: _stores.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    itemBuilder: (context, index) {
                      final store = _stores[index];
                      final distance = store
                          .distanceFrom(_userLocation!)
                          .toStringAsFixed(2);
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(store.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text('Pickup: ${store.collectionDay}'),
                          trailing: Text('$distance km'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onTapNav(index, context),
      ),
    );
  }
}
