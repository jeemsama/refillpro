class OwnerShopDetails {
  final int id;
  final List<String> deliveryTimeSlots;
  final List<String> collectionDays;
  final double borrowPrice;
  final bool hasRegularGallon;
  final double regularGallonPrice;
  final bool hasDispenserGallon;
  final double dispenserGallonPrice;
  final bool borrow;
  final bool swap;

  OwnerShopDetails({
    required this.id,
    required this.deliveryTimeSlots,
    required this.collectionDays,
    required this.borrowPrice,
    required this.hasRegularGallon,
    required this.regularGallonPrice,
    required this.hasDispenserGallon,
    required this.dispenserGallonPrice,
    required this.borrow,
    required this.swap,
  });

  factory OwnerShopDetails.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    return OwnerShopDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      deliveryTimeSlots: toStringList(json['delivery_time_slots']),
      collectionDays: toStringList(json['collection_days']),
      borrowPrice: toDouble(json['borrow_price']), // ✅ FIXED HERE
      hasRegularGallon: json['has_regular_gallon'] == true,
      regularGallonPrice: toDouble(json['regular_gallon_price']),
      hasDispenserGallon: json['has_dispenser_gallon'] == true,
      dispenserGallonPrice: toDouble(json['dispenser_gallon_price']),
      borrow: json['borrow'] == true || json['borrow'] == 1,
      swap: json['swap'] == true || json['swap'] == 1,
    );
  }
}
