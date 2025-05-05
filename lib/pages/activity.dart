import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Activity",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 4, // You can make this dynamic later
              itemBuilder: (context, index) => ActivityCard(
                shopName: "Nhorlen’s Water Station",
                dateTime: "21 Mar 2025, 9:35 AM",
                amount: 30.00,
                orderNumber: "ORDER-000$index",
                orderedBy: "John Doe",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  final String shopName;
  final String dateTime;
  final double amount;
  final String orderNumber;
  final String orderedBy;

  const ActivityCard({
    super.key,
    required this.shopName,
    required this.dateTime,
    required this.amount,
    required this.orderNumber,
    required this.orderedBy,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.shopName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(widget.dateTime,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text("Pending",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text("₱${widget.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text("Order No: ${widget.orderNumber}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("Ordered By: ${widget.orderedBy}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
