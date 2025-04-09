import 'package:flutter/material.dart';
import 'package:refillproo/navs/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditingName = false;
  bool isEditingAddress = false;
  bool isEditingContact = false;

  final nameController = TextEditingController(text: "Jaymark Ancheta");
  final addressController = TextEditingController(text: "316 Maharlika Highway Tuguegarao City");
  final contactController = TextEditingController(text: "09275313243");

  void _onTapNav(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/activity');
        break;
      case 3:
        // Already on Profile
        break;
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: TextField(
          controller: controller,
          enabled: isEditing,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        trailing: IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f4),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text("PROFILE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[400],
                    child: Stack(
                      children: const [
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, size: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("09553806970", style: TextStyle(color: Colors.white)),
                  const Text("Jaymark Ancheta", style: TextStyle(color: Colors.white70)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: "Name",
            controller: nameController,
            isEditing: isEditingName,
            onEdit: () {
              setState(() => isEditingName = !isEditingName);
            },
          ),
          _buildEditableField(
            label: "Address",
            controller: addressController,
            isEditing: isEditingAddress,
            onEdit: () {
              setState(() => isEditingAddress = !isEditingAddress);
            },
          ),
          _buildEditableField(
            label: "Contact Number",
            controller: contactController,
            isEditing: isEditingContact,
            onEdit: () {
              setState(() => isEditingContact = !isEditingContact);
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Handle delete account logic
            },
            child: const Text("Delete my account", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: _onTapNav,
      ),
    );
  }
}
