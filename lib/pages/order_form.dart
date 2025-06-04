import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:refillproo/models/order.dart';
import 'package:refillproo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_shop_details.dart';

class OrderForm extends StatefulWidget {
  final String shopName;
  final int customerId;
  final int stationId;
  final String ownerName;
  final OwnerShopDetails ownerShopDetails;
  final int regularGallon;
  final int dispenserGallon;
  final bool borrow;
  final bool swap;
  final double total;
  final int shopId;
  final String regularGallonImage;
  final String dispenserGallonImage;
  final double borrowPrice;

  const OrderForm({
    super.key,
    required this.shopName,
    required this.customerId,
    required this.stationId,
    required this.ownerName,
    required this.ownerShopDetails,
    required this.regularGallon,
    required this.dispenserGallon,
    required this.borrow,
    required this.swap,
    required this.total,
    required this.shopId,
    required this.regularGallonImage,
    required this.dispenserGallonImage,
    required this.borrowPrice,
  });

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();

  String? selectedTimeSlot;

  final MapController mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _markerPosition;
  List<Marker> _markers = [];

  int regularBorrowCount = 0;
  int dispenserBorrowCount = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('customer_name') ?? '';
    final savedPhone = prefs.getString('customer_phone') ?? '';

    setState(() {
      nameController.text = savedName;
      phoneController.text = savedPhone;
    });
  }

  Future<void> _determinePosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _markerPosition = _currentPosition;
      _updateMarker();
    });
  }

  void _updateMarker() {
    if (_markerPosition == null) return;
    _markers = [
      Marker(
        point: _markerPosition!,
        width: 40,
        height: 40,
        child: GestureDetector(
          onLongPress: _showAdjustLocationDialog,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ),
    ];
  }

  void _showAdjustLocationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF455567),
        title: const Text('Adjust Location',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Drag the map to position the marker precisely.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  int _slotValue(String slot) {
    final m = RegExp(r'^(\d{1,2})(?::\d{2})?\s*(AM|PM)\$', caseSensitive: false)
        .firstMatch(slot.trim());
    if (m == null) return 0;
    var hour = int.parse(m.group(1)!);
    final isPm = m.group(2)! == 'PM';
    if (hour == 12) hour = 0;
    if (isPm) hour += 12;
    return hour * 60;
  }

  Widget _buildGallonCard({
    required String image,
    required String label,
    required int count,
    required int selectedBorrow,
    required int selectedSwap,
    required ValueChanged<int> onBorrowChanged,
    required ValueChanged<int> onSwapChanged,
  }) {
    List<int> options = List.generate(count + 1, (i) => i);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Image.asset(image, width: 80, height: 121, fit: BoxFit.contain),
              const SizedBox(height: 8),
              Text('x$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Borrow gallon (₱${widget.borrowPrice.toStringAsFixed(0)}/gallon)',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DropdownButton<int>(
                      value: selectedBorrow,
                      dropdownColor: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(12),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: options.map((val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text('$val'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onBorrowChanged(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Swap gallon:',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DropdownButton<int>(
                      value: selectedSwap,
                      dropdownColor: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(12),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: options.map((val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text('$val'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onSwapChanged(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    instructionController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final h = media.size.height;

    const backgroundColor = Color(0xFF455567);
    const darkBlue = Color(0xFF0F1A2B);
    const borderColor = Color(0xFF1F2937);
    const textColor = Color(0xFFE5E7EB);
    const unselectedSlotColor = Color(0xFF1F2937);
    const selectedSlotColor = Color(0xFFc6c6c6);
    const inputColor = Color(0xFFD9D9D9);

    final slots = widget.ownerShopDetails.deliveryTimeSlots.toList()
      ..sort((a, b) => _slotValue(a).compareTo(_slotValue(b)));

    final int totalBorrowCount = regularBorrowCount + dispenserBorrowCount;
    final double borrowTotal = totalBorrowCount * widget.borrowPrice;

    final double computedTotal =
        (widget.regularGallon * widget.ownerShopDetails.regularGallonPrice) +
            (widget.dispenserGallon *
                widget.ownerShopDetails.dispenserGallonPrice) +
            borrowTotal;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Order form',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gallon Info Section (newly added)
                // Gallon Info Section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: h * 0.02),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Gallon Info',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Please specify your order',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (widget.regularGallon > 0)
                        _buildGallonCard(
                          image: widget.regularGallonImage,
                          label: 'REGULAR GALLON',
                          count: widget.regularGallon,
                          selectedBorrow: regularBorrowCount,
                          selectedSwap:
                              widget.regularGallon - regularBorrowCount,
                          onBorrowChanged: (val) => setState(() {
                            regularBorrowCount = val;
                          }),
                          onSwapChanged: (val) => setState(() {
                            regularBorrowCount = widget.regularGallon - val;
                          }),
                        ),

                      if (widget.regularGallon > 0 &&
                          widget.dispenserGallon > 0)
                        const SizedBox(
                            height: 20), // spacing between both cards

                      if (widget.dispenserGallon > 0)
                        _buildGallonCard(
                          image: widget.dispenserGallonImage,
                          label: 'DISPENSER GALLON',
                          count: widget.dispenserGallon,
                          selectedBorrow: dispenserBorrowCount,
                          selectedSwap:
                              widget.dispenserGallon - dispenserBorrowCount,
                          onBorrowChanged: (val) => setState(() {
                            dispenserBorrowCount = val;
                          }),
                          onSwapChanged: (val) => setState(() {
                            dispenserBorrowCount = widget.dispenserGallon - val;
                          }),
                        ),
                    ],
                  ),
                ),
                // Recipients Info
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Recipients Info',
                        style: TextStyle(
                            color: textColor,
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: h * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: w * 0.2,
                            child: Text('Name:',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: w * 0.035,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: Container(
                              height: h * 0.04,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: inputColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment
                                  .center, // Center the child TextField
                              child: TextField(
                                controller: nameController,
                                maxLength: 36, // Limit to 36 characters
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '', // Hide the counter
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.zero, // Remove padding
                                ),
                                textAlign: TextAlign
                                    .left, // Keep text alignment to the left
                                style: TextStyle(fontSize: w * 0.035),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.01),
                      // Phone (Max 11 digits)
                      Row(
                        children: [
                          SizedBox(
                            width: w * 0.2,
                            child: Text('Phone:',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: w * 0.035,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: Container(
                              height: h * 0.04,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: inputColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment
                                  .center, // Center the child TextField
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 11, // Limit to 11 digits
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '', // Hide the counter
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.zero, // Remove padding
                                ),
                                textAlign: TextAlign
                                    .left, // Keep text alignment to the left
                                style: TextStyle(fontSize: w * 0.035),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.01),
                      // Message (Max 25 characters)
                      Row(
                        children: [
                          SizedBox(
                            width: w * 0.2,
                            child: Text('Message:',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: w * 0.035,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: Container(
                              height: h * 0.04,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: inputColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment
                                  .center, // Center the child TextField
                              child: TextField(
                                controller: instructionController,
                                maxLength: 36, // Limit to 25 characters
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '', // Hide the counter
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.zero, // Remove padding
                                ),
                                textAlign: TextAlign
                                    .left, // Keep text alignment to the left
                                style: TextStyle(fontSize: w * 0.035),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.02),
                      // Pin Location
                      Center(
                        child: Text(
                          'Pin your location',
                          style: TextStyle(
                              color: textColor,
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Container(
                        width: w * 0.8,
                        height: h * 0.2,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _currentPosition == null
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white))
                              : FlutterMap(
                                  mapController: mapController,
                                  options: MapOptions(
                                    initialCenter: _currentPosition!,
                                    initialZoom: 15.0,
                                    onTap: (tapPos, latlng) {
                                      setState(() => _markerPosition = latlng);
                                      _updateMarker();
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(markers: _markers),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Center(
                        child: Text(
                          'Tap to place marker or long press to adjust',
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: w * 0.03,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.02),

                // Delivery Info + Time Slots
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    children: [
                      Text('Delivery Info',
                          style: TextStyle(
                              color: textColor,
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: h * 0.02),
                      Text('Select delivery time slots',
                          style: TextStyle(
                              color: textColor,
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w500)),
                      Text('(Not guaranteed to deliver on time but we will try)',
                          style: TextStyle(
                              color: textColor,
                              fontSize: w * 0.025,
                              fontWeight: FontWeight.w300)),
                      SizedBox(height: h * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: slots
                            .map(
                              (t) => Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildTimeSlotButton(t, w, h,
                                      selectedSlotColor, unselectedSlotColor),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: h * 0.02),
                      const Divider(color: borderColor),
                      SizedBox(height: h * 0.02),

                      // Order summary
                      Text('Order summary:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: h * 0.01),
                      if (widget.regularGallon > 0)
                        _buildSummaryRow(
                          'Regular gallon:',
                          '₱${widget.ownerShopDetails.regularGallonPrice.toStringAsFixed(0)}',
                          '${widget.regularGallon}x',
                          w,
                        ),
                      if (widget.dispenserGallon > 0)
                        _buildSummaryRow(
                          'Dispenser gallon:',
                          '₱${widget.ownerShopDetails.dispenserGallonPrice.toStringAsFixed(0)}',
                          '${widget.dispenserGallon}x',
                          w,
                        ),
                      if (totalBorrowCount > 0)
                        _buildSummaryRow(
                          'Borrow gallon:',
                          '₱${widget.borrowPrice.toStringAsFixed(0)}',
                          '${totalBorrowCount}x',
                          w,
                        ),
                      if (widget.swap)
                        _buildSummaryRow(
                          'Swap gallon:',
                          '₱0',
                          '${widget.regularGallon + widget.dispenserGallon}x',
                          w,
                        ),
                      SizedBox(height: h * 0.015),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment method:',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: w * 0.035,
                                  fontWeight: FontWeight.w500)),
                          Text('Cash On Delivery',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: w * 0.035,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SizedBox(height: h * 0.02),
                      const Divider(color: borderColor),
                      SizedBox(height: h * 0.02),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ₱${computedTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              // 1) Simple validations
                              if (_markerPosition == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please pin your location on the map'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedTimeSlot == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select a delivery time slot'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (nameController.text.isEmpty ||
                                  phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please fill in all required fields'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // 1) build a local Order
                              final newOrder = Order(
                                id: '', // or let server fill it
                                customerId: widget
                                    .customerId, // the customerId you passed
                                shopId:
                                    widget.stationId, // the shop you clicked
                                ownerName: widget.ownerName,
                                shopName: widget.shopName,
                                orderedBy: nameController.text,
                                phone: phoneController.text,
                                timeSlot: selectedTimeSlot!,
                                message: instructionController.text,
                                regularCount: widget.regularGallon,
                                dispenserCount: widget.dispenserGallon,
                                borrow: widget.borrow,
                                swap: widget.swap,
                                total: computedTotal,
                                latitude: _markerPosition!.latitude,
                                longitude: _markerPosition!.longitude,
                              );

                              // 2) show the “sent” overlay
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => Center(
                                    child: Image.asset('images/order_msg.png')),
                              );
                              await Future.delayed(const Duration(seconds: 3));
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop(); // dismiss overlay

                              // 3) POST to backend
                              try {
                                await ApiService.createOrder(newOrder);
                                // optionally show a success toast/snackbar
                                // ignore: use_build_context_synchronously
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to place order: $e')),
                                );
                              }

                              // 4) back to home
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotButton(
      String time, double w, double h, Color sel, Color unsel) {
    final isSel = selectedTimeSlot == time;
    return GestureDetector(
      onTap: () => setState(() => selectedTimeSlot = time),
      child: Container(
        height: h * 0.045,
        decoration: BoxDecoration(
          color: isSel ? sel : unsel,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(time,
            style: TextStyle(
                color: Colors.white,
                fontSize: w * 0.035,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String price, String count, double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: w * 0.4,
              child: Text(label,
                  style: TextStyle(color: Colors.white, fontSize: w * 0.035))),
          const Spacer(),
          Text(price,
              style: TextStyle(color: Colors.white, fontSize: w * 0.035)),
          const SizedBox(width: 16),
          Text(count,
              style: TextStyle(color: Colors.white, fontSize: w * 0.035)),
        ],
      ),
    );
  }
}
