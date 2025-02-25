// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../MenuPage/menu_item.dart';

// class ScoreDialog extends StatelessWidget {
//   final MenuItem menuItem; // Accept MenuItem as a parameter

//   const ScoreDialog({super.key, required this.menuItem});

//   @override
//   Widget build(BuildContext context) {
//     final List<String> scoringCriteria =
//         menuItem.ScoredBasedOn.where((element) => element.trim().isNotEmpty)
//             .toList(); // Remove empty values

//     // Function to check if a string starts with an Uppercase Letter + DOT (A., B., C.)
//     bool isTitle(String text) {
//       final regex = RegExp(r'^[A-Z]\.\s'); // Matches "A. ", "B. ", etc.
//       return regex.hasMatch(text) && !text.startsWith("I."); // Exclude "I."
//     }

//     // Function to check if a string is a Roman numeral (I., II., III., IV.)
//     bool isRomanNumeral(String text) {
//       final regex = RegExp(
//           r'^(I{1,3}|IV|V?I{0,3})\.\s'); // Matches "I. ", "II. ", "III. "
//       return regex.hasMatch(text);
//     }

//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Prevents full-screen takeover
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title Section
//             Center(
//               child: Column(
//                 children: [
//                   Image.asset(
//                     "assets/Capture.PNG",
//                     height: 30,
//                   ),
//                   Text(
//                     "CONSUMABLE PRODUCTS\nSCORE STRUCTURE",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Total Score Section
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     "TOTAL: 100 POINTS",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green[800],
//                     ),
//                   ),
//                   Text(
//                     "SCORING CRITERIA",
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             Container(
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade200)),
//               height:
//                   MediaQuery.of(context).size.height * 0.4, // Responsive height
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: scoringCriteria.length - 0, // Start from index 1
//                 itemBuilder: (context, index) {
//                   final text = scoringCriteria[index + 0]; // Adjust index

//                   // Skip empty values
//                   if (text.trim().isEmpty) return SizedBox.shrink();

//                   return Container(
//                     margin: const EdgeInsets.only(top: 8),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             text,
//                             style: isTitle(text)
//                                 ? GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green[800],
//                                   )
//                                 : isRomanNumeral(text)
//                                     ? GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors
//                                             .black, // Normal color for Roman numerals
//                                       )
//                                     : GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         color: Colors.black87,
//                                       ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Close Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   "CLOSE",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
