// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:refillproo/models/owner_shop_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class ApiService {
  static const _base = 'http://192.168.1.36:8000/api/v1';

  /// Create a new order
  static Future<Order> createOrder(Order o) async {
    final uri = Uri.parse('$_base/orders');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(o.toJson()),
    );
    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body)['data'];
      return Order.fromJson(data);
    }
    throw Exception('Failed to create order: ${resp.statusCode}\n${resp.body}');
  }

  /// Fetch all orders for a given customer ID
  static Future<List<Order>> fetchMyOrders(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    final uri = Uri.parse('$_base/orders?customer_id=$customerId');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body)['data'] as List;
      return list.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch orders: ${resp.statusCode}\n${resp.body}');
  }

  /// Fetch all orders for a given owner/shop ID
  static Future<List<Order>> fetchOwnerOrders(String ownerId) async {
    final uri = Uri.parse('$_base/orders?owner_id=$ownerId');
    final resp = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body)['data'] as List;
      return list.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception(
        'Failed to fetch owner orders: ${resp.statusCode}\n${resp.body}');
  }

  /// Cancel an order by ID, with a reason
  static Future<void> cancelOrder(int orderId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) {
      throw Exception('No auth token, user is not logged in!');
    }

    final uri = Uri.parse('$_base/orders/$orderId/cancel');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to cancel order: ${resp.statusCode}\n${resp.body}');
    }
  }

  /// Delete (permanently remove) an order by ID
  static Future<void> deleteOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('customer_token');
    if (token == null) {
      throw Exception('No auth token, user is not logged in!');
    }

    final uri = Uri.parse('$_base/orders/$orderId');
    final resp = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
          'Failed to delete order: ${resp.statusCode}\n${resp.body}');
    }
  }


    /// Stub: Recreate an order by order ID. You’ll need to implement this on your server.
  static Future<void> reorder(String orderId) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.36:8000/api/customer/orders/$orderId/reorder'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Reorder failed: ${response.statusCode}');
    }
  }


    /// Fetch the single most‐recent “completed” order for a given customer:
  static Future<Order?> fetchLastCompletedOrder(String customerId) async {
    final uri = Uri.parse('$_base/api/customer/last-completed-order?customer_id=$customerId');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      // Suppose the API returns `{ "data": <order JSON> }` or `{ "data": null }`
      if (body['data'] == null) return null;
      return Order.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Error fetching last completed order: ${resp.statusCode}');
    }
  }

/// Fetch shop details by owner‐ID (for pricing, time slots, etc).
  static Future<OwnerShopDetails> fetchOwnerShopDetails(String ownerId) async {
    // Note: this hits GET /api/v1/shop-details/owner/{ownerId}
    final uri = Uri.parse('$_base/shop-details/owner/$ownerId');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        // add auth header here if this endpoint is protected
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      // assume your controller returns { "data": { ... } }
      final data = body['data'] as Map<String, dynamic>;
      return OwnerShopDetails.fromJson(data);
    } else {
      throw Exception(
        'Error fetching shop details (status ${resp.statusCode}): ${resp.body}'
      );
    }
  }

}
