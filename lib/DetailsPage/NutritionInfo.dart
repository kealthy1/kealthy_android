import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MenuPage/menu_item.dart';
import '../Services/FirestoreCart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final averageStarsProvider =
    FutureProvider.family<double, String>((ref, productName) async {
  final response = await http.get(
    Uri.parse('https://api-jfnhkjk4nq-uc.a.run.app/rate/$productName'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return double.parse(data['averageStars']);
  } else {
    throw Exception('Failed to fetch average stars');
  }
});

class RedNutritionSection extends ConsumerWidget {
  final MenuItem menuItem;

  const RedNutritionSection({
    required this.menuItem,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageStarsAsync = ref.watch(averageStarsProvider(menuItem.name));
    final cartItems = ref.watch(sharedPreferencesCartProvider);

    final cartNotifier = ref.read(sharedPreferencesCartProvider.notifier);

    final isItemInCart = cartItems.any((item) => item.name == menuItem.name);
    final cartItem = isItemInCart
        ? cartItems.firstWhere((item) => item.name == menuItem.name)
        : null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    averageStarsAsync.when(
                      data: (averageStars) => Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < averageStars.floor()) {
                              return const Icon(Icons.star_outlined,
                                  color: Colors.amber, size: 15);
                            } else if (index == averageStars.floor() &&
                                averageStars % 1 != 0) {
                              return const Icon(Icons.star_half,
                                  color: Colors.amber, size: 15);
                            } else {
                              return const Icon(Icons.star_border,
                                  color: Colors.amber, size: 15);
                            }
                          }),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            '${averageStars.toStringAsFixed(1)} Ratings',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // CircularProgressIndicatorWidget(
              //   kealthyScore: double.parse(menuItem.kealthyScore),
              // )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: Offset(0, -4),
                        child: Text(
                          "₹",
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        "${menuItem.price.toStringAsFixed(0)} /-",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: Color(0xFF273847),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF273847),
                      ),
                    ),
                    child: isItemInCart
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  cartNotifier
                                      .decreaseItemQuantity(cartItem!.id);
                                },
                              ),
                              Text(cartItem!.quantity.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  )),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  cartNotifier
                                      .increaseItemQuantity(cartItem.id);
                                },
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              print(menuItem.macros);
                              final newCartItem = SharedPreferencesCartItem(
                                name: menuItem.name,
                                price: menuItem.price,
                                quantity: 1,
                                id: menuItem.name,
                                imageUrl: menuItem.imageUrls[0],
                                EAN: menuItem.EAN,
                              );
                              cartNotifier.addItemToCart(newCartItem);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "ADD",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Text(
              "(Inclusive of all taxes)",
              style: GoogleFonts.poppins(
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (menuItem.totalFat != 'Not Applicable')
              Expanded(
                child: _buildDataContainer(
                  color: Colors.blue.shade50,
                  context,
                  'Macros',
                  menuItem.macros.where((macro) => macro != '').toList(),
                  icon: Icons.energy_savings_leaf,
                ),
              ),
            const SizedBox(width: 5),
            if (menuItem.micros.isNotEmpty &&
                menuItem.micros.any((micro) => micro != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  color: Colors.green.shade50,
                  context,
                  'Micros',
                  menuItem.micros.where((micro) => micro != '').toList(),
                  icon: Icons.grain,
                ),
              ),
            const SizedBox(width: 5),
            if (menuItem.ingredients.isNotEmpty &&
                menuItem.ingredients.any((ingredients) => ingredients != ''))
              Expanded(
                child: _buildDataContainer(
                  color: Colors.yellow.shade50,
                  context,
                  'Ingredients',
                  menuItem.ingredients.map((ingredient) => ingredient).toList(),
                  icon: Icons.restaurant_menu,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDataContainer(
      BuildContext context, String title, List<String> data,
      {required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: () {
        _showDataDialog(context, title, data);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: Color(0xFF273847),
            ),
            const SizedBox(height: 5),
            _buildDataDisplay(title, data),
          ],
        ),
      ),
    );
  }

  Widget _buildDataDisplay(String title, List<String> data,
      {int maxItems = 3}) {
    final displayData =
        data.length > maxItems ? data.sublist(0, maxItems) : data;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Color(0xFF273847),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        const SizedBox(height: 5),
        Text(
          displayData.join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Color(0xFF273847),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'More',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDataDialog(BuildContext context, String title, List<String> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                color: Colors.grey, // Grey border for all cells
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(0.3), // Adjust column width
                1: FlexColumnWidth(1.0),
              },
              children: List.generate(data.length, (index) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (index + 1).toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF273847),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF273847),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
