import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Name Entry')),
      body: const NameEntry(),
    );
  }
}

class NameEntry extends StatefulWidget {
  const NameEntry({super.key});

  @override
  _NameEntryState createState() => _NameEntryState();
}

class _NameEntryState extends State<NameEntry> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveName() async {
    if (_nameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('names').add({
        'name': _nameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name Saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveName,
            child: const Text('Save Name'),
          ),
        ],
      ),
    );
  }
}
