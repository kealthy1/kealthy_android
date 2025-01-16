import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final opacityProvider = StateProvider<double>((ref) => 0.0);

class FadeInText extends ConsumerWidget {
  final String text;
  final Duration duration;
  final Color color;
  final double fontSize;

  const FadeInText({
    super.key,
    required this.text,
    this.duration = const Duration(seconds: 2),
    this.color = Colors.white,
    this.fontSize = 30.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opacity = ref.watch(opacityProvider);

    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      child: Text(
        text,
        style: GoogleFonts.abrilFatface(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
