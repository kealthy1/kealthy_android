import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Riverpod/CartItems.dart';

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
    final filteredItems = items.where((item) => item.category == category).toList();

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
                    onIncrement: () => ref.read(addCartProvider.notifier).incrementItem(item.id),
                    onDecrement: () => ref.read(addCartProvider.notifier).decrementItem(item.id),
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

  const CartItemWidget({
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 15.0,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 243, 243),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 12, 12, 12).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
