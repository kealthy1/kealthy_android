import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Cart/Cart_Items.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: const Color.fromARGB(255, 79, 170, 82),
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Sara",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "7994689802",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/103.png',
                width: 24.0,
                height: 24.0,
              ),
              title: const Text(
                'My Orders',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset(
                'assets/104.png',
                width: 24.0,
                height: 24.0,
              ),
              title: const Text('My Profile',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const ShowCart(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Delivery Address',
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading:
                  const Icon(Icons.contact_phone_outlined, color: Colors.green),
              title: const Text('Contact Us',
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.green),
              title: const Text('Helps & FAQs',
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title:
                  const Text('Log Out', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
