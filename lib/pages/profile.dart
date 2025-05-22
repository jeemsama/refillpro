import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:refillproo/models/customer_profile.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:refillproo/pages/home.dart';
import 'package:refillproo/pages/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController _settingsAnimController;
  bool _isSettingsOpen = false;

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
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for settings panel
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
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          // actions: [
          //   // Add settings icon button
          //   IconButton(
          //     icon: const Icon(Icons.settings, color: Colors.white),
          //     onPressed: _toggleSettings,
          //   ),
          // ],
        ),
      ),
      body: Stack(
        children: [
          ProfileContent(onLogoutTap: () {
            _showLogoutDialog();
          }),

          // Settings panel with animation
          AnimatedBuilder(
            animation: _settingsAnimController,
            builder: (context, child) {
              return Positioned(
                right: -MediaQuery.of(context).size.width *
                    (1 - _settingsAnimController.value),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.7,
                child: child!,
              );
            },
            child: GestureDetector(
              onTap: () {}, // Prevent clicks from passing through
              child: Container(
                color: const Color(0xff1F2937),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).padding.top +
                            kToolbarHeight),
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
                    // Settings options
                    _buildSettingsOption(
                      title: 'Log out',
                      onTap: () {
                        _toggleSettings();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _showLogoutDialog(); // clean and safe
                        });
                      },
                    ),
                    _buildSettingsOption(
                      title: 'Delete account',
                      onTap: () {
                        // Show delete confirmation dialog
                        Navigator.pop(context); // Close settings panel
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                                'Are you sure you want to delete your account? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Account deleted')),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(flex: 4),
                    // Logo at the bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Image.asset(
                        'images/logo1.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlay to close settings when tapping outside
          if (_isSettingsOpen)
            GestureDetector(
              onTap: _toggleSettings,
              child: Container(
                color: Colors.black.withAlpha(77),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
      {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
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
  String contactNumber = '';
  File? profileImage;
  String? networkProfileImageUrl;

  bool isEditingShopName = false;
  bool isEditingContactNumber = false;
  bool isEditingProfileImage = false;

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
    final token = prefs.getString('customer_token');
    if (token == null) return;

    final url = Uri.parse('http://192.168.1.6:8000/api/customer/profile');
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
        networkProfileImageUrl = profile.profileImageUrl; // ✅ Add this line
      });
    }
  }

  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');

    final uri = Uri.parse('http://192.168.1.6:8000/api/customer/profile');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields['_method'] = 'PUT'
      ..fields['name'] = shopName
      ..fields['phone'] = contactNumber;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage!.path,
      ));
    }

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(resStr);
      setState(() {
        shopName = data['name'] ?? '';
        contactNumber = data['phone'] ?? '';
        // update profileImage from `data['profile_image']` if needed'
        if (data['profile_image_url'] != null) {
          // Optional: you can store this string to use it in an Image.network() later
          networkProfileImageUrl = data['profile_image_url'];
          profileImage =
              null; // Clear local file since you're using network now
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed')),
      );
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  Future<XFile?> _pickImage() async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final widthScaleFactor = screenWidth / 401;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    double w(double value) => value * widthScaleFactor;
    double h(double value) => value * widthScaleFactor;
    double fontSize(double value) => value * widthScaleFactor;

    ImageProvider? imageProvider;
    if (profileImage != null) {
      imageProvider = FileImage(profileImage!);
    } else if (networkProfileImageUrl != null) {
      imageProvider = NetworkImage(networkProfileImageUrl!);
    } else {
      imageProvider = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: h(170) + topPadding,
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
                  GestureDetector(
                    onTap: () async {
                      final picked = await _pickImage();
                      if (picked != null) {
                        setState(() {
                          profileImage = File(picked.path);
                          isEditingProfileImage = true;
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: w(62.5),
                          backgroundColor: const Color(0xFFD9D9D9),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Icon(Icons.person,
                                  size: w(60), color: const Color(0xFF999999))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child:
                                Icon(Icons.edit, size: 18, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: w(125),
                          height: h(116),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                            image: profileImage != null
                                ? DecorationImage(
                                    image: FileImage(profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profileImage == null
                              ? Icon(Icons.person,
                                  size: w(60), color: const Color(0xFFD9D9D9))
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shopName.isNotEmpty ? shopName : 'Your Name',
                    textAlign: TextAlign.center,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildEditableField(
                    label: 'Name',
                    value: shopName,
                    isEditing: isEditingShopName,
                    controller: shopNameController,
                    fontSize: fontSize,
                    onSave: () {
                      setState(() {
                        shopName = shopNameController.text;
                        isEditingShopName = false;
                      });
                      updateProfile();
                    },
                    onEdit: () {
                      setState(() {
                        shopNameController.text = shopName;
                        isEditingShopName = true;
                      });
                    },
                  ),
                  _buildEditableField(
                    label: 'Contact Number',
                    value: contactNumber,
                    isEditing: isEditingContactNumber,
                    controller: contactNumberController,
                    fontSize: fontSize,
                    onSave: () {
                      setState(() {
                        contactNumber = contactNumberController.text;
                        isEditingContactNumber = false;
                      });
                      updateProfile();
                    },
                    onEdit: () {
                      setState(() {
                        contactNumberController.text = contactNumber;
                        isEditingContactNumber = true;
                      });
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  if (isEditingProfileImage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          updateProfile();
                          setState(() {
                            isEditingProfileImage = false;
                          });
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Profile Picture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2937),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                            fontSize: fontSize(16),
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: keyboardType,
                          autofocus: true,
                          onSubmitted: (_) => onSave(),
                        )
                      : Text(
                          value.isNotEmpty ? value : 'Not set',
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
            icon:
                Icon(isEditing ? Icons.check : Icons.edit, size: fontSize(18)),
            onPressed: isEditing ? onSave : onEdit,
          ),
        ],
      ),
    );
  }
}
