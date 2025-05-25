import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedQuizOption = -1;
  String? _customerName;

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.21:8000/api/customer/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _customerName = data['name'];
      });
    }
  }

  final List<String> _tips = [
    'Drink at least 8 glasses of water each day to stay hydrated.',
    'Cold water can help boost your metabolism slightly.',
    'Carry a reusable bottle to track and increase your intake.',
    'Infuse your water with fruits for added flavor and nutrients.',
    'Drinking water before meals can help with digestion and appetite control.',
  ];

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
                fontFamily: 'PoppinsExtraBold'),
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
    final tip = _tips[DateTime.now().day % _tips.length];
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

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color baseColor,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withAlpha(150), baseColor.withAlpha(60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: baseColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardRow() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFeatureCard(
            title: 'Water Refill',
            subtitle:
                'Order purified or alkaline water for delivery or pickup.',
            icon: Icons.water_drop,
            baseColor: Colors.blue,
          ),
          _buildFeatureCard(
            title: 'Container Pickup',
            subtitle: 'We collect used containers based on your schedule.',
            icon: Icons.recycling,
            baseColor: Colors.green,
          ),
          _buildFeatureCard(
            title: 'Sanitizing',
            subtitle: 'Ensure your containers are safe and hygienic.',
            icon: Icons.cleaning_services,
            baseColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    const question = 'How many glasses have you drunk today?';
    final options = ['0', '1', '2', '3', '4', '5+'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade200],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz, size: 28, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Poll',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(options.length, (i) {
              final selected = _selectedQuizOption == i;
              return ChoiceChip(
                label: Text(
                  options[i],
                  style: TextStyle(
                      color: selected
                          ? Colors.orange.shade900
                          : const Color.fromARGB(255, 19, 19, 19)),
                ),
                selected: selected,
                backgroundColor: Colors.white.withAlpha(60),
                selectedColor: Colors.white.withAlpha(150),
                onSelected: (_) =>
                    setState(() => _selectedQuizOption = selected ? -1 : i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          _buildTipCard(),
          _buildFlashcardRow(),
          _buildQuizCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const MapPage(),
      const ActivityPage(),
      Profile(),
    ];
    return Scaffold(
      backgroundColor: Color(0xFFF1EFEC),
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
