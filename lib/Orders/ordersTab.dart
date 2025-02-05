import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Orders/Completed_orders.dart';
import 'MyOrders.dart';

class OrdersTabScreen extends StatelessWidget {
  const OrdersTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Color(0xFF273847),
            splashFactory: NoSplash.splashFactory,
            labelColor: Color(0xFF273847),
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: [
              Tab(
                icon: Icon(
                  Icons.delivery_dining_outlined,
                ),
                child: Text(
                  'Live Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.check_circle_sharp,
                ),
                child: Text(
                  'Past Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyOrdersPage(),
            OrderCard(),
          ],
        ),
      ),
    );
  }
}
