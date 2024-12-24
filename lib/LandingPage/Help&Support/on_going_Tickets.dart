import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recentTicketsProvider = StreamProvider.autoDispose((ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final phoneNumber = prefs.getString('phoneNumber') ?? '';

  yield* FirebaseFirestore.instance
      .collection('Help')
      .where('status', isEqualTo: 'notsolved')
      .where('phoneNumber', isEqualTo: phoneNumber)
      .snapshots();
});

class OngoingTicketsPage extends ConsumerWidget {
  const OngoingTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsyncValue = ref.watch(recentTicketsProvider);

    return ticketsAsyncValue.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.xmark_circle, size: 40, color: Colors.black),
              SizedBox(
                height: 10,
              ),
              Text(
                "No Active Tickets Found",
                style: TextStyle(color: Colors.black, fontFamily: "poppins"),
              )
            ],
          );
        }

        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data();

            final timestamp = data['timestamp'] as Timestamp?;
            final dateTime = timestamp?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(dateTime ?? DateTime.now()),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMM').format(dateTime ?? DateTime.now()),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ticket ID ${data['ticketId'] ?? 'No ID'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: "poppins"),
                    ),
                    Text(
                      "Active",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins"),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['description'] ?? "No Description",
                      style: TextStyle(fontFamily: "poppins"),
                    ),
                    const SizedBox(height: 10),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushReplacement(
                    //         context,
                    //         SeamlessRevealRoute(
                    //             page: TicketChatPage(
                    //           ticketId: data['ticketId'] ?? "ID",
                    //         )));
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         CupertinoIcons.chat_bubble_text,
                    //         size: 25,
                    //         color: Color(0xFF273847),
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         "Chat with Support",
                    //         style: TextStyle(
                    //           color: Colors.green,
                    //           fontSize: 14,
                    //           fontFamily: "poppins",
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
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

class AlertLog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const AlertLog({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.green[400],
              size: 80,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: "poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: "poppins",
          fontSize: 12,
        ),
      ),
      actions: actions.isNotEmpty
          ? actions
          : [
              TextButton(
                onPressed: () {},
                child: const Text("OK"),
              ),
            ],
    );
  }
}

void showAlertLog({
  required BuildContext context,
  required String title,
  required String message,
  List<Widget>? actions,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertLog(
      title: title,
      message: message,
      actions: actions ?? [],
    ),
  );
}
