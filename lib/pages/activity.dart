// lib/pages/activity.dart

import 'package:flutter/material.dart';
import 'package:refillproo/models/order.dart';
import 'package:refillproo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Order>> _ordersFuture = Future.value(<Order>[]);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMyOrders();
  }

  Future<void> _loadMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('customer_id');
    if (id == null) return;
    setState(() {
      _ordersFuture = ApiService.fetchMyOrders(id.toString());
    });
  }

  Future<void> _cancelOrder(Order order, String reason) async {
    await ApiService.cancelOrder(int.parse(order.id), reason);
    await _loadMyOrders();
  }

  Future<void> _deleteOrder(Order order) async {
    await ApiService.deleteOrder(int.parse(order.id));
    await _loadMyOrders();
  }

  List<Order> _filterByStatus(List<Order> orders, String status) =>
      orders.where((o) => o.status.toLowerCase() == status).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(77),
          child: Container(
            color: const Color(0xFFF2F2F2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      const Text("Your orders",
                          style: TextStyle(
                            fontFamily: 'PoppinsExtraBold',
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      const Spacer(),
                      TabBar(
                        controller: _tabController,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                        dividerColor: Colors.transparent, // Remove the 
                        isScrollable: true,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: "Pending"),
                          Tab(text: "Completed"),
                          Tab(text: "Cancelled"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final orders = snapshot.data!;
          return Column(
            children: [
              // we leave the header and tabs in the AppBar, so nothing else here
              // Expand only the TabBarView so it scrolls under the pinned AppBar
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(_filterByStatus(orders, 'pending'),
                        'No pending orders.'),
                    _buildOrderList(_filterByStatus(orders, 'completed'),
                        'No completed orders.'),
                    _buildOrderList(_filterByStatus(orders, 'cancelled'),
                        'No cancelled orders.'),
                  ],
                ),
              ),
            ],
          );
          }
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        if (order.status.toLowerCase() == 'pending') {
          return ActivityCard(
            order: order,
            actionLabel: 'Cancel order',
            actionColor: const Color(0xFFA62C2C),
            onAction: () => _showCancelDialog(order),
          );
        } else if (order.status.toLowerCase() == 'cancelled') {
          return ActivityCard(
            order: order,
            actionLabel: 'Delete order',
            actionColor: Colors.grey,
            onAction: () => _deleteOrder(order),
          );
        } else {
          // Completed – no action button:
          return ActivityCard(order: order);
        }
      },
    );
  }

  Future<void> _showCancelDialog(Order order) async {
    final reasons = <String>[
      'Changed my mind',
      'Found better price',
      'Ordered by mistake',
      'Other',
    ];
    String? selectedReason;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF455567),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Cancel order?',
                    style: TextStyle(

                        color: Colors.white,
                        fontFamily: 'PoppinsExtraBold',
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedReason,
                    hint: const Text('Reason to cancel',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: reasons
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedReason = v),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize:
                        Size(MediaQuery.of(ctx).size.width * 0.4, 44),
                  ),
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                          _cancelOrder(order, selectedReason!);
                        },
                  child: const Text('Submit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Order order;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;

  const ActivityCard({

    super.key,
    required this.order,
    this.actionLabel,
    this.actionColor,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.shopName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(order.status.capitalize(),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.access_time,
                        color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("ordered by ${order.orderedBy}",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(order.phone,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            if (order.borrow || order.swap)
              Text(order.borrow ? "Borrow gallon" : "Swap gallon",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(order.timeSlot,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Align(
              alignment: Alignment.topRight,
              child: Text(order.formattedDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            if ((order.message ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(order.message!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            // Products + action button + total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  if (order.regularCount > 0)
                    _buildProductItem(
                        count: order.regularCount,
                        imagePath: 'images/regular_gallon.png'),
                  if (order.dispenserCount > 0)
                    _buildProductItem(
                        count: order.dispenserCount,
                        imagePath: 'images/dispenser_gallon.png'),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (actionLabel != null)
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          minimumSize: Size(w * 0.3, h * 0.04),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(actionLabel!,
                            style:
                                const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    const SizedBox(height: 8),
                    Text("₱${order.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem({
    required int count,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(children: [
        Image.asset(imagePath, width: 45, height: 45),
        const SizedBox(width: 4),
        Text("x$count",
            style:
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
}
