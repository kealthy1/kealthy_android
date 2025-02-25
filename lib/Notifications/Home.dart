// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kealthy/Services/Notifications/shared_prefrences_Notification.dart';
// import 'FromFirestore.dart';

// class NotificationHome extends ConsumerStatefulWidget {
//   const NotificationHome({super.key});

//   @override
//   _NotificationHomeState createState() => _NotificationHomeState();
// }

// class _NotificationHomeState extends ConsumerState<NotificationHome>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifications = ref.watch(notificationProvider);
//     final firestoreNotifications = ref.watch(firestoreNotificationProvider);
//     final isLoading = notifications.isEmpty && firestoreNotifications.isEmpty;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         surfaceTintColor: Colors.white,
//         centerTitle: true,
//         title: Text(
//           "Notifications",
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF273847),
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: const Color(0xFF273847),
//           labelColor: const Color(0xFF273847),
//           unselectedLabelColor: Colors.grey,
//           splashFactory: NoSplash.splashFactory,
//           dividerHeight: 0.5,
//           tabs: [
//             Tab(
//               icon: Icon(CupertinoIcons.hand_thumbsup_fill, size: 24),
//               text: "Rate Your Purchase",
//             ),
//             Tab(
//               icon: Icon(Icons.local_offer, size: 24),
//               text: "Offers & Updates",
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     CupertinoIcons.bell_slash,
//                     size: 50,
//                     color: Color(0xFF273847),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'No Notifications',
//                     style: GoogleFonts.poppins(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF273847),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : TabBarView(
//               controller: _tabController,
//               children: const [
//                 NotificationsScreens(),
//                 NotificationsScreen(),
//               ],
//             ),
//     );
//   }
// }
