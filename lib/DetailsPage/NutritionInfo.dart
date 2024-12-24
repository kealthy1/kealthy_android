import 'package:flutter/material.dart';
import '../MenuPage/menu_item.dart';

class RedNutritionSection extends StatelessWidget {
  final MenuItem menuItem;

  const RedNutritionSection({
    required this.menuItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            menuItem.name,
            style: const TextStyle(
                color: Colors.black, fontFamily: "poppins", fontSize: 24.0),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildDataContainer(
                color: Colors.blue.shade50,
                context,
                'Macros',
                menuItem.macros.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .toList(),
                icon: Icons.energy_savings_leaf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDataContainer(
                color: Colors.green.shade50,
                context,
                'Micros',
                menuItem.micros.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .toList(),
                icon: Icons.vaccines,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDataContainer(
                color: Colors.yellow.shade50,
                context,
                'Ingredients',
                menuItem.ingredients.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .toList(),
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
          boxShadow: [
            const BoxShadow(
              color: Color(0xFF273847),
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "poppins",
            overflow: TextOverflow.ellipsis,
            color: Color(0xFF273847),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          displayData.join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: "poppins",
            color: Color(0xFF273847),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'More',
          style: TextStyle(
              fontSize: 12, color: Colors.green, fontFamily: "poppins"),
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
          title: Center(child: Text(title)),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: data
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF273847),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF273847),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
