// import 'package:flutter/material.dart';

// class ScoreBreakdownPage extends StatelessWidget {
//   final String scoreData; // Passed as a string from Firestore

//   const ScoreBreakdownPage({
//     super.key,
//     required this.scoreData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Parse and extract values dynamically
//     Map<String, dynamic> scoringData = _extractScoreData(scoreData);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(scoreData),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Display Overall Score Header
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade50,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "KEALTHY SCORE BREAKDOWN",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // Generate Containers for Each Section
//               for (var key in scoringData.keys)
//                 _buildSectionContainer(
//                   title: "$key – ${scoringData[key]['total']} Points",
//                   subcategories: scoringData[key]['details'],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Extracts scoring data dynamically from Firestore's stored string
//   Map<String, dynamic> _extractScoreData(String data) {
//     Map<String, dynamic> scoringData = {};

//     // Split by sections (A, B, C, D, E)
//     List<String> sections = data.split(RegExp(r'(?=[A-E]\.)'));

//     for (var section in sections) {
//       if (section.trim().isEmpty) continue;

//       // Extract section key (A, B, C, D, E)
//       String sectionKey = section.substring(0, 1);
//       String content =
//           section.substring(3).trim(); // Remove prefix (e.g., "A. ")

//       // Extract total points from first line
//       List<String> lines = content.split("\n");
//       int totalPoints = int.tryParse(
//               RegExp(r'\d+').firstMatch(lines.first)?.group(0) ?? "0") ??
//           0;

//       // Extract subpoints using Roman numerals
//       List<Map<String, dynamic>> details = [];
//       RegExp regex = RegExp(r'(I{1,3}|IV|V|VI{0,3})\.\s*(.*) – (\d+)');
//       for (var line in lines.skip(1)) {
//         RegExpMatch? match = regex.firstMatch(line);
//         if (match != null) {
//           details.add({
//             "title": match.group(1) ?? "", // Roman numeral
//             "name": match.group(2)?.trim() ?? "",
//             "points": int.tryParse(match.group(3) ?? "0") ?? 0,
//           });
//         }
//       }

//       // Store in structured map
//       scoringData[sectionKey] = {"total": totalPoints, "details": details};
//     }

//     return scoringData;
//   }

//   /// Builds a container for each section
//   Widget _buildSectionContainer({
//     required String title,
//     required List<Map<String, dynamic>> subcategories,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.shade300, blurRadius: 4, spreadRadius: 2),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title, // Section Title (A, B, C, etc.)
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
//           ),
//           SizedBox(height: 5),
//           for (var sub in subcategories)
//             Padding(
//               padding: const EdgeInsets.only(left: 8.0, top: 5),
//               child: Text(
//                 "${sub['title']}. ${sub['name']} – ${sub['points']} Points",
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
