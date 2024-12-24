import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:kealthy/LandingPage/Myprofile/PrivacyPolicy.dart';
import 'package:kealthy/LandingPage/Myprofile/Refund&Policy.dart';
import 'package:kealthy/LandingPage/Myprofile/Terms&Conditions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login/login_page.dart';
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

  Future<void> _clearPreferencesAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneNumber');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginFields()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final userName = userProfile.name;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF273847),
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontFamily: "poppins"),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF273847),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF273847), width: 2),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.location_on_outlined,
                    'My Address',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectAdress(totalPrice: 0),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.shopping_bag_outlined,
                    'Orders',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersTabScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.privacy_tip,
                    "Privacy Policy",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.article,
                    "Terms and conditions",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsPage(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    CupertinoIcons.arrow_uturn_left,
                    "Return and Refund Policies",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReturnRefundPolicyPage(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    CupertinoIcons.chat_bubble_text,
                    "Help & Support",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportDeskScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.exit_to_app,
                    'Logout',
                    () => _clearPreferencesAndNavigate(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F5),
        border: Border.all(
          color: Color(0xFF273847),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Color(0xFF273847),
        ),
        title: Text(title,
            style: const TextStyle(
              color: Color(0xFF273847),
            )),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF273847),
        ),
        onTap: onTap,
      ),
    );
  }
}
