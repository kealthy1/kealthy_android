import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'searchprovider.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

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

    _controller.addListener(() {
      final currentText = _controller.text;
      ref.read(searchTextProvider.notifier).state = currentText;

      if (currentText.isEmpty) {
        // ignore: invalid_use_of_protected_member
        ref.read(productProvider.notifier).state = [];
      }
    });

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
    ref.watch(productProvider);
    ref.watch(searchTextProvider);

    return WillPopScope(
      onWillPop: () async {
        // ignore: invalid_use_of_protected_member
        ref.read(productProvider.notifier).state = [];
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
          child: Column(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  ref.read(searchTextProvider.notifier).state = value;
                  widget.onSearch(_controller.text);
                  if (value.isNotEmpty) {
                    ref
                        .read(productProvider.notifier)
                        .fetchProductSuggestions(value);
                  } else {
                    // ignore: invalid_use_of_protected_member
                    ref.read(productProvider.notifier).state = [];
                  }
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSearch(_controller.text);
                      }
                    },
                    icon: const Icon(CupertinoIcons.search),
                  ),
                  hintText: "Search",
                  hintStyle: const TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
