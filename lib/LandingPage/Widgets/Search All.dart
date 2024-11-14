import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'searchprovider.dart';

class SearchBarall extends ConsumerStatefulWidget {
  final Function(String) onSearch;

  const SearchBarall({super.key, required this.onSearch});

  @override
  ConsumerState<SearchBarall> createState() => _SearchBarallState();
}

class _SearchBarallState extends ConsumerState<SearchBarall> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productSuggestions = ref.watch(productProvider);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    ref
                        .read(productProvider.notifier)
                        .fetchProductSuggestions(value);
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        color: Colors.green,
                        iconSize: 30,
                        onPressed: () {
                          widget.onSearch(_controller.text);
                        },
                        icon: const Icon(Icons.search)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.green)),
                    hintText: "Search for a product",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                if (productSuggestions.isNotEmpty)
                  Container(
                    color: Colors.transparent,
                    height: 200,
                    child: ListView.builder(
                      itemCount: productSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = productSuggestions[index];
                        return GestureDetector(
                          onTap: () {
                            _controller.text = suggestion.name;
                            widget.onSearch(suggestion.name);
                            // ignore: invalid_use_of_protected_member
                            ref.read(productProvider.notifier).state = [];
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    imageUrl: suggestion.imageUrl,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    suggestion.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
