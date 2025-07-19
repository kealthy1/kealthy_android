import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/view/Cart/slot_generator.dart';
import 'package:kealthy/view/Toast/toast_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntp/ntp.dart';
import 'package:firebase_database/firebase_database.dart';

final selectedSlotProvider =
    StateProvider<Map<String, DateTime>?>((ref) => null);
final isExpandedProvider = StateProvider<bool>((ref) => true);
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                ref.read(isExpandedProvider.notifier).state = !isExpanded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedSlot != null
                              ? 'Selected Slot : ${DateFormat('MMM d').format(selectedSlot["start"]!)}, ${DateFormat('h:mm a').format(selectedSlot["start"]!)} - ${DateFormat('h:mm a').format(selectedSlot["end"]!)}'
                              : 'Preferred Delivery Time',
                          style: GoogleFonts.poppins(
                              color: selectedSlot != null
                                  ? Colors.black
                                  : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(isExpanded
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down),
                    ],
                  ),
                ),
                // Uncomment and wrap with Flexible or Expanded if needed
                // Flexible(
                //   child: Text(
                //     'Save ₹50 🎉',
                //     style: GoogleFonts.poppins(
                //       color: Colors.green,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w500,
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
              ],
            ),
          ),
          if (isExpanded)
            FutureBuilder<Map<String, dynamic>>(
              future: () async {
                final generator =
                    AvailableSlotsGenerator(slotDurationMinutes: 180);
                final todaySlots = await generator.getSlots(0);
                return todaySlots;
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CupertinoActivityIndicator(
                    color: Colors.black,
                  ));
                }
                if (snapshot.hasError) {}

                final availableSlots =
                    (snapshot.data?["slots"] as List<dynamic>?)
                            ?.map((slot) => slot as Map<String, DateTime>)
                            .toList() ??
                        [];

                final message = snapshot.data?["message"] as String?;

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final tomorrow = today.add(const Duration(days: 1));

                final todaySlots = availableSlots.where((slot) {
                  final date = slot["start"]!;
                  return date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                }).toList();

                final tomorrowSlots = availableSlots.where((slot) {
                  final date = slot["start"]!;
                  return date.year == tomorrow.year &&
                      date.month == tomorrow.month &&
                      date.day == tomorrow.day;
                }).toList();

                Widget buildSlotButtons(List<Map<String, DateTime>> slots) {
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 10,
                      children: slots.map((slot) {
                        final formattedStartTime =
                            DateFormat('h:mm a').format(slot["start"]!);
                        final formattedEndTime =
                            DateFormat('h:mm a').format(slot["end"]!);

                        return GestureDetector(
                          onTap: () async {
                            final formattedStartTime =
                                DateFormat('hh:mm a').format(slot["start"]!);
                            final formattedEndTime =
                                DateFormat('hh:mm a').format(slot["end"]!);
                            final selectedSlotLabel =
                                "${DateFormat('MMM d').format(slot["start"]!)}, $formattedStartTime - $formattedEndTime";

                            final isAvailable =
                                await isSlotAvailable(selectedSlotLabel);
                            if (!isAvailable) {
                              ToastHelper.showErrorToast(
                                  'Slot not available. Please choose another slot');
                              return;
                            }

                            ref.read(selectedSlotProvider.notifier).state =
                                slot;
                            ref.read(isExpandedProvider.notifier).state = false;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                'selectedSlot', selectedSlotLabel);
                          },
                          child: IntrinsicWidth(
                            stepWidth: 10,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                color: (selectedSlot != null &&
                                        selectedSlot["start"] ==
                                            slot["start"] &&
                                        selectedSlot["end"] == slot["end"])
                                    ? const Color.fromARGB(255, 223, 240,
                                        224) // ✅ Change color if selected
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Center(
                                child: Text(
                                  '$formattedStartTime - $formattedEndTime',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message != null)
                      Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (todaySlots.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                            "Today’s Slots - ${DateFormat('MMM d, yyyy').format(today)}",
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 0, 124, 4))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No slots for today. Book for tomorrow!",
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.red)),
                      ),
                    if (todaySlots.isNotEmpty) buildSlotButtons(todaySlots),
                    if (tomorrowSlots.isNotEmpty) const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          "Tomorrow’s Slots - ${DateFormat('MMM d, yyyy').format(tomorrow)}",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 0, 124, 4))),
                    ),
                    if (tomorrowSlots.isNotEmpty)
                      buildSlotButtons(tomorrowSlots),
                  ],
                );
              },
            )
        ],
      ),
    );
  }
}

Future<bool> isSlotAvailable(String selectedSlotLabel) async {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  ).ref().child('orders');

  final snapshot = await databaseRef
      .orderByChild('selectedSlot')
      .equalTo(selectedSlotLabel)
      .get();

  for (final child in snapshot.children) {
    debugPrint("Matched order ID: ${child.key}");
    debugPrint("Stored slot: ${child.child('selectedSlot').value}");
  }

  final existingOrders = snapshot.children.length;
  debugPrint('Orders for $selectedSlotLabel: $existingOrders');
  return existingOrders < 15; // ⛔️ only allow 0, 1, or 2 orders — NOT 3+
}

//-----x------------x----------------x------------------x--------

// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:kealthy/view/Toast/toast_helper.dart';

// final selectedSlotProvider =
//     StateProvider<Map<String, dynamic>?>((ref) => null);
// final isExpandedProvider = StateProvider<bool>((ref) => true);

// class SlotSelectionContainer extends ConsumerWidget {
//   const SlotSelectionContainer({super.key});

//   Future<List<dynamic>> fetchSlotsFromBackend() async {
//     final response = await http.get(
//       Uri.parse('https://7982759bb6af.ngrok-free.app/slots'),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body) as List<dynamic>;
//     } else {
//       throw Exception('Failed to fetch slots');
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedSlot = ref.watch(selectedSlotProvider);
//     final isExpanded = ref.watch(isExpandedProvider);

//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 5,
//             spreadRadius: 1,
//             offset: const Offset(0, 1),
//           ),
//         ],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: () =>
//                 ref.read(isExpandedProvider.notifier).state = !isExpanded,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           selectedSlot != null
//                               ? 'Selected Slot : ${DateFormat('MMM d').format(DateTime.parse(selectedSlot["start"]))}, ${DateFormat('h:mm a').format(DateTime.parse(selectedSlot["start"]))} - ${DateFormat('h:mm a').format(DateTime.parse(selectedSlot["end"]))}'
//                               : 'Preferred Delivery Time',
//                           style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black),
//                           overflow: TextOverflow.visible,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       Icon(isExpanded
//                           ? Icons.arrow_drop_up
//                           : Icons.arrow_drop_down),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isExpanded)
//             FutureBuilder<List<dynamic>>(
//               future: fetchSlotsFromBackend(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child: CupertinoActivityIndicator(color: Colors.black));
//                 }

//                 if (snapshot.hasError) {
//                   return const Padding(
//                     padding: EdgeInsets.all(12),
//                     child: Text("Failed to load slots"),
//                   );
//                 }

//                 final availableSlots = (snapshot.data ?? []).map((slot) {
//                   return {
//                     "start": DateTime.parse(slot["start"]),
//                     "end": DateTime.parse(slot["end"]),
//                     "label": slot["label"],
//                   };
//                 }).toList();

//                 final now = DateTime.now();
//                 final today = DateTime(now.year, now.month, now.day);
//                 final tomorrow = today.add(const Duration(days: 1));

//                 final todaySlots = availableSlots.where((slot) {
//                   final date = slot["start"];
//                   return date.year == today.year &&
//                       date.month == today.month &&
//                       date.day == today.day;
//                 }).toList();

//                 final tomorrowSlots = availableSlots.where((slot) {
//                   final date = slot["start"];
//                   return date.year == tomorrow.year &&
//                       date.month == tomorrow.month &&
//                       date.day == tomorrow.day;
//                 }).toList();

//                 Widget buildSlotButtons(List<Map<String, dynamic>> slots) {
//                   return SingleChildScrollView(
//                     child: Wrap(
//                       spacing: 5,
//                       runSpacing: 10,
//                       children: slots.map((slot) {
//                         final formattedStartTime =
//                             DateFormat('h:mm a').format(slot["start"]);
//                         final formattedEndTime =
//                             DateFormat('h:mm a').format(slot["end"]);

//                         return GestureDetector(
//                           onTap: () async {
//                             final label = slot["label"];
//                             final isAvailable = await isSlotAvailable(label);
//                             if (!isAvailable) {
//                               ToastHelper.showErrorToast(
//                                   'Slot not available. Please choose another slot');
//                               return;
//                             }

//                             ref.read(selectedSlotProvider.notifier).state =
//                                 slot;
//                             ref.read(isExpandedProvider.notifier).state = false;

//                             final prefs = await SharedPreferences.getInstance();
//                             await prefs.setString('selectedSlot', label);
//                           },
//                           child: IntrinsicWidth(
//                             stepWidth: 10,
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.37,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 10),
//                               decoration: BoxDecoration(
//                                 color: (selectedSlot != null &&
//                                         DateTime.parse(selectedSlot["start"]) ==
//                                             slot["start"] &&
//                                         DateTime.parse(selectedSlot["end"]) ==
//                                             slot["end"])
//                                     ? const Color.fromARGB(255, 223, 240, 224)
//                                     : Colors.white,
//                                 borderRadius: BorderRadius.circular(5),
//                                 border: Border.all(color: Colors.black12),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '$formattedStartTime - $formattedEndTime',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   );
//                 }

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     if (todaySlots.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           "Today’s Slots - ${DateFormat('MMM d, yyyy').format(today)}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: const Color.fromARGB(255, 0, 124, 4),
//                           ),
//                         ),
//                       )
//                     else
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           "No slots for today. Book for tomorrow!",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ),
//                     if (todaySlots.isNotEmpty) buildSlotButtons(todaySlots),
//                     if (tomorrowSlots.isNotEmpty) const SizedBox(height: 10),
//                     if (tomorrowSlots.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           "Tomorrow’s Slots - ${DateFormat('MMM d, yyyy').format(tomorrow)}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: const Color.fromARGB(255, 0, 124, 4),
//                           ),
//                         ),
//                       ),
//                     if (tomorrowSlots.isNotEmpty)
//                       buildSlotButtons(tomorrowSlots),
//                   ],
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// Future<bool> isSlotAvailable(String selectedSlotLabel) async {
//   final databaseRef = FirebaseDatabase.instanceFor(
//     app: FirebaseDatabase.instance.app,
//     databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
//   ).ref().child('orders');

//   final snapshot = await databaseRef
//       .orderByChild('selectedSlot')
//       .equalTo(selectedSlotLabel)
//       .get();

//   final existingOrders = snapshot.children.length;
//   debugPrint('Orders for $selectedSlotLabel: $existingOrders');
//   return existingOrders < 15;
// }
