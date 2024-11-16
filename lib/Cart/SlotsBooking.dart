import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AvailableslotGenerator.dart';

final selectedSlotProvider = StateProvider<DateTime?>((ref) => null);
final isExpandedProvider = StateProvider<bool>((ref) => false);

class SlotSelectionContainer extends ConsumerWidget {
  const SlotSelectionContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlot = ref.watch(selectedSlotProvider);
    final isExpanded = ref.watch(isExpandedProvider);
    if (selectedSlot != null) {
      final currentTime = DateTime.now();
      final slotExpiryTime = selectedSlot.add(const Duration(minutes: 10));

      if (currentTime.isAfter(slotExpiryTime)) {
        ref.read(selectedSlotProvider.notifier).state = null;
      }
    }
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
                        : 'Select Delivery Slot',
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
              child: FutureBuilder<DateTime>(
                future: NTP.now(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final currentTime = snapshot.data!;
                    final generator = AvailableSlotsGenerator(
                      slotDurationMinutes: 30,
                      minGapMinutes: 30,
                      startTime: DateTime(
                        currentTime.year,
                        currentTime.month,
                        currentTime.day,
                        7,
                        0,
                      ),
                      endTime: DateTime(
                        currentTime.year,
                        currentTime.month,
                        currentTime.day + 1,
                        0,
                        0,
                      ),
                    );
                    final availableSlots =
                        generator.getAvailableSlots(currentTime);
                    return Wrap(
                      spacing: 3,
                      runSpacing: 10,
                      children: availableSlots.map((slot) {
                        final formattedTime = DateFormat('h:mm a').format(slot);
                        return InkWell(
                          onTap: () async {
                            ref.read(selectedSlotProvider.notifier).state =
                                slot;
                            ref.read(isExpandedProvider.notifier).state = false;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('selectedSlot',
                                DateFormat('h:mm a').format(slot));
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
                    );
                  } else {
                    return Center(
                      child: LoadingAnimationWidget.inkDrop(
                        size: 50,
                        color: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
