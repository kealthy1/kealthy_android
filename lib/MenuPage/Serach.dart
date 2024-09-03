import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define providers
final searchProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class SearchAndFilter extends ConsumerWidget {
  const SearchAndFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.watch(searchProvider));
    ref.watch(selectedCategoryProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => ref.read(searchProvider.notifier).state = value,
                  decoration: const InputDecoration(
                    hintText: 'Search for Food',
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.green[400], shape: BoxShape.circle),
                  child: const Icon(Icons.search_sharp, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryButton('Pasta', Icons.local_pizza, ref),
              _buildCategoryButton('Salad', Icons.fastfood, ref),
              _buildCategoryButton('Vegetables', Icons.local_drink, ref),
              _buildCategoryButton('Rice', Icons.local_offer, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () {
          ref.read(selectedCategoryProvider.notifier).state =
              selectedCategory == title ? null : title;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCategory == title ? Colors.orange[400] : Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
