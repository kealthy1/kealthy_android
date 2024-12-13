class AvailableSlotsGenerator {
  final int slotDurationMinutes;
  final int minGapMinutes;
  final DateTime startTime; 
  final DateTime endTime; 

  AvailableSlotsGenerator({
    required this.slotDurationMinutes,
    required this.minGapMinutes,
    required this.startTime,
    required this.endTime,
  });

  List<DateTime> getAvailableSlots(DateTime currentTime, double etaMinutes) {
    List<DateTime> slots = [];
    DateTime adjustedStartTime = startTime;

    DateTime etaAdjustedTime =
        currentTime.add(Duration(minutes: etaMinutes.toInt()));

    DateTime etaPlusBreak = etaAdjustedTime.add(const Duration(minutes: 30));

    DateTime nextHour = DateTime(
      etaPlusBreak.year,
      etaPlusBreak.month,
      etaPlusBreak.day,
      etaPlusBreak.hour + 1,
    );

    adjustedStartTime = nextHour;

    while (adjustedStartTime.isBefore(endTime)) {
      if (adjustedStartTime.isAfter(currentTime) &&
          adjustedStartTime.difference(currentTime).inMinutes >=
              minGapMinutes) {
        slots.add(adjustedStartTime);
      }

      adjustedStartTime =
          adjustedStartTime.add(Duration(minutes: slotDurationMinutes));
    }
    return slots;
  }
}
