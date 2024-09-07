import 'package:flutter/material.dart';

class SearchBarall extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  SearchBarall({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final searchBarWidth = screenWidth * 0.8;

    return SizedBox(
      width: searchBarWidth,
      child: Stack(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            style: const TextStyle(fontSize: 16),
          ),
          Positioned(
            right: 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              child: ElevatedButton(
                onPressed: () {
                  // Handle search action
                  print('Search: ${_controller.text}');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 5,
                ),
                child: const Text('Search'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
