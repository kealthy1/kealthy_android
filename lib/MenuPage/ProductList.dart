import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_item.dart';

// Keep your existing menuProvider unchanged
final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('Products').get();

  List<MenuItem> menuItems = [];

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final menuItem = MenuItem.fromFirestore(data);
    menuItems.add(menuItem);
  }

  return menuItems;
});


class PaginatedMenuState {
  final List<MenuItem> items;
  final bool isLoading;
  final bool hasMore;

  PaginatedMenuState({
    required this.items,
    required this.isLoading,
    required this.hasMore,
  });
}

class PaginatedMenuNotifier extends StateNotifier<PaginatedMenuState> {
  PaginatedMenuNotifier(this.ref)
      : super(PaginatedMenuState(items: [], isLoading: true, hasMore: true)) {
    _loadInitialItems();
  }

  final Ref ref;
  static const int _limit = 1;

  Future<void> _loadInitialItems() async {
    final allItems = await ref.read(menuProvider.future);
    state = PaginatedMenuState(
      items: allItems.take(_limit).toList(),
      isLoading: false,
      hasMore: allItems.length > _limit,
    );
  }

  Future<void> loadMoreItems() async {
    if (!state.hasMore || state.isLoading) return;

    state = PaginatedMenuState(
        items: state.items, isLoading: true, hasMore: state.hasMore);

    final allItems = await ref.read(menuProvider.future);
    final newItems = allItems.skip(state.items.length).take(_limit).toList();

    state = PaginatedMenuState(
      items: [...state.items, ...newItems],
      isLoading: false,
      hasMore: allItems.length > state.items.length + newItems.length,
    );
  }
}

final paginatedMenuProvider =
    StateNotifierProvider<PaginatedMenuNotifier, PaginatedMenuState>((ref) {
  return PaginatedMenuNotifier(ref);
});
