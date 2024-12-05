import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Riverpod/Searchbar.dart';
import '../../Services/Navigation.dart';
import '../Allitems.dart';

class SearchInput extends ConsumerWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintIndex = ref.watch(searchHintProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final searchController = TextEditingController();
    final hints = ref.read(searchHintProvider.notifier).hints;
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
            child: Stack(
              children: [
                TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.of(context).push(
                      SeamlessRevealRoute(
                        page: const AllItemsPage(),
                      ),
                    );
                  },
                  controller: searchController,
                  style: const TextStyle(
                    color: Color(0xFF273847),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.search),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF273847)),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInExpo)),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 48),
                        key: ValueKey<int>(hintIndex),
                        child: Row(
                          children: [
                            const Text(
                              'Search ',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "poppins",
                                color: Color(0xFF273847),
                              ),
                            ),
                            Text(
                              hints.isNotEmpty
                                  ? '"${hints[hintIndex]}"'
                                  : '"Salad"',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "poppins",
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF273847),
                              ),
                            ),
                          ],
                        ),
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
