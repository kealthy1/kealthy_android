import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Maps/Widgets/SavedAdress.dart';
import 'package:kealthy/Payment/payment.dart';
import 'Bill.dart';
import '../Maps/Widgets/Deliveryinst.dart';

class AdressPage extends ConsumerWidget {
  final double totalPrice;
  final double? totalDistance;
 

  const AdressPage(
      {super.key,
      required this.totalPrice,
      this.totalDistance,
    });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 214, 214),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 218, 214, 214),
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Confirm Address',
          style: TextStyle(fontFamily: "poppins"),
        ),
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
                    totalPrice: totalPrice, time: '',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PaymentSection(
              totalAmountToPay: totalPrice,
            ),
          )
        ],
      ),
    );
  }
}
