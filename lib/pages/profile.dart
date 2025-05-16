import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refillproo/pages/home.dart';

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
          actions: [
            // Add settings icon button
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _toggleSettings,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const ProfileContent(),
          
          // Settings panel with animation
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
              onTap: () {}, // Prevent clicks from passing through
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
                    // Settings options
                    _buildSettingsOption(
                      title: 'Log out',
                      onTap: () {
                        // Handle log out
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
                            content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Account deleted')),
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
  
  Widget _buildSettingsOption({required String title, required VoidCallback onTap}) {
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
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  String shopName = 'Jaymark Ancheta';
  String contactNumber = '09275313243';
  String address = 'Carig Sur, Tuguegarao City, Cagayan';

  bool isEditingShopName = false;
  bool isEditingContactNumber = false;
  bool isEditingAddress = false;


  late TextEditingController shopNameController;
  late TextEditingController contactNumberController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    shopNameController = TextEditingController(text: shopName);
    contactNumberController = TextEditingController(text: contactNumber);
    addressController = TextEditingController(text: address);
  }

  @override
  void dispose() {
    shopNameController.dispose();
    contactNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final widthScaleFactor = screenWidth / 401;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    double w(double value) => value * widthScaleFactor;
    double h(double value) => value * widthScaleFactor;
    double fontSize(double value) => value * widthScaleFactor;

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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: w(125),
                        height: h(116),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                      Container(
                        width: w(98),
                        height: h(98),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: Icon(
                          Icons.person,
                          size: w(60),
                          color: const Color(0xFFD9D9D9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shopName,
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
                    },
                    onEdit: () {
                      setState(() {
                        contactNumberController.text = contactNumber;
                        isEditingContactNumber = true;
                      });
                    },
                    keyboardType: TextInputType.phone,
                  ),
                    _buildEditableField(
                    label: 'Address',
                    value: address,
                    isEditing: isEditingAddress,
                    controller: addressController,
                    fontSize: fontSize,
                    onSave: () {
                      setState(() {
                        address = addressController.text;
                        isEditingContactNumber = false;
                      });
                    },
                    onEdit: () {
                      setState(() {
                        addressController.text = address;
                        isEditingAddress = true;
                      });
                    },
                    keyboardType: TextInputType.streetAddress,
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
                  padding: const EdgeInsets.only(left: 12, bottom: 8, right: 12),
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
                          value,
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
            icon: Icon(isEditing ? Icons.check : Icons.edit, size: fontSize(18)),
            onPressed: isEditing ? onSave : onEdit,
          ),
        ],
      ),
    );
  }
}