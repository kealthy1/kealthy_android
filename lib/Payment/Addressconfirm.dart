import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedAddressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'road': prefs.getString('selectedRoad') ?? 'N/A',
    'selectedSlot': prefs.getString('selectedSlot') ?? 'N/A',
    'selectedDistance': prefs.getDouble('selectedDistance') ?? 0.0,
    'type': prefs.getString('type') ?? 'N/A',
  };
});

class ConfirmOrder extends ConsumerWidget {
  const ConfirmOrder({
    super.key,
  });

  IconData getIconForAddressType(String? addressType) {
    if (addressType == "Work") {
      return Icons.work_outline;
    } else if (addressType == "Home") {
      return CupertinoIcons.home;
    } else {
      return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAddressAsync = ref.watch(savedAddressProvider);

    return savedAddressAsync.when(
      data: (savedAddress) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${savedAddress['type'] ?? 'N/A'}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            getIconForAddressType(savedAddress['type']),
                            size: 24,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        savedAddress['road'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        savedAddress['selectedSlot'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(savedAddress['selectedDistance'] != null ? savedAddress['selectedDistance'].toStringAsFixed(2) : 'N/A')} km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Color(0xFF273847),
          size: 30,
        ),
      ),
      error: (error, stack) => SizedBox.shrink(),
    );
  }
}
