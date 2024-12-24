import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntp/ntp.dart';
import 'AvailableslotGenerator.dart';

final selectedSlotProvider = StateProvider<DateTime?>((ref) => null);
final isExpandedProvider = StateProvider<bool>((ref) => false);
final distanceProvider = FutureProvider<double>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('selectedDistance') ?? 3.0;
});

final selectedETAProvider = StateProvider<DateTime?>((ref) => null);

final etaTimeProvider = FutureProvider<DateTime>((ref) async {
  final distance = await ref.read(distanceProvider.future);

  const double averageSpeedKmH = 30.0;
  const int cookingTimeMinutes = 15;

  final etaMinutes = (distance / averageSpeedKmH) * 100 + cookingTimeMinutes;

  final currentTime = await NTP.now();
  return currentTime.add(Duration(minutes: etaMinutes.toInt()));
});

class SlotSelectionContainer extends ConsumerWidget {
  const SlotSelectionContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlot = ref.watch(selectedSlotProvider);
    final isExpanded = ref.watch(isExpandedProvider);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(isExpandedProvider.notifier).state = !isExpanded;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedSlot != null
                        ? 'Slot: ${DateFormat('h:mm a').format(selectedSlot)}'
                        : 'Preferred Delivery Time',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Consumer(
                builder: (context, ref, child) {
                  final etaTimeAsync = ref.watch(etaTimeProvider);

                  return etaTimeAsync.when(
                    data: (etaTime) {
                      final nextFullHourAfterBreak = etaTime
                          .add(const Duration(minutes: 45))
                          .add(Duration(hours: 1) -
                              Duration(minutes: etaTime.minute));

                      final generator = AvailableSlotsGenerator(
                        slotDurationMinutes: 60,
                        minGapMinutes: 30,
                        startTime: nextFullHourAfterBreak,
                        endTime: DateTime(
                          etaTime.year,
                          etaTime.month,
                          etaTime.day + 1,
                          0,
                          0,
                        ),
                      );

                      final availableSlots =
                          generator.getAvailableSlots(etaTime, 0);

                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 10,
                          children: availableSlots.map((slot) {
                            final formattedTime =
                                DateFormat('h:mm a').format(slot);
                            return GestureDetector(
                              onTap: () async {
                                print('Selected Slot: $formattedTime');
                                ref.read(selectedSlotProvider.notifier).state =
                                    slot;
                                ref.read(isExpandedProvider.notifier).state =
                                    false;

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final success = await prefs.setString(
                                    'selectedSlot', formattedTime);

                                if (success) {
                                  print('Saved Slot: $formattedTime');
                                } else {
                                  print('Failed to save slot');
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.26,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedSlot == slot
                                      ? const Color.fromARGB(255, 223, 240, 224)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Center(
                                  child: Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: selectedSlot == slot
                                          ? Colors.black
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => const Center(
                      child: Text("Error loading ETA."),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
