// lib/pages/profile.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refillproo/models/customer_profile.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController _settingsAnimController;
  bool _isSettingsOpen = false;

  @override
  void initState() {
    super.initState();
    _settingsAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F2937),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _settingsAnimController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer_token');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Onboarding()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _isSettingsOpen = !_isSettingsOpen;
      if (_isSettingsOpen) {
        _settingsAnimController.forward();
      } else {
        _settingsAnimController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xff1F2937),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFF1F2937),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          ProfileContent(onLogoutTap: _showLogoutDialog),
          // Settings drawer
          AnimatedBuilder(
            animation: _settingsAnimController,
            builder: (context, child) {
              return Positioned(
                right: -MediaQuery.of(context).size.width * (1 - _settingsAnimController.value),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.7,
                child: child!,
              );
            },
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: const Color(0xff1F2937),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildSettingsOption(title: 'Log out', onTap: _toggleSettings),
                    const Spacer(flex: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Image.asset('images/logo1.png', width: 35, height: 35),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSettingsOpen)
            GestureDetector(onTap: _toggleSettings, child: Container(color: Colors.black.withAlpha(77))),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  final VoidCallback onLogoutTap;
  const ProfileContent({super.key, required this.onLogoutTap});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  String shopName = '';
  String contactNumber = ''; // will be stored as "+63xxxxxxxxxx"
  String address = '';

  bool isEditingShopName = false;
  bool isEditingContactNumber = false;

  late TextEditingController shopNameController;
  late TextEditingController contactNumberController;

  @override
  void initState() {
    super.initState();
    shopNameController = TextEditingController();
    contactNumberController = TextEditingController();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    address = prefs.getString('saved_address') ?? 'Unknown location';
    final token = prefs.getString('customer_token');
    if (token == null) return;

    final url = Uri.parse('http://192.168.1.36:8000/api/customer/profile');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final profile = CustomerProfile.fromJson(data);
      setState(() {
        shopName = profile.name ?? '';
        contactNumber = profile.phone ?? '';
      });
      // persist for order_form pre-fill
      await prefs.setString('customer_name', profile.name ?? '');
      await prefs.setString('customer_phone', profile.phone ?? '');
    }
  }

  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) return;

    final uri = Uri.parse('http://192.168.1.36:8000/api/customer/profile');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': shopName,
        'phone': contactNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        shopName = data['name'] ?? '';
        contactNumber = data['phone'] ?? '';
        isEditingContactNumber = false;
        isEditingShopName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      // update SharedPreferences too
      await prefs.setString('customer_name', shopName);
      await prefs.setString('customer_phone', contactNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed')),
      );
    }
  }

  void _saveContactNumber() {
    final local = contactNumberController.text.trim();
    if (local.length == 10) {
      setState(() {
        contactNumber = '+63$local';
        isEditingContactNumber = false;
      });
      updateProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter exactly 10 digits for your phone number.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final widthScaleFactor = screenWidth / 401;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    double w(double v) => v * widthScaleFactor;
    double fontSize(double v) => v * widthScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // top banner
            Container(
              width: double.infinity,
              height: w(170) + topPadding,
              padding: EdgeInsets.only(top: topPadding),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: w(62.5),
                    backgroundImage: const AssetImage('images/default_profile.png'),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shopName.isNotEmpty ? shopName : 'Your Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize(24),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Name field
                  _buildEditableField(
                    label: 'Name',
                    value: shopName,
                    isEditing: isEditingShopName,
                    controller: shopNameController,
                    fontSize: fontSize,
                    onSave: () {
                      setState(() {
                        shopName = shopNameController.text.trim();
                        isEditingShopName = false;
                      });
                      updateProfile();
                    },
                    onEdit: () {
                      shopNameController.text = shopName;
                      setState(() => isEditingShopName = true);
                    },
                  ),

                  // Contact Number field
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 8),
                                child: Text(
                                  'Contact Number',
                                  style: TextStyle(
                                    fontSize: fontSize(12),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, bottom: 8, right: 12),
                                child: isEditingContactNumber
                                    ? TextField(
                                        controller: contactNumberController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          prefixText: '+63 ',
                                        ),
                                        autofocus: true,
                                        onSubmitted: (_) => _saveContactNumber(),
                                      )
                                    : Text(
                                        contactNumber.isNotEmpty
                                            ? contactNumber
                                            : 'Not set',
                                        style: TextStyle(
                                          fontSize: fontSize(16),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isEditingContactNumber ? Icons.check : Icons.edit,
                            size: fontSize(18),
                          ),
                          onPressed: () {
                            if (isEditingContactNumber) {
                              _saveContactNumber();
                            } else {
                              contactNumberController.text =
                                  contactNumber.replaceFirst('+63', '');
                              setState(() => isEditingContactNumber = true);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Address display
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: TextStyle(
                              fontSize: fontSize(12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: fontSize(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton.icon(
                      onPressed: widget.onLogoutTap,
                      icon: const Icon(Icons.logout),
                      label: const Text('Log out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required double Function(double) fontSize,
    required VoidCallback onSave,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize(12),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, bottom: 8, right: 12),
                  child: isEditing
                      ? TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                              fontSize: fontSize(16), fontWeight: FontWeight.w500),
                          keyboardType: keyboardType,
                          autofocus: true,
                          onSubmitted: (_) => onSave(),
                        )
                      : Text(
                          value.isNotEmpty ? value : 'Not set',
                          style: TextStyle(
                              fontSize: fontSize(16), fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit,
                size: fontSize(18)),
            onPressed: isEditing ? onSave : onEdit,
          ),
        ],
      ),
    );
  }
}
