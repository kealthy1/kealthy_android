import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:kealthy/LandingPage/Myprofile/PrivacyPolicy.dart';
import 'package:kealthy/LandingPage/Myprofile/Refund&Policy.dart';
import 'package:kealthy/LandingPage/Myprofile/Terms&Conditions.dart';
import 'package:kealthy/Login/introscreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Maps/SelectAdress.dart';
import '../../Orders/ordersTab.dart';

class UserProfile {
  final String name;

  UserProfile({required this.name});
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  bool _isDisposed = false;

  UserProfileNotifier() : super(UserProfile(name: 'User')) {
    _loadUserName();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String savedName = prefs.getString('name') ?? 'User';
    if (!_isDisposed) {
      state = UserProfile(name: savedName);
    }
  }

  Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', newName);
    if (!_isDisposed) {
      state = UserProfile(name: newName);
    }
  }

  Future<void> refreshUserName() async {
    await _loadUserName();
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
    return prefs.getString('phoneNumber') ?? 'Not Set';
  }

  Future<void> _clearPreferencesAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      CupertinoModalPopupRoute(builder: (context) => const IntroScreen()),
    );
  }

  Widget buildLogoutAlertDialog(BuildContext context) {
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

    return FutureBuilder<String?>(
      future: _getPhoneNumber(),
      builder: (context, snapshot) {
        final phoneNumber = snapshot.data ?? 'Not Set';

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_alt_circle,
                            color: Colors.black,
                            size: 60,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phoneNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                        icon: Row(
                          children: [
                            Icon(
                              CupertinoIcons.arrowshape_turn_up_right,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Share',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                                      const SupportDeskScreen()))
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
                                    buildLogoutAlertDialog(context),
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
      onTap: onTap,
    );
  }
}
