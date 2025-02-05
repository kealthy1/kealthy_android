import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalDistanceProvider = FutureProvider<double?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('selectedDistance');
});
final SlotProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedSlot');
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
    final selectedSlotAsync = ref.watch(SlotProvider);

    return totalDistanceAsync.when(
      data: (totalDistance) {
        double originalFee = 0;
        double discountedFee = 0;
        bool isFreeDelivery = false;
        bool showUnlockMessage = false;

        // Add ₹50 if selected slot is "Slot Delivery 📦"
        double additionalCharge = 0;

        Future<void> saveInstantDeliveryCharge(double charge) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('instantDeliveryCharge', charge);
        }

        selectedSlotAsync.whenData((selectedSlot) {
          print("Slot $selectedSlot");
          if (selectedSlot != null) {
            if (selectedSlot.startsWith("Instant Delivery ⚡")) {
              additionalCharge =
                  50; // Adding ₹50 if the slot starts with "Instant Delivery ⚡"
            } else {
              additionalCharge =
                  0; // Setting ₹0 if the slot does not start with "Instant Delivery ⚡"
            }
            saveInstantDeliveryCharge(additionalCharge);
          }
        });

        if (totalDistance != null) {
          int roundedDistance = totalDistance.ceil();

          // Calculate original fee (total distance at standard rates)
          originalFee = roundedDistance > 10
              ? (5 * 30) + (5 * 10) + ((roundedDistance - 10) * 10)
              : (roundedDistance <= 5
                  ? roundedDistance * 30
                  : (5 * 30) + ((roundedDistance - 5) * 10));

          // Delivery fee logic
          if (totalPrice >= 199) {
            if (roundedDistance <= 7) {
              discountedFee = 0;
              isFreeDelivery = true;
            } else if (roundedDistance <= 10) {
              discountedFee = (roundedDistance - 7) * 8;
            } else {
              discountedFee = (3 * 8) + ((roundedDistance - 10) * 10);
            }
          } else {
            if (roundedDistance <= 5) {
              discountedFee = 30;
            } else if (roundedDistance <= 10) {
              discountedFee = 30 + ((roundedDistance - 5) * 10);
            } else {
              discountedFee = 30 + (5 * 10) + ((roundedDistance - 10) * 10);
            }
          }

          if (totalPrice < 199 && roundedDistance <= 5) {
            showUnlockMessage = true;
          }

          _saveDeliveryFee(discountedFee);
        }

        double handlingFee = 5;
        double totalToPay =
            totalPrice + handlingFee + discountedFee + additionalCharge;

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
                  border:
                      Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Bill Details',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isFreeDelivery || showUnlockMessage)
                      Text(
                        isFreeDelivery
                            ? 'You Unlocked A Free Delivery 🎉'
                            : 'Purchase for ₹${(199 - totalPrice).toStringAsFixed(0)} More to unlock free Delivery!',
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (totalDistance != null && totalDistance >= 7)
                                Text(
                                  '₹${(totalDistance * 8).toStringAsFixed(0)} ',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.black,
                                      decorationStyle:
                                          TextDecorationStyle.solid),
                                ),
                              if (isFreeDelivery) const SizedBox(width: 8),
                              isFreeDelivery
                                  ? Text(
                                      'Free  ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      '₹${discountedFee.toStringAsFixed(0)}/-',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        _BillItem(
                          amountColor: Colors.grey,
                          title: 'Handling Fee',
                          amount: '₹5/-',
                        ),
                        const SizedBox(height: 5),
                        if (additionalCharge > 0)
                          _BillItem(
                            amountColor: Colors.grey,
                            title: 'Instant Delivery Charge',
                            amount: '₹${additionalCharge.toStringAsFixed(0)}/-',
                          ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 20),
                        _BillItem(
                          amountColor: Colors.grey,
                          title: 'To Pay',
                          amount: '₹${totalToPay.toStringAsFixed(0)}/-',
                          isRightAligned: true,
                          isBold: false,
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
      loading: () => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Color(0xFF273847),
          size: 30,
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading distance: $error'),
      ),
    );
  }

  Future<void> _saveDeliveryFee(double deliveryFee) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('deliveryFee', deliveryFee);
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
