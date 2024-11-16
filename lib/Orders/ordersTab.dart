import 'package:flutter/material.dart';
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
          backgroundColor: Colors.green,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.delivery_dining_outlined,
                ),
                child: Text(
                  'Live Orders',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.check_circle_sharp,
                ),
                child: Text(
                  'Past Orders',
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
