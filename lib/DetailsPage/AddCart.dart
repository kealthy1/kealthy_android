import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MenuPage/menu_item.dart';

class AddToCart extends ConsumerWidget {
  final MenuItem menuItem;

  const AddToCart({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
       
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            "What Is it?",
            textAlign: TextAlign.justify,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          menuItem.whatIsIt,
          textAlign: TextAlign.justify,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "What Is it used for?",
          textAlign: TextAlign.justify,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          menuItem.whatIsItUsedFor,
          textAlign: TextAlign.justify,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
