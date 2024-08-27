import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Cart/Cart_Items.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return AppBar(
      backgroundColor: Colors.white,
      title: const Padding(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: Text(
          "Hello Sara  👋 ",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Container(
          width: screenWidth * 0.6,
          height: screenHeight * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green,
              width: 2.0,
            ),
          ),
          child: const CircleAvatar(
            backgroundColor: Color.fromARGB(255, 135, 127, 127),
            backgroundImage: AssetImage("assets/sara2.jpg"),
          ),
        ),
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
          onPressed: () {},
        ),
      ],
    );
  }
}
