import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MenuPage/menu_item.dart';
import 'Percentindicator.dart';

class RedNutritionSection extends StatefulWidget {
  final MenuItem menuItem;

  const RedNutritionSection({
    required this.menuItem,
    super.key,
  });

  @override
  State<RedNutritionSection> createState() => _RedNutritionSectionState();
}

class _RedNutritionSectionState extends State<RedNutritionSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.menuItem.name,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 24,
                    )),
              ),
              CircularProgressIndicatorWidget(
                kealthyScore: double.parse(widget.menuItem.kealthyScore),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.menuItem.macros.isNotEmpty &&
                widget.menuItem.macros.any((macro) => macro != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  color: Colors.blue.shade50,
                  context,
                  'Macros',
                  widget.menuItem.macros
                      .where((macro) => macro != 'Not Applicable')
                      .toList(),
                  icon: Icons.energy_savings_leaf,
                ),
              ),
            const SizedBox(width: 5),
            if (widget.menuItem.micros.isNotEmpty &&
                widget.menuItem.micros.any((micro) => micro != 'Not Applicable'))
              Expanded(
                child: _buildDataContainer(
                  color: Colors.green.shade50,
                  context,
                  'Micros',
                  widget.menuItem.micros
                      .where((micro) => micro != 'Not Applicable')
                      .toList(),
                  icon: Icons.vaccines,
                ),
              ),
            const SizedBox(width: 5),
            if (widget.menuItem.ingredients.isNotEmpty)
              Expanded(
                child: _buildDataContainer(
                  color: Colors.yellow.shade50,
                  context,
                  'Ingredients',
                  widget.menuItem.ingredients.map((ingredient) => ingredient).toList(),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF273847),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF273847),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
