import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ProductList.dart';

final searchProvider = StateProvider<String>((ref) => '');

class SearchAndFilter extends ConsumerWidget {
  const SearchAndFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController =
        TextEditingController(text: ref.watch(searchProvider));

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
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                    if (value.isEmpty) {
                      ref.read(searchProvider.notifier).state = '';
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  searchController.text.trim();
                },
                child: const Icon(
                  Icons.search_sharp,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
