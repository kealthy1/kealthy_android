import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ReusableAppBar({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF273847),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
