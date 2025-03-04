import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:kealthy/Orders/Completed_orders.dart';
import 'package:kealthy/Orders/MyOrders.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: const AssetImage("assets/nutri (2).png"),
                radius: 14, 
                backgroundColor: Colors.blueGrey[100],
              ),
              const SizedBox(width: 7), 
              Text(
                "Need Help? I'm Here for You!",
                style: GoogleFonts.poppins(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          HelpOption(
            title: "Track Order",
            onTap: () => navigateTo(context, MyOrdersPage()),
          ),
          HelpOption(
            title: "Past Orders",
            onTap: () => navigateTo(context, OrderCard()),
          ),
          HelpOption(
            title: "Call Help Center",
            onTap: () => showCallSupportDialog(context),
          ),
          HelpOption(
            title: "Open a Ticket",
            onTap: () => navigateTo(
              context,
              const SupportDeskScreen(
                value: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void showCallSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              "Contact Support",
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
          content: Text(
            "Would you like to contact a support executive? Our team is here to assist you.",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 199, 57, 47),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Dismiss",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 57, 161, 75),
                  ),
                  onPressed: () {
                    FlutterPhoneDirectCaller.callNumber("8848673425");
                  },
                  child: Text(
                    "Call Now",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class HelpOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const HelpOption({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
