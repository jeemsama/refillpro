// lib/models/refilling_station.dart
class RefillingStation {
  final int id;
  final int ownerId;            // ← newly added
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String shopPhoto;


  RefillingStation({
    required this.id,
    required this.ownerId,      // ← include in ctor
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.shopPhoto,

  });

  factory RefillingStation.fromJson(Map<String, dynamic> json) {
    // parse station id
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId.toString()) ?? 0;

    // parse owner_id (or nested owner.id)
    int ownerId = 0;
    if (json.containsKey('owner_id')) {
      final o = json['owner_id'];
      ownerId = o is int
          ? o
          : int.tryParse(o.toString()) ?? 0;
    } else if (json['owner']?['id'] != null) {
      final o = json['owner']['id'];
      ownerId = o is int
          ? o
          : int.tryParse(o.toString()) ?? 0;
    }

    // helper to pull a string safely
String str(List<String> keys) {
  for (var k in keys) {
    if (json.containsKey(k) && json[k] != null) {
      return json[k].toString();
    }
  }
  return '';
}


    // helper to pull a double safely
    double dbl(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return RefillingStation(
      id:        id,
      ownerId:   ownerId,        // ← pass it through
      shopName:  str(['shop_name','shopName','name']),
      ownerName: str(['owner_name','ownerName','owner']),
      email:     str(['email','emailAddress']),
      phone:     str(['phone','contact','phoneNumber']),
      address:   str(['address','location']),
      latitude:  dbl('latitude'),
      longitude: dbl('longitude'),
      shopPhoto: str(['shop_photo','shopPhoto','photo','image']),

    );
  }
}
