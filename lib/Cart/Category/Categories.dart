import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Services/FirestoreCart.dart';

class CategoryContainer extends ConsumerWidget {
  final String category;
  final List<CartItem> items;
  final double screenWidth;
  final double screenHeight;

  const CategoryContainer({
    required this.category,
    required this.items,
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems =
        items.where((item) => item.category == category).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        filteredItems.isEmpty
            ? Center(
                child: Text(
                  'No items in $category',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: filteredItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return CartItemWidget(
                    item: item,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onIncrement: () => ref
                        .read(addCartProvider.notifier)
                        .incrementItem(item.id),
                    onDecrement: () => ref
                        .read(addCartProvider.notifier)
                        .decrementItem(item.id),
                    onDelete: () =>
                        ref.read(addCartProvider.notifier).removeItem(item.id),
                  );
                },
              ),
      ],
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
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
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column for Image and Delete Button
          Column(
            children: [
              if (item.imagePath.startsWith('http'))
                Image.network(
                  item.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              else
                Image.asset(
                  item.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              const SizedBox(
                height: 3,
              ),
              GestureDetector(onTap: onDelete,
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
