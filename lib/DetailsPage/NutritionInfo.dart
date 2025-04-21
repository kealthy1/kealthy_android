import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../MenuPage/menu_item.dart';
import '../Services/FirestoreCart.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  ⭐ Average‑stars provider
/// ─────────────────────────────────────────────────────────────────────────────
final averageStarsProvider =
    FutureProvider.family<double, String>((ref, productName) async {
  final res = await http
      .get(Uri.parse('https://api-jfnhkjk4nq-uc.a.run.app/rate/$productName'));

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return double.parse(data['averageStars']);
  }
  throw Exception('Failed to fetch average stars');
});

/// ─────────────────────────────────────────────────────────────────────────────
///  🟥  RedNutritionSection
/// ─────────────────────────────────────────────────────────────────────────────
class RedNutritionSection extends ConsumerWidget {
  final MenuItem menuItem;
  const RedNutritionSection({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* ── Providers ────────────────────────────────────────────────────────── */
    final averageStarsAsync = ref.watch(averageStarsProvider(menuItem.name));
    final cartNotifier = ref.read(sharedPreferencesCartProvider.notifier);
    final cartItems = ref.watch(sharedPreferencesCartProvider);

    final isItemInCart = cartItems.any((it) => it.name == menuItem.name);
    final cartItem = isItemInCart
        ? cartItems.firstWhere((it) => it.name == menuItem.name)
        : null;

    /* ── Helper: build the action pill ───────────────────────────────────── */
    Widget _buildActionPill() {
      final bool soldOut = menuItem.SOH == 0;

      // 1️⃣  SOLD‑OUT PILL  (disabled)
      if (soldOut) {
        return Container(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.30,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            'OUT OF STOCK',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }

      // 2️⃣  ITEM IN CART  ➜  show – qty +
      if (isItemInCart) {
        return Container(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.30,
          decoration: BoxDecoration(
            color: const Color(0xFF273847),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () =>
                    cartNotifier.decreaseItemQuantity(cartItem!.id),
              ),
              Text(
                cartItem!.quantity.toString(),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => cartNotifier.increaseItemQuantity(cartItem.id),
              ),
            ],
          ),
        );
      }

      // 3️⃣  DEFAULT ADD BUTTON
      return SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.30,
        child: ElevatedButton(
          onPressed: () {
            final newItem = SharedPreferencesCartItem(
              id: menuItem.name,
              name: menuItem.name,
              price: menuItem.price,
              quantity: 1,
              imageUrl: menuItem.imageUrls[0],
              EAN: menuItem.EAN,
            );
            cartNotifier.addItemToCart(newItem);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF273847),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'ADD',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    /* ── UI ───────────────────────────────────────────────────────────────── */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ── Title & rating ─────────────────────────────────────────────── */
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /* Name & stars */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text('${menuItem.name} ${menuItem.qty}',
                              style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 20)),
                        ),
                      ],
                    ),
                    averageStarsAsync.when(
                      data: (stars) => Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < stars.floor()) {
                              return const Icon(Icons.star_outlined,
                                  color: Colors.amber, size: 15);
                            } else if (i == stars.floor() && stars % 1 != 0) {
                              return const Icon(Icons.star_half,
                                  color: Colors.amber, size: 15);
                            }
                            return const Icon(Icons.star_border,
                                color: Colors.amber, size: 15);
                          }),
                          const SizedBox(width: 3),
                          Text('${stars.toStringAsFixed(1)} Ratings',
                              style: GoogleFonts.poppins(
                                  color: Colors.black87, fontSize: 12)),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /* ── Price & Action pill ────────────────────────────────────────── */
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /* Price */
              Row(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: const Text('₹', style: TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(width: 2),
                  Text('${menuItem.price.toStringAsFixed(0)} /-',
                      style: GoogleFonts.poppins(fontSize: 24)),
                ],
              ),
              /* Action pill */
              _buildActionPill(),
            ],
          ),
        ),
        Text('(Inclusive of all taxes)',
            style: GoogleFonts.poppins(fontSize: 12)),

        /* ── Nutrition / ingredients chips (unchanged) ─────────────────── */
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (menuItem.macros.any((m) => m != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  context,
                  'Macros',
                  menuItem.macros.where((m) => m.isNotEmpty).toList(),
                  icon: Icons.energy_savings_leaf,
                  color: Colors.blue.shade50,
                ),
              ),
            const SizedBox(width: 5),
            if (menuItem.micros.any((m) => m != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  context,
                  'Micros',
                  menuItem.micros.where((m) => m.isNotEmpty).toList(),
                  icon: Icons.grain,
                  color: Colors.green.shade50,
                ),
              ),
            const SizedBox(width: 5),
            if (menuItem.ingredients.any((i) => i != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  context,
                  'Ingredients',
                  menuItem.ingredients,
                  icon: Icons.restaurant_menu,
                  color: Colors.yellow.shade50,
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
