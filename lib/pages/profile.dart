import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refillproo/pages/home.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F2937),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
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
        ),
      ),
      body: const ProfileContent(),
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

  bool isEditingShopName = false;
  bool isEditingContactNumber = false;

  late TextEditingController shopNameController;
  late TextEditingController contactNumberController;

  @override
  void initState() {
    super.initState();
    shopNameController = TextEditingController(text: shopName);
    contactNumberController = TextEditingController(text: contactNumber);
  }

  @override
  void dispose() {
    shopNameController.dispose();
    contactNumberController.dispose();
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
                      // Positioned(
                      //   right: 0,
                      //   bottom: 8,
                      //   child: Container(
                      //     width: w(24),
                      //     height: h(24),
                      //     decoration: const BoxDecoration(
                      //       color: Colors.white,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Icon(
                      //       Icons.edit,
                      //       size: fontSize(14),
                      //       color: const Color(0xFF1F2937),
                      //     ),
                      //   ),
                      // ),
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
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
                                  // 
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
