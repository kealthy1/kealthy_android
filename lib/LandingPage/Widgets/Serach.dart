import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Riverpod/Searchbar.dart';

class SearchInput extends ConsumerWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintIndex = ref.watch(searchHintProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            width: screenWidth * 0.7,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search \"${hints[hintIndex]}\"",
                hintStyle: const TextStyle(color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(searchHintProvider.notifier).nextHint();
          },
          child: Container(
            height: screenHeight * 0.06,
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[500],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
