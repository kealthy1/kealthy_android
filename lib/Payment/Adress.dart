import 'package:flutter/material.dart';
import 'package:kealthy/Maps/Widgets/SavedAdress.dart';
import 'package:kealthy/Payment/payment.dart';
import 'Bill.dart';
import '../Maps/Widgets/Deliveryinst.dart';

class AdressPage extends StatefulWidget {
  final double totalPrice;
  final double? totalDistance;
  final double? totalAmountToPay;
  final String? time;

  const AdressPage(
      {super.key,
      required this.totalPrice,
      this.totalDistance,
      required this.totalAmountToPay,
      required this.time});

  @override
  _AdressPageState createState() => _AdressPageState();
}

class _AdressPageState extends State<AdressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 214, 214),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 218, 214, 214),
        automaticallyImplyLeading: false,
        title: const Text('Address'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SavedAddress(),
                  const DeliveryInstructionsSection(),
                  BillDetails(
                    totalPrice: widget.totalPrice,
                    time: widget.time ?? 'No Slot selected',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PaymentSection(
              totalAmountToPay: widget.totalPrice,
            ),
          )
        ],
      ),
    );
  }
}
