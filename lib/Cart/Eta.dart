import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SlotsBooking.dart';

class EstimatedTimeSelector extends ConsumerWidget {
  final bool isSelected;
  final VoidCallback onSelect;

  const EstimatedTimeSelector({
    super.key,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etaTimeAsync = ref.watch(etaTimeProvider);
    final distanceAsync = ref.watch(distanceProvider);

    return etaTimeAsync.when(
      data: (etaTime) {
        final formattedETA = DateFormat('h:mm a').format(etaTime);
        final distance = distanceAsync.maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

        double? etaMinutes;
        if (distance != null) {
          const double averageSpeedKmH = 30.0;
          const int cookingTimeMinutes = 15;
          etaMinutes = (distance / averageSpeedKmH) * 100 + cookingTimeMinutes;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CheckboxListTile(
            value: ref.watch(selectedETAProvider) == etaTime,
            onChanged: (bool? value) async {
              final prefs = await SharedPreferences.getInstance();

              if (value == true) {
                prefs.setString('selectedSlot',
                    '${DateFormat('h:mm a').format(etaTime)}Instant Delivery');

                ref.read(selectedETAProvider.notifier).state = etaTime;

                onSelect();
              } else {
                final isRemoved = await prefs.remove('selectedSlot');
                if (isRemoved) {
                  ref.read(selectedETAProvider.notifier).state = null;

                  onSelect();
                } else {
                  print(
                      "Failed to remove 'selectedSlot' from SharedPreferences.");
                }
              }
            },
            title: Text(
              'Instant delivery ⚡',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (etaMinutes != null)
                  Text(
                    'Estimated Delivery Time: $formattedETA, (${etaMinutes.toStringAsFixed(0)} min)',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            activeColor: Color(0xFF273847),
            checkColor: Colors.white,
          ),
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: Color(0xFF273847),
          size: 70,
        ),
      ),
      error: (error, stack) => const Center(
        child: Text("Error loading ETA."),
      ),
    );
  }
}
