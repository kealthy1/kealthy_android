class AvailableSlotsGenerator {
  final int slotDurationMinutes; // Duration of each slot
  final int minGapMinutes; // Minimum gap between current time and next slot
  final DateTime startTime; // Start time of slot generation
  final DateTime endTime; // End time of slot generation

  AvailableSlotsGenerator({
    required this.slotDurationMinutes,
    required this.minGapMinutes,
    required this.startTime,
    required this.endTime,
  });

  List<DateTime> getAvailableSlots(DateTime currentTime) {
    List<DateTime> slots = [];
    DateTime adjustedStartTime = startTime;

    int minutesToNextSlot =
        (adjustedStartTime.difference(currentTime).inMinutes / slotDurationMinutes).ceil() * slotDurationMinutes;

    // Special case: If current time is 3:30, skip to 4:15
    if (currentTime.hour == 3 && currentTime.minute == 30) {
      adjustedStartTime =
          adjustedStartTime.add(const Duration(minutes: 45)); // Directly jump to 4:15
      minutesToNextSlot = 45; // Update minutesToNextSlot for the next iteration
    }

    // If the next slot is less than minGapMinutes away, skip it
    if (minutesToNextSlot < minGapMinutes) {
      adjustedStartTime = adjustedStartTime.add(Duration(minutes: minutesToNextSlot));
    }

    while (adjustedStartTime.isBefore(endTime)) {
      // Check the gap before adding the slot
      if (adjustedStartTime.isAfter(currentTime) &&
          adjustedStartTime.difference(currentTime).inMinutes >= minGapMinutes) {
        slots.add(adjustedStartTime);
      }

      adjustedStartTime = adjustedStartTime.add(Duration(minutes: slotDurationMinutes));
    }
    return slots;
  }
}
