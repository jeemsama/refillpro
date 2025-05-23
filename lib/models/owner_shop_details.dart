class OwnerShopDetails {
  final List<String> deliveryTimeSlots;
  final List<String> collectionDays;
  final bool hasRegularGallon;
  final double regularGallonPrice;
  final bool hasDispenserGallon;
  final double dispenserGallonPrice;

  OwnerShopDetails({
    required this.deliveryTimeSlots,
    required this.collectionDays,
    required this.hasRegularGallon,
    required this.regularGallonPrice,
    required this.hasDispenserGallon,
    required this.dispenserGallonPrice,
  });

  factory OwnerShopDetails.fromJson(Map<String, dynamic> json) {
    // helper to parse a nullable num/String into double with default 0.0
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // helper to parse a nullable list into List<String>
    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return <String>[];
    }

    return OwnerShopDetails(
      deliveryTimeSlots: toStringList(json['delivery_time_slots']),
      collectionDays:    toStringList(json['collection_days']),
      hasRegularGallon:    json['has_regular_gallon'] == true,
      regularGallonPrice:  toDouble(json['regular_gallon_price']),
      hasDispenserGallon:  json['has_dispenser_gallon'] == true,
      dispenserGallonPrice:toDouble(json['dispenser_gallon_price']),
    );
  }

}
