import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final String eanCode = menuItem.hsn;
    final String sourceAndMarketedBy =
        'Supermarket Grocery Supplies Pvt. Ltd, No. 7, Service Road, Off 100 Feet Road IndiranagarLandmark: Above HDFC BankBangalore, Karnataka 560071';
    final String countryOfOrigin = 'India';
    final String bestBefore = '3 days from delivery date';
    final String disclaimer =
        'The expiry date shown here is for indicative purposes only. Please refer to the information provided on the product package received at delivery for the actual expiry date';
    final String customerService =
        'For Queries/Feedback/Complaints, contact our customer care executive at 1860 123 1000 | Address: Innovative Retail Concepts Private Limited, Ranka Junction 4th Floor, Tin Factory Bus Stop. KR Puram, Bangalore - 560016 Email: customerservice@bigbasket.com';

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
                isExpanded ? Icons.remove : Icons.add,
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
        if (isExpanded) ...[
          SingleChildScrollView(
            // Wrap the expanded content in SingleChildScrollView
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
                _buildInfoItem('Best Before:', bestBefore),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Disclaimer:', disclaimer),
                SizedBox(
                  height: 10,
                ),
                _buildInfoItem('Customer Service:', customerService),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildInfoItem(String title, String subtitle) {
    return Text(
      '$title $subtitle',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }
}
