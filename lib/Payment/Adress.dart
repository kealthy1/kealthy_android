import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Payment/Addressconfirm.dart';
import 'package:kealthy/Payment/payment.dart';
import 'Bill.dart';
import 'Deliveryinst.dart';

class AdressPage extends ConsumerWidget {
  final double totalPrice;
  final double? totalDistance;

  const AdressPage({
    super.key,
    required this.totalPrice,
    this.totalDistance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 214, 214),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 218, 214, 214),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Confirm Address',
          style: TextStyle(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ConfirmOrder(),
                  ),
                  const DeliveryInstructionsSection(),
                  BillDetails(
                    totalPrice: totalPrice,
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
