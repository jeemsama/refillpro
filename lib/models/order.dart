// lib/models/order.dart

class Order {
  final String   id;
  final int      customerId;
  final int      shopId;
  final String   ownerName;
  final String   shopName;
  final String   orderedBy;
  final String   phone;
  final String   timeSlot;
  final String?  message;
  final int      regularCount;
  final int      dispenserCount;
  final bool     borrow;
  final bool     swap;
  final double   total;
  final DateTime placedAt;
  final String   status;

  Order({
    this.id               = '',
    required this.customerId,
    required this.shopId,
    required this.ownerName,
    required this.shopName,
    required this.orderedBy,
    required this.phone,
    required this.timeSlot,
    this.message,
    required this.regularCount,
    required this.dispenserCount,
    required this.borrow,
    required this.swap,
    required this.total,
    DateTime? placedAt,
    this.status          = 'pending',
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
      id:             (j['id'] ?? '').toString(),
      customerId:     parseInt(j['customer_id']),
      shopId:         parseInt(j['shop_id']),
      ownerName:      j['owner_name']   as String? ?? '',
      shopName:       j['shop_name']    as String? ?? '',
      orderedBy:      j['ordered_by']   as String? ?? '',
      phone:          j['phone']        as String? ?? '',
      timeSlot:       j['time_slot']    as String? ?? '',
      message:        j['message']      as String?,
      regularCount:   parseInt(j['regular_count']),
      dispenserCount: parseInt(j['dispenser_count']),
      borrow:         parseBool(j['borrow']),
      swap:           parseBool(j['swap']),
      total:          parseDouble(j['total']),
      placedAt:       j['created_at'] != null
                        ? DateTime.parse(j['created_at'] as String)
                        : DateTime.now(),
      status:         j['status'] as String? ?? 'pending',
    );
  }

  /// Convert an Order to JSON for creating/updating via your API.
  Map<String, dynamic> toJson() => {
        'shop_name'     : shopName,
        'customer_id'    : customerId,
        'shop_id'        : shopId,
        'ordered_by'     : orderedBy,        // ← add this
        'phone'          : phone,            // ← and this
        'time_slot'      : timeSlot,
        'message'        : message,
        'regular_count'  : regularCount,
        'dispenser_count': dispenserCount,
        'borrow'         : borrow,
        'swap'           : swap,
        'total'          : total,
      };
}
