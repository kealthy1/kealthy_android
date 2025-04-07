import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../MenuPage/menu_item.dart';

final expansionStateProvider = StateProvider<bool>((ref) => false);

class ProductInfoContainer extends ConsumerWidget {
  final MenuItem menuItem;
  const ProductInfoContainer({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(expansionStateProvider);

    final String eanCode = menuItem.EAN;
    final List<String> fssai = menuItem.FSSAI;
    final String sourceAndMarketedBy = menuItem.ImportedMarketedBy;
    final String countryOfOrigin = menuItem.Orgin;
    final String bestBefore = _formatDate(menuItem.Expiry);

    final String disclaimer =
        'Please refer to the information provided on the product package received at delivery for the actual expiry date';
    final String customerService =
        'For Queries/Feedback/Complaints, contact our customer care executive at 8848673425.';
    final String address =
        "Cotolore Enterprises LLP, 15/293 - C, Muriyankara-Pinarmunda Milma Road, Peringala (PO), Ernakulam, 683565, Kerala, India.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            ref.read(expansionStateProvider.notifier).state = !isExpanded;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Other Product Info',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.remove_circle
                    : Icons.expand_circle_down_rounded,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'EAN Code: $eanCode',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (fssai.isNotEmpty && fssai.first != 'Not Applicable')
          Text(
            'FSSAI: ${fssai.join(", ")}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        SizedBox(
          height: 10,
        ),
        if (isExpanded) ...[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem('Sourced & marketed by:', sourceAndMarketedBy),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Country of Origin:', countryOfOrigin),
                SizedBox(
                  height: 10,
                ),
                Text(
                  textAlign: TextAlign.justify,
                  'Best Before: $bestBefore from the date of packaging',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Disclaimer:', disclaimer),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Customer Service:', customerService),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Address:', address),
              ],
            ),
          ),
        ]
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return menuItem.Expiry;
    }
  }

  Widget _buildInfoItem(String title, String subtitle) {
    return Text(
      textAlign: TextAlign.justify,
      '$title $subtitle',
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}
