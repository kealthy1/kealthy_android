import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/FirestoreCart.dart';

class CategoryContainer extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;

  const CategoryContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cartItems.isEmpty
            ? Center(
                child: Text(
                  'No items in Cart',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: cartItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return CartItemWidget(
                    item: item,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onIncrement: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .increaseItemQuantity(item.name),
                    onDecrement: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .decreaseItemQuantity(item.name),
                    onDelete: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .removeItemFromCart(item.name),
                  );
                },
              ),
      ],
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final SharedPreferencesCartItem item;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const CartItemWidget({
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF273847),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  '₹${item.price.toStringAsFixed(0)} /-',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF273847),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      "Remove",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      color: Color(0xFF273847),
                      iconSize: 20,
                      onPressed: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${item.quantity}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: Color(0xFF273847),
                      iconSize: 20,
                      onPressed: onIncrement,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(0)} /-',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
