class RefillingStation {
  final int id;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String shopPhoto;
  final Map<String, dynamic>? gallons;
  final List<String> deliveryTimeSlots;

  RefillingStation({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.shopPhoto,
    this.gallons,
    required this.deliveryTimeSlots,
  });

  // Helper methods to access gallon data
  bool get hasRegularGallon => gallons?['regular'] != null;
  double? get regularGallonPrice => gallons?['regular']?['price'] != null 
      ? double.tryParse(gallons!['regular']['price'].toString()) : null;

  bool get hasDispenserGallon => gallons?['dispenser'] != null;
  double? get dispenserGallonPrice => gallons?['dispenser']?['price'] != null 
      ? double.tryParse(gallons!['dispenser']['price'].toString()) : null;

  bool get hasSmallGallon => gallons?['small'] != null;
  double? get smallGallonPrice => gallons?['small']?['price'] != null 
      ? double.tryParse(gallons!['small']['price'].toString()) : null;

  factory RefillingStation.fromJson(Map<String, dynamic> json) {
    return RefillingStation(
      id: json['id'],
      shopName: json['shop_name'],
      ownerName: json['owner_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      shopPhoto: json['shop_photo'],
      gallons: json['gallons'],
      deliveryTimeSlots: List<String>.from(json['delivery_time_slots']),
    );
  }
}