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
        double discountedFee = 0;
        bool isFreeDelivery = false;
        double additionalCharge = 0;

        Future<void> saveInstantDeliveryCharge(double charge) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('instantDeliveryCharge', charge);
        }

        selectedSlotAsync.whenData((selectedSlot) {
          if (selectedSlot != null &&
              selectedSlot.startsWith("Instant Delivery ⚡")) {
            additionalCharge = 50;
          } else {
            additionalCharge = 0;
          }
          saveInstantDeliveryCharge(additionalCharge);
        });

        if (totalDistance != null) {
          // Delivery fee logic
          if (totalPrice >= 199) {
            if (totalDistance <= 7) {
              discountedFee = 0;
              isFreeDelivery = true;
            } else if (totalDistance <= 15) {
              discountedFee = (totalDistance - 7) * 8;
            }
          } else {
            if (totalDistance <= 7) {
              discountedFee = 50;
            } else if (totalDistance <= 15) {
              discountedFee = 50 + ((totalDistance - 7) * 10);
            }
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
                    Text(
                      (totalPrice >= 199 &&
                              totalDistance != null &&
                              totalDistance.ceil() <= 7)
                          ? 'You Unlocked A Free Delivery 🎉'
                          : (totalPrice < 199 &&
                                  totalDistance != null &&
                                  totalDistance.ceil() <= 7)
                              ? 'Purchase for ₹${(199 - totalPrice).toStringAsFixed(0)} More to unlock free Delivery!'
                              : (totalPrice < 199 &&
                                      totalDistance != null &&
                                      totalDistance.ceil() > 7)
                                  ? 'Purchase for ₹${(199 - totalPrice).toStringAsFixed(0)} and pay delivery fee ₹${((totalDistance - 7) * 8).toStringAsFixed(0)}/- Only'
                                  : (totalPrice >= 199 &&
                                          totalDistance != null &&
                                          totalDistance.ceil() > 7)
                                      ? 'Unlocked A Discounted Delivery! 🎉 You saved ₹${((totalDistance * 10) - discountedFee).toStringAsFixed(0)} on This Order!'
                                      : '',
                      style: GoogleFonts.montserrat(
                        color: (totalPrice >= 199 &&
                                totalDistance != null &&
                                totalDistance.ceil() <= 7)
                            ? Colors.green // Free Delivery (Green)
                            : (totalPrice < 199 &&
                                    totalDistance != null &&
                                    totalDistance.ceil() <= 7)
                                ? Colors.orange // Unlock Free Delivery (Orange)
                                : (totalPrice < 199 &&
                                        totalDistance != null &&
                                        totalDistance.ceil() > 7)
                                    ? Colors
                                        .red // Purchase & Pay Delivery Fee (Red)
                                    : (totalPrice >= 199 &&
                                            totalDistance != null &&
                                            totalDistance.ceil() > 7)
                                        ? Colors
                                            .green // Discounted Delivery (Blue)
                                        : Colors
                                            .orange, // Default color (if none of the conditions match)
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _BillItem(
                          isBold: true,
                          amountColor: Colors.black,
                          title: 'Item Total',
                          amount: '₹${totalPrice.toStringAsFixed(0)}/-',
                        ),
                        const SizedBox(height: 5),
                        _BillItem(
                          isBold: true,
                          amountColor:
                              isFreeDelivery ? Colors.green : Colors.black,
                          title:
                              'Delivery Fee | ${totalDistance != null ? totalDistance.toStringAsFixed(2) : 'N/A'} km',
                          amount: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFreeDelivery)
                                Text(
                                  '₹${(totalDistance != null ? (totalDistance * 10).toStringAsFixed(0) : '0')} /-',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (totalDistance != null && totalDistance >= 7)
                                Text(
                                  '₹${(totalDistance * 10).toStringAsFixed(0)} ',
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
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
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        _BillItem(
                          amountColor: Colors.black,
                          title: 'Handling Fee',
                          amount: '₹5/-',
                          isBold: true,
                        ),
                        const SizedBox(height: 5),
                        if (additionalCharge > 0)
                          _BillItem(
                            amountColor: Colors.black,
                            title: 'Instant Delivery Charge',
                            isBold: true,
                            amount: '₹${additionalCharge.toStringAsFixed(0)}/-',
                          ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 20),
                        _BillItem(
                          amountColor: Colors.black,
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
      loading: () => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Color(0xFF273847),
          size: 30,
        ),
      ),
      error: (error, stack) => Center(
        child: SizedBox.shrink(),
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
            style: GoogleFonts.montserrat(
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
