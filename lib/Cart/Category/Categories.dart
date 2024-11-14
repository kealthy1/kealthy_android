import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Services/FirestoreCart.dart';

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
            ? const Center(
                child: Text(
                  'No items in Cart',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: cartItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final isLoading =
                      ref.watch(addCartProvider.notifier).isLoading(item.id);
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
                    isLoading: isLoading,
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
  final bool isLoading;

  const CartItemWidget({
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              if (item.imageUrl.startsWith('http'))
                CachedNetworkImage(
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  imageUrl: item.imageUrl,
                )
              else
                Image.asset(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              const SizedBox(
                height: 3,
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Text(
                  "Remove Item",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.05),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove),
                  color: Colors.green,
                  iconSize: 20,
                  onPressed: onDecrement,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  color: Colors.green,
                  iconSize: 20,
                  onPressed: onIncrement,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
