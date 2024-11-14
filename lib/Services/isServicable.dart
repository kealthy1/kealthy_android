// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:kealthy/MenuPage/Drinks/DrinksPage.dart';
// import 'package:kealthy/MenuPage/Food/FoodPage.dart';
// import 'package:kealthy/MenuPage/Snacks/SnacksPage.dart';
// import '../../Services/ServiceableAlert.dart';

// class CategoryGrid extends StatelessWidget {
//   const CategoryGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           SizedBox(width: screenWidth * 0.06),
//           GestureDetector(
//             onTap: () => _onCategoryTap(
//               context,
//               const SnacksMenuPage(),
//               checkServiceable: false,
//             ),
//             child: _buildCategoryAvatar(
//               'Kealthy Snacks',
//               '',
//             ),
//           ),
//           SizedBox(width: screenWidth * 0.06),
//           GestureDetector(
//             onTap: () => _onCategoryTap(
//               context,
//               const FoodMenuPage(),
//               checkServiceable: true, 
//             ),
//             child: _buildCategoryAvatar(
//               '  Foods',
//               '',
//             ),
//           ),
//           SizedBox(width: screenWidth * 0.06),
//           GestureDetector(
//             onTap: () => _onCategoryTap(
//               context,
//               const DrinksMenuPage(),
//               checkServiceable: false,
//             ),
//             child: _buildCategoryAvatar(
//               ' Drinks',
//               '',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _onCategoryTap(BuildContext context, Widget destinationPage,
//       {bool checkServiceable = false}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedAddress = prefs.getString('currentaddress') ?? '';
//     List<String> serviceablePincodes = ['682030', '682037', '683565'];
//     bool isServiceable =
//         serviceablePincodes.any((pincode) => savedAddress.contains(pincode));

//     if (!isServiceable && checkServiceable) {
//       ServiceableAlert.show(
//         context: context,
//         onContinue: () {
//           Navigator.push(
//             context,
//             CupertinoModalPopupRoute(builder: (context) => destinationPage),
//           );
//         },
//       );
//     } else {
//       Navigator.push(
//         context,
//         CupertinoModalPopupRoute(builder: (context) => destinationPage),
//       );
//     }
//   }

//   Widget _buildCategoryAvatar(String label, String imagePath) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.green,
//                 width: 2.0,
//               ),
//             ),
//             child: CircleAvatar(
//               backgroundColor: Colors.transparent,
//               backgroundImage: AssetImage(imagePath),
//               radius: 50,
//             ),
//           ),
//           const SizedBox(height: 8.0),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }