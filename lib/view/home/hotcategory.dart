import 'package:flutter/material.dart';

class HotPage extends StatelessWidget {
  const HotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hot Items')),
      body: const Center(child: Text('🔥 Welcome to Hot Category')),
    );
  }
}
