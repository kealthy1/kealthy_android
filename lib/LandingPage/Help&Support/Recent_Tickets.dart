import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recentTicketsProvider = StreamProvider.autoDispose((ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final phoneNumber = prefs.getString('phoneNumber') ?? '';

  yield* FirebaseFirestore.instance
      .collection('Help')
      .where('status', isEqualTo: 'solved')
      .where('phoneNumber', isEqualTo: phoneNumber)
      .snapshots();
});

class RecentTicketsPage extends ConsumerWidget {
  const RecentTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsyncValue = ref.watch(recentTicketsProvider);

    return ticketsAsyncValue.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.doc, size: 40, color: Colors.black),
              SizedBox(
                height: 10,
              ),
              Text(
                "No solved Tickets Found",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
              )
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data();

            final timestamp = data['timestamp'] as Timestamp?;
            final dateTime = timestamp?.toDate();

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Color(0xFF273847),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(dateTime ?? DateTime.now()),
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMM').format(dateTime ?? DateTime.now()),
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ticket ID ${data['ticketId'] ?? 'No ID'}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Solved",
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  data['subCategory'] ?? "No Description",
                  style: GoogleFonts.poppins(),
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
          child: LoadingAnimationWidget.inkDrop(
        color: Color(0xFF273847),
        size: 30,
      )),
      error: (error, stack) => Center(
        child: Text("Error: $error"),
      ),
    );
  }
}
