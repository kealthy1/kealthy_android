// ignore_for_file: unused_result

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:kealthy/LandingPage/Myprofile/EditProfile.dart';
import 'package:kealthy/LandingPage/Myprofile/PrivacyPolicy.dart';
import 'package:kealthy/LandingPage/Myprofile/Refund&Policy.dart';
import 'package:kealthy/LandingPage/Myprofile/Terms&Conditions.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Login/login_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login/Guest_Alert.dart';
import '../../Maps/SelectAdress.dart';
import '../../Orders/ordersTab.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://api-jfnhkjk4nq-uc.a.run.app";

class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  bool _isDisposed = false;

  UserProfileNotifier() : super(UserProfile(name: 'User', email: '')) {
    _loadUserDetails();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('selectedName');
    String? savedEmail = prefs.getString('email');

    if ((savedName == null || savedName.isEmpty) ||
        (savedEmail == null || savedEmail.isEmpty)) {
      // Fetch from API if missing
      final userDetails = await _fetchUserDetailsFromAPI();
      savedName = userDetails['name'] ?? 'User';
      savedEmail = userDetails['email'] ?? '';

      if (savedName.isNotEmpty) {
        await prefs.setString('selectedName', savedName);
      }
      if (savedEmail.isNotEmpty) {
        await prefs.setString('email', savedEmail);
      }
    }

    if (!_isDisposed) {
      state = UserProfile(name: savedName, email: savedEmail);
    }
  }

  Future<Map<String, String?>> _fetchUserDetailsFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    final String? phoneNumber = prefs.getString("phoneNumber");

    if (phoneNumber == null || phoneNumber.isEmpty) {
      return {"name": null, "email": null};
    }

    final url = Uri.parse('$baseUrl/getUserDetails');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phoneNumber": phoneNumber}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        "name": data['user']['name'],
        "email": data['user']['email'],
      };
    }
    return {"name": null, "email": null};
  }

  Future<void> updateUserDetails(String newName, String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedName', newName);
    await prefs.setString('email', newEmail);
    if (!_isDisposed) {
      state = UserProfile(name: newName, email: newEmail);
    }
  }

  Future<void> refreshUserDetails() async {
    await _loadUserDetails();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<String?> _getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber') ?? '';
  }

  Future<void> _clearPreferencesAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoModalPopupRoute(builder: (context) => const LoginFields()),
      (Route<dynamic> route) => false,
    );
  }

  Widget buildLogoutAlertDialog(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      icon: Icon(
        Icons.exit_to_app,
        size: 60,
        color: Color(0xFF273847),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Are You Leaving?',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure to logout? All your data may be lost.',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 10,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ref.refresh(bottomNavIndexProvider);
            _clearPreferencesAndNavigate(context);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            backgroundColor: Color(0xFF273847),
          ),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final userName = userProfile.name;
final userEmail = userProfile.email;
    return FutureBuilder<String?>(
      future: _getPhoneNumber(),
      builder: (context, snapshot) {
        final phoneNumber = snapshot.data ?? '';

        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Profile",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) =>
                              EditProfilePage(nameFromConstructor: userName, EMAILFromConstructor: userEmail,),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.person_alt_circle,
                                color: Colors.grey.shade500,
                                size: 60,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  userName,
                                                  softWrap: true,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.mode_edit_outline_rounded,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final link =
                                'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy';
                            final text = link;
                            try {
                              await Share.share(
                                text,
                                subject: 'Kealthy App',
                              );
                            } catch (e) {
                              debugPrint('Error sharing: $e');
                            }
                          },
                          icon: const Icon(
                            CupertinoIcons.arrowshape_turn_up_right,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final menuItems = [
                        {
                          'icon': Icons.location_on_outlined,
                          'title': 'My Address',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const SelectAdress(totalPrice: 0)))
                        },
                        {
                          'icon': Icons.shopping_bag_outlined,
                          'title': 'Orders',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const OrdersTabScreen()))
                        },
                        {
                          'icon': Icons.privacy_tip_outlined,
                          'title': 'Privacy Policy',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyPage()))
                        },
                        {
                          'icon': Icons.assignment_outlined,
                          'title': 'Terms and Conditions',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const TermsAndConditionsPage()))
                        },
                        {
                          'icon': CupertinoIcons.arrow_uturn_left_circle,
                          'title': 'Return and Refund Policies',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const ReturnRefundPolicyPage()))
                        },
                        {
                          'icon': CupertinoIcons.chat_bubble_text,
                          'title': 'Help & Support',
                          'onTap': () => Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const SupportDeskScreen(value: 0,)))
                        },
                      ];

                      return _buildMenuItem(
                        context,
                        menuItems[index]['icon'] as IconData,
                        menuItems[index]['title'] as String,
                        menuItems[index]['onTap'] as VoidCallback,
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      height: 15,
                      thickness: 0.2,
                      color: Colors.black,
                    ),
                    itemCount: 6,
                  ),
                  Divider(
                    thickness: 0.7,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) =>
                                    buildLogoutAlertDialog(context, ref),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 15),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.power_settings_new_sharp,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Logout',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.data?.version ?? '1.1.2';
                          return Text(
                            'App Version: $version',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF273847),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF273847),
      ),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final phoneNumber = prefs.getString('phoneNumber') ?? '';

        if (phoneNumber.isEmpty &&
            (title == 'My Address' ||
                title == 'Orders' ||
                title == 'Help & Support')) {
          GuestDialog.show(
            context: context,
            title: "Login Required",
            content: "Please log in to access $title.",
            navigateTo: LoginFields(),
          );
        } else {
          onTap();
        }
      },
    );
  }
}

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null) {
    _loadPhoneNumber();
  }

  // Load phoneNumber from SharedPreferences
  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('phoneNumber');
  }

  final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
    return AuthNotifier();
  });
}
