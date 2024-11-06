import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Maps/SelectAdress.dart';
import 'payment_service.dart';

class BillDetails extends StatefulWidget {
  final double totalPrice;
  final double tip;
  final double gst;
  final String time;

  const BillDetails({
    super.key,
    required this.totalPrice,
    this.tip = 0.00,
    this.gst = 23.58,
    required this.time,
  });

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  double? totalDistance;

  @override
  void initState() {
    super.initState();
    _loadDistanceFromPreferences();
  }

  Future<void> _loadDistanceFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalDistance = prefs.getDouble('selectedDistance');
    });
  }

  @override
  Widget build(BuildContext context) {
    double deliveryFee = (totalDistance != null ? totalDistance! * 10 : 0);
    double totalToPay = widget.totalPrice + deliveryFee;
    PaymentService().updateTotalToPay(totalToPay);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Bill Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _BillItem(
                      amountColor: Colors.grey,
                      title: 'Item Total',
                      amount: '₹${widget.totalPrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 5),
                    _BillItem(
                      amountColor: Colors.grey,
                      title:
                          'Delivery Fee | ${totalDistance != null ? totalDistance!.toStringAsFixed(2) : 'N/A'} km',
                      amount: '₹${deliveryFee.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 20),
                    _BillItem(
                      amountColor: Colors.grey,
                      title: 'To Pay',
                      amount: '₹${totalToPay.toStringAsFixed(2)}',
                      isRightAligned: true,
                      isBold: true,
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
}

class _BillItem extends StatelessWidget {
  final Color amountColor;
  final String title;
  final String amount;

  final bool isRightAligned;
  final bool isBold;

  const _BillItem({
    required this.amountColor,
    required this.title,
    required this.amount,
    this.isRightAligned = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isRightAligned ? MainAxisAlignment.start : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(color: amountColor),
        ),
      ],
    );
  }
}

Future<void> saveSelectedAddress(Address address, double distance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedAddressId', address.id);
  await prefs.setString('Name', address.Name);
  await prefs.setString('selectedRoad', address.road);
  await prefs.setString('landmark', address.Landmark);

  await prefs.setString('selectedType', address.type);
  if (address.directions != null) {
    await prefs.setString('selectedDirections', address.directions!);
  }
  await prefs.setDouble('selectedLatitude', address.latitude);
  await prefs.setDouble('selectedLongitude', address.longitude);
  await prefs.setDouble('selectedDistance', distance);

  print(distance);
}
