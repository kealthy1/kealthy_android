import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalDistanceProvider = FutureProvider<double?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('selectedDistance');
});

class BillDetails extends ConsumerWidget {
  final double totalPrice;

  const BillDetails({
    super.key,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDistanceAsync = ref.watch(totalDistanceProvider);

    return totalDistanceAsync.when(
      data: (totalDistance) {
        double originalFee = 0;
        double discountedFee = 0;
        bool isFreeDelivery = false;
        bool showUnlockMessage = false;

        if (totalDistance != null) {
          // Calculate original fee (total distance at standard rates)
          originalFee = totalDistance > 10
              ? (10 * 5) + ((totalDistance - 10) * 10)
              : totalDistance * 5;

          // Delivery fee logic
          if (totalPrice >= 499) {
            if (totalDistance > 10) {
              // First 10 km free, charge ₹10/km for remaining
              discountedFee = (totalDistance - 10) * 10;
            } else {
              // Free delivery for distances ≤ 10 km
              discountedFee = 0;
              isFreeDelivery = true;
            }
          } else {
            if (totalDistance > 10) {
              // Charge ₹5/km for first 10 km and ₹10/km for remaining
              discountedFee = (10 * 5) + ((totalDistance - 10) * 10);
            } else {
              // Charge ₹5/km for distances ≤ 10 km
              discountedFee = totalDistance * 5;
            }

            // Show "Unlock Free Delivery" message
            if (totalDistance <= 10) {
              showUnlockMessage = true;
            }
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
                    Text(
                      'Bill Details',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isFreeDelivery || showUnlockMessage)
                      Text(
                        isFreeDelivery
                            ? 'You Unlocked A Free Delivery 🎉'
                            : '🎉 Unlock Free delivery on bill amount above ₹499!',
                        style: GoogleFonts.poppins(
                          color: isFreeDelivery ? Colors.green : Colors.orange,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 10),
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
                          amountColor:
                              isFreeDelivery ? Colors.green : Colors.grey,
                          title:
                              'Delivery Fee | ${totalDistance != null ? totalDistance.toStringAsFixed(2) : 'N/A'} km',
                          amount: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFreeDelivery)
                                Text(
                                  '₹${originalFee.toStringAsFixed(0)} /-',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (isFreeDelivery) const SizedBox(width: 8),
                              isFreeDelivery
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
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (amount is String)
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          )
        else if (amount is Widget)
          amount,
      ],
    );
  }
}
