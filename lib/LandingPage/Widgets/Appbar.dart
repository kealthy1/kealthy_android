import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Cart/Cart_Items.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(15),
      ),
      child: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/sara2.jpg"),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text(
          "Hello Sara  👋 ",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const ShowCart(),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
