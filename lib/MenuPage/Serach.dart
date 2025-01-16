import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Riverpod/Searchbar.dart';
import 'Search_provider.dart';

final searchProvider = StateProvider<String>((ref) => '');

class SearchAndFilter extends ConsumerStatefulWidget {
  const SearchAndFilter({super.key});

  @override
  _SearchAndFilterState createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends ConsumerState<SearchAndFilter> {
  late TextEditingController searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintIndex = ref.watch(searchHintProvider);
    final hints = ref.read(searchHintProvider.notifier).hints;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                      if (value.isEmpty) {
                        ref.read(searchProvider.notifier).state = '';
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          searchController.text.trim();
                        },
                        child: const Icon(
                          CupertinoIcons.search,
                          color: Color(0xFF273847),
                          size: 30,
                        ),
                      ),
                      hintText:
                          !_focusNode.hasFocus && searchController.text.isEmpty
                              ? 'Search "${hints[hintIndex]}"'
                              : '',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
