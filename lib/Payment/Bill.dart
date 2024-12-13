import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Maps/SelectAdress.dart';
import 'payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalDistanceProvider = FutureProvider<double?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('selectedDistance');
});

class BillDetails extends ConsumerWidget {
  final double totalPrice;
  final String time;

  const BillDetails({
    super.key,
    required this.totalPrice,
    required this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDistanceAsync = ref.watch(totalDistanceProvider);

    return totalDistanceAsync.when(
      data: (totalDistance) {
        double originalFee = 0;
        double discountedFee = 0;

        if (totalDistance != null) {
          // Calculate original fee based on the entire distance
          originalFee = totalDistance * 10;

          // Apply the discount for the first 10 km
          if (totalDistance > 10) {
            double chargeableDistance = totalDistance - 10;
            discountedFee = chargeableDistance * 10; // Fee for distance > 10 km
          }
        }

        double totalToPay = totalPrice + discountedFee;

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
                          amount: '₹${totalPrice.toStringAsFixed(0)}/-',
                        ),
                        const SizedBox(height: 5),
                        _BillItem(
                          amountColor: totalDistance != null
                              ? Colors.green
                              : Colors.grey,
                          title:
                              'Delivery Fee | ${totalDistance != null ? totalDistance.toStringAsFixed(2) : 'N/A'} km',
                          amount: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${originalFee.toStringAsFixed(0)} /-',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              totalDistance != null && totalDistance <= 10
                                  ? const Text(
                                      'Free',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      '₹${discountedFee.toStringAsFixed(0)}/-',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 20),
                        _BillItem(
                          amountColor: Colors.grey,
                          title: 'To Pay',
                          amount: '₹${totalToPay.toStringAsFixed(0)}/-',
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading distance: $error'),
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final Color amountColor;
  final String title;
  final dynamic amount;
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
      mainAxisAlignment: isRightAligned
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: "poppins",
            ),
          ),
        ),
        if (amount is String)
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontFamily: "poppins",
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          )
        else if (amount is Widget)
          amount,
      ],
    );
  }
}

Future<void> saveSelectedAddress(Address address, double distance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedAddressId', address.id);
  await prefs.setString('Name', address.name);
  await prefs.setString('selectedRoad', address.road);
  await prefs.setString('landmark', address.landmark);

  await prefs.setString('selectedType', address.type);
  if (address.directions != null) {
    await prefs.setString('selectedDirections', address.directions!);
  }
  await prefs.setDouble('selectedLatitude', address.latitude);
  await prefs.setDouble('selectedLongitude', address.longitude);
  await prefs.setDouble('selectedDistance', distance);

  print(distance);
}
