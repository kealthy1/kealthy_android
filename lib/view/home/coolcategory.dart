import 'package:flutter/material.dart';

class CoolPage extends StatelessWidget {
  const CoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cool Items')),
      body: const Center(child: Text('❄️ Welcome to Cool Category')),
    );
  }
}
