// lib/models/order.dart

class Order {
  final String id;
  final String shopName;
  final int customerId;
  final int shopId;
  final String ownerName;
  final String orderedBy;
  final String phone;
  final String timeSlot;
  final String? message;
  final int regularCount;
  final int dispenserCount;
  final bool borrow;
  final bool swap;
  final double total;
  final DateTime placedAt;
  final String status;
  final double latitude;
  final double longitude;
  final String? cancelReasonCustomer; // from JSON: cancel_reason_customer
  final String? cancelReasonOwner;    // from JSON: cancel_reason_owner

  Order({
    this.id = '',
    required this.shopName,
    required this.customerId,
    required this.shopId,
    required this.ownerName,
    required this.orderedBy,
    required this.phone,
    required this.timeSlot,
    this.message,
    required this.regularCount,
    required this.dispenserCount,
    required this.borrow,
    required this.swap,
    required this.total,
    required this.latitude,
    required this.longitude,
    DateTime? placedAt,
    this.status = 'pending',
    this.cancelReasonCustomer,
    this.cancelReasonOwner,
  }) : placedAt = placedAt ?? DateTime.now();

  String get formattedDate =>
      "${placedAt.day}/${placedAt.month}/${placedAt.year}";

  /// Create an Order from JSON, handling strings & numbers flexibly.
  factory Order.fromJson(Map<String, dynamic> j) {
    // Helper to parse booleans (from bool, int, or String)
    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) {
        final l = v.toLowerCase();
        return l == '1' || l == 'true';
      }
      return false;
    }

    // Helper to parse integers (from int, num, or numeric String)
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    // Helper to parse doubles (from num or numeric String)
    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return Order(
      id: (j['id'] ?? '').toString(),
      customerId: parseInt(j['customer_id']),
      shopId: parseInt(j['shop_id']),
      ownerName: j['owner_name'] as String? ?? '',
      shopName: j['shop_name'] as String? ?? '',
      orderedBy: j['ordered_by'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      timeSlot: j['time_slot'] as String? ?? '',
      message: j['message'] as String?,
      regularCount: parseInt(j['regular_count']),
      dispenserCount: parseInt(j['dispenser_count']),
      borrow: parseBool(j['borrow']),
      swap: parseBool(j['swap']),
      total: parseDouble(j['total']),
      latitude: parseDouble(j['latitude']),
      longitude: parseDouble(j['longitude']),
      placedAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'] as String)
          : DateTime.now(),
      status: j['status'] as String? ?? 'pending',
      cancelReasonCustomer: j['cancel_reason_customer'] as String?,
      cancelReasonOwner:    j['cancel_reason_owner']    as String?,
    );
  }

  /// Convert an Order to JSON for creating/updating via your API.
  Map<String, dynamic> toJson() => {
        'customer_id': customerId, // must exist:customers,id
        'shop_id': shopId, // must exist:owner_shop_details,id
        'ordered_by': orderedBy, // required|string
        'phone': phone, // required|string
        'time_slot': timeSlot, // required|string
        'message': message, // nullable|string
        'regular_count': regularCount, // required|integer|min:0
        'dispenser_count': dispenserCount, // required|integer|min:0
        'borrow': borrow ? 1 : 0, // required|boolean
        'swap': swap ? 1 : 0, // required|boolean
        'total': total, // required|numeric
        'latitude': latitude, // required|numeric
        'longitude': longitude, // required|numeric
      };
}
