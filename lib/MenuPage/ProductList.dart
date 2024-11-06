import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_item.dart';

final searchQueryProvider =
    StateProvider<String>((ref) => '');

final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final searchQuery =
      ref.watch(searchQueryProvider.notifier).state;

  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection('Products')
      .where('Name', isGreaterThanOrEqualTo: searchQuery)
      .where('Name',
          isLessThanOrEqualTo: '$searchQuery\uf8ff')
      .get();

  List<MenuItem> menuItems = [];

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final menuItem = MenuItem.fromFirestore(data);
    menuItems.add(menuItem);
  }

  return menuItems;
});

final searchAndFilterProvider = FutureProvider<List<MenuItem>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final firestore = FirebaseFirestore.instance;

  Query query =
      firestore.collection('Products').where('Category', isEqualTo: 'Drinks');

  final querySnapshot = await query.get();

  if (querySnapshot.docs.isEmpty) {}

  List<MenuItem> allMenuItems = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem.fromFirestore(data);
  }).toList();

  if (searchQuery.isEmpty) {
    return allMenuItems;
  }

  List<MenuItem> filteredMenuItems = allMenuItems.where((item) {
    final itemName = item.name.toLowerCase();
    return itemName.contains(searchQuery);
  }).toList();

  return filteredMenuItems;
});
// ignore: non_constant_identifier_names
final SnaksFilterProvider = FutureProvider<List<MenuItem>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final firestore = FirebaseFirestore.instance;

  Query query =
      firestore.collection('Products').where('Category', isEqualTo: 'Snacks');

  final querySnapshot = await query.get();

  if (querySnapshot.docs.isEmpty) {}

  List<MenuItem> allMenuItems = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem.fromFirestore(data);
  }).toList();

  if (searchQuery.isEmpty) {
    return allMenuItems;
  }

  List<MenuItem> filteredMenuItems = allMenuItems.where((item) {
    final itemName = item.name.toLowerCase();
    return itemName.contains(searchQuery);
  }).toList();

  return filteredMenuItems;
});
// ignore: non_constant_identifier_names
final FoodFilterProvider = FutureProvider<List<MenuItem>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final firestore = FirebaseFirestore.instance;

  Query query =
      firestore.collection('Products').where('Category', isEqualTo: 'Food');

  final querySnapshot = await query.get();

  if (querySnapshot.docs.isEmpty) {}

  List<MenuItem> allMenuItems = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem.fromFirestore(data);
  }).toList();

  if (searchQuery.isEmpty) {
    return allMenuItems;
  }

  List<MenuItem> filteredMenuItems = allMenuItems.where((item) {
    final itemName = item.name.toLowerCase();
    return itemName.contains(searchQuery);
  }).toList();

  return filteredMenuItems;
});

