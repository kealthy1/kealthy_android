class AvailableSlotsGenerator {
  final int slotDurationMinutes;
  final int minGapMinutes;

  AvailableSlotsGenerator({
    required this.slotDurationMinutes,
    required this.minGapMinutes,
  });

  List<DateTime> getAvailableSlots(
    DateTime startBoundary,
    DateTime endBoundary,
    DateTime currentTime,
    double etaMinutes,
  ) {
    DateTime etaAdjustedTime =
        currentTime.add(Duration(minutes: etaMinutes.toInt()));
    DateTime etaPlusBreak = etaAdjustedTime.add(const Duration(minutes: 30));

    DateTime adjustedStartTime = etaPlusBreak.isBefore(startBoundary)
        ? startBoundary
        : etaPlusBreak.add(Duration(minutes: 60 - etaPlusBreak.minute));

    List<DateTime> slots = [];

    while (adjustedStartTime.isBefore(endBoundary) ||
        adjustedStartTime == endBoundary) {
      if (adjustedStartTime.difference(currentTime).inMinutes >=
          minGapMinutes) {
        slots.add(adjustedStartTime);
      }
      adjustedStartTime =
          adjustedStartTime.add(Duration(minutes: slotDurationMinutes));
    }

    return slots;
  }

  Map<String, dynamic> getSlots(DateTime currentTime, double etaMinutes) {
    // Today's slot boundaries (7 AM to 10 PM)
    DateTime todayStartBoundary = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      7,
    );

    DateTime todayEndBoundary = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      23,
    );
    DateTime EndBoundary =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 21, 58);

    // Tomorrow's slot boundaries (7 AM to 10 PM)
    DateTime tomorrowStartBoundary = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day + 1,
      7,
    );

    DateTime tomorrowEndBoundary = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day + 1,
      22,
    );

    // Logic to decide which slots to show
    if (currentTime.isAfter(EndBoundary)) {
      // After 10 PM, show tomorrow's slots
      return {
        "slots": getAvailableSlots(tomorrowStartBoundary, tomorrowEndBoundary,
            currentTime, etaMinutes),
        "message": "Bookings are available for tomorrow",
      };
    } else if (currentTime.isBefore(todayStartBoundary)) {
      // Before 7 AM, show today's slots starting at 7 AM
      return {
        "slots": getAvailableSlots(
            todayStartBoundary, todayEndBoundary, currentTime, etaMinutes),
        "message": "Slots available today!",
      };
    } else {
      // Between 7 AM and 10 PM, show today's slots
      return {
        "slots": getAvailableSlots(
            todayStartBoundary, todayEndBoundary, currentTime, etaMinutes),
        "message": "Slots available today!",
      };
    }
  }
}
