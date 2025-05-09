import 'package:flutter/material.dart';

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

  // Helper methods
  bool get hasRegularGallon => gallons?['regular'] != null;
  double? get regularGallonPrice => _getGallonPrice('regular');
  
  bool get hasDispenserGallon => gallons?['dispenser'] != null;
  double? get dispenserGallonPrice => _getGallonPrice('dispenser');
  
  bool get hasSmallGallon => gallons?['small'] != null;
  double? get smallGallonPrice => _getGallonPrice('small');
  
  double? _getGallonPrice(String type) {
    final price = gallons?[type]?['price'];
    if (price == null) return null;
    
    // Handle multiple potential formats
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory RefillingStation.fromJson(Map<String, dynamic> json) {
    // Debug print to see what fields are actually coming from the API
    debugPrint("JSON keys: ${json.keys.toList()}");
    
    // Handle potential field name variations
    int getId() {
      if (json.containsKey('id')) return json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0;
      if (json.containsKey('ID')) return json['ID'] is int ? json['ID'] : int.tryParse(json['ID'].toString()) ?? 0;
      return 0;
    }
    
    String getStringValue(List<String> possibleKeys, String defaultValue) {
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key].toString();
        }
      }
      return defaultValue;
    }
    
    double getDoubleValue(List<String> possibleKeys, double defaultValue) {
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          var value = json[key];
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) {
            try {
              return double.parse(value);
            } catch (_) {
              // Keep trying other keys
            }
          }
        }
      }
      return defaultValue;
    }
    
    List<String> getTimeSlots() {
      var possibleKeys = ['delivery_time_slots', 'deliveryTimeSlots', 'time_slots'];
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          var value = json[key];
          if (value is List) {
            return value.map((item) => item.toString()).toList();
          }
        }
      }
      return [];
    }

    Map<String, dynamic>? getGallons() {
      var possibleKeys = ['gallons', 'gallon_types', 'gallonTypes'];
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null && json[key] is Map) {
          return Map<String, dynamic>.from(json[key]);
        }
      }
      return null;
    }
    
    return RefillingStation(
      id: getId(),
      shopName: getStringValue(['shop_name', 'shopName', 'name'], ''),
      ownerName: getStringValue(['owner_name', 'ownerName', 'owner'], ''),
      email: getStringValue(['email', 'emailAddress'], ''),
      phone: getStringValue(['phone', 'phoneNumber', 'contact'], ''),
      address: getStringValue(['address', 'location'], ''),
      latitude: getDoubleValue(['latitude', 'lat'], 0.0),
      longitude: getDoubleValue(['longitude', 'lng', 'long'], 0.0),
      shopPhoto: getStringValue(['shop_photo', 'shopPhoto', 'photo', 'image'], ''),
      gallons: getGallons(),
      deliveryTimeSlots: getTimeSlots(),
    );
  }
}