import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Cart/Cart_Items.dart';
import '../../Services/FirestoreCart.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour < 12) {
      greeting = "Good Morning";
    } else if (currentHour < 18) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Night";
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(15),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "$greeting Sara",
          style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const ShowCart(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final cartItemCount = ref.watch(addCartProvider).length;
                  return Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Center(
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  FeatherIcons.helpCircle,
                  size: 30,
                )),
          ),
        ],
      ),
    );
  }
}
