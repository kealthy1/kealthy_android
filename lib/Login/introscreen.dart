import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Login/login_page.dart';

class IntroPage2 extends ConsumerStatefulWidget {
  const IntroPage2({super.key});

  @override
  _IntroPage2State createState() => _IntroPage2State();
}

class _IntroPage2State extends ConsumerState<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Artboard 11 (2).png"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.dilate(),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF273847),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) => const LoginFields(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white, 
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
