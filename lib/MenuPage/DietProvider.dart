import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'menu_item.dart';

final dietProvider = FutureProvider<List<DietItem>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('Diets').get();

  List<DietItem> dietItems = [];

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final dietItem = DietItem.fromFirestore(data);
    dietItems.add(dietItem);
  }

  return dietItems;
});
class PaginatedDietState {
  final List<DietItem> items;
  final bool isLoading;
  final bool hasMore;

  PaginatedDietState({
    required this.items,
    required this.isLoading,
    required this.hasMore,
  });
}

class PaginatedDietNotifier extends StateNotifier<PaginatedDietState> {
  PaginatedDietNotifier(this.ref)
      : super(PaginatedDietState(items: [], isLoading: true, hasMore: true)) {
    _loadInitialItems();
  }

  final Ref ref;
  static const int _limit = 1;

  Future<void> _loadInitialItems() async {
    final allItems = await ref.read(dietProvider.future);
    state = PaginatedDietState(
      items: allItems.take(_limit).toList(),
      isLoading: false,
      hasMore: allItems.length > _limit,
    );
  }

  Future<void> loadMoreItems() async {
    if (!state.hasMore || state.isLoading) return;

    state = PaginatedDietState(
        items: state.items, isLoading: true, hasMore: state.hasMore);

    final allItems = await ref.read(dietProvider.future);
    final newItems = allItems.skip(state.items.length).take(_limit).toList();

    state = PaginatedDietState(
      items: [...state.items, ...newItems],
      isLoading: false,
      hasMore: allItems.length > state.items.length + newItems.length,
    );
  }
}

final paginatedDietProvider =
    StateNotifierProvider<PaginatedDietNotifier, PaginatedDietState>((ref) {
  return PaginatedDietNotifier(ref);
});
