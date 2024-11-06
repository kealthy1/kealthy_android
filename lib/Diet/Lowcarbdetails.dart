import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../DetailsPage/HomePage.dart';
import '../MenuPage/menu_item.dart';
import 'Meal_Container.dart';

class LowCarbDietNotifier extends StateNotifier<List<QueryDocumentSnapshot>> {
  LowCarbDietNotifier() : super([]) {
    fetchAllMeals();
  }

  Future<void> fetchAllMeals() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Products')
        .where('Diets', isEqualTo: 'Low Carb')
        .get();
    state = querySnapshot.docs;
  }

  void updateMeals(String searchQuery) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Products')
        .where('Diets', isEqualTo: 'Low Carb')
        .get();

    List<QueryDocumentSnapshot> filteredMeals =
        querySnapshot.docs.where((meal) {
      final mealData = meal.data() as Map<String, dynamic>;
      final mealName = mealData['Name'].toString().toLowerCase();
      final mealDescription = mealData['Description'].toString().toLowerCase();
      return mealName.contains(searchQuery) ||
          mealDescription.contains(searchQuery);
    }).toList();

    state = filteredMeals;
  }
}

final LowCarbDietProvider =
    StateNotifierProvider<LowCarbDietNotifier, List<QueryDocumentSnapshot>>(
        (ref) {
  return LowCarbDietNotifier();
});

class LowCarbDietDetailsPage extends ConsumerWidget {
  const LowCarbDietDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(LowCarbDietProvider);
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Low Carb Diet Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadField<String>(
              suggestionsCallback: (pattern) async {
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('Products')
                    .where('Diets', isEqualTo: 'Low Carb')
                    .get();

                return querySnapshot.docs
                    .where((meal) {
                      final mealData = meal.data() as Map<String, dynamic>;
                      final mealName =
                          mealData['Name'].toString().toLowerCase();
                      return mealName.contains(pattern.toLowerCase());
                    })
                    .map((meal) => (meal.data() as Map<String, dynamic>)['Name']
                        .toString())
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  focusColor: Colors.white,
                  title: Text(suggestion),
                );
              },
              onSelected: (suggestion) {
                searchController.text = suggestion;
                ref
                    .read(LowCarbDietProvider.notifier)
                    .updateMeals(suggestion.toLowerCase());
              },
              decorationBuilder: (context, child) {
                return Material(
                  type: MaterialType.button,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
              },
              offset: const Offset(0, 12),
              constraints: const BoxConstraints(maxHeight: 500),
              builder: (context, controller, focusNode) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        hintText: 'Search',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.clear();
                            ref
                                .read(LowCarbDietProvider.notifier)
                                .fetchAllMeals();
                          },
                        ),
                        labelStyle: const TextStyle(color: Colors.green)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: meals.isEmpty
                  ? const Center(child: Text('No items found.'))
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final mealData =
                            meals[index].data() as Map<String, dynamic>;

                        double protein = double.tryParse(mealData['Protein']
                                .toString()
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0.0;
                        double fat = double.tryParse(mealData['Fat']
                                .toString()
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0.0;
                        double kcal = (mealData['Kcal'] as int).toDouble();
                        double price = (mealData['Price'] as int).toDouble();
                        double carbs = double.tryParse(mealData['Carbs']
                                .toString()
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0.0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  menuItem: MenuItem(
                                    name: mealData['Name'] as String,
                                    description:
                                        mealData['Description'] as String,
                                    imageUrl: mealData['ImageUrl'] as String,
                                    kcal: kcal,
                                    price: price,
                                    carbs: carbs,
                                    fat: fat,
                                    protein: protein,
                                    category: mealData['Category'] as String,
                                    time: mealData['Time'] as String,
                                    delivery: mealData['Delivery'] as String,
                                    rating: mealData['Rating'] as double,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: MealContainer(
                            title: mealData['Name'] as String,
                            description: mealData['Description'] as String,
                            imageUrl: mealData['ImageUrl'] as String,
                            kcal: kcal.toInt(),
                            price: price.toInt(),
                            carbs: carbs.toString(),
                            fat: fat.toString(),
                            protein: protein,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
