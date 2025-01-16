import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_item.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider.notifier).state;

  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection('Products')
      .where('Name', isGreaterThanOrEqualTo: searchQuery)
      .where('Name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
      .get();

  List<MenuItem> menuItems = [];

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final menuItem = MenuItem.fromFirestore(data);
    menuItems.add(menuItem);
  }

  return menuItems;
});
