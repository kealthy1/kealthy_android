// ignore_for_file: invalid_use_of_protected_member, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Myprofile/Myprofile.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);

class ProfileState {
  final String name;
  final String email;
  final String phoneNumber;
  final bool isLoading;

  ProfileState({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    bool? isLoading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(name: '', email: '', phoneNumber: ''));

  Future<void> fetchUserData({String? nameFromConstructor}) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber') ?? '';
    final storedEmail = prefs.getString('email') ?? '';

    state = state.copyWith(
      name: nameFromConstructor?.isNotEmpty == true
          ? nameFromConstructor
          : state.name,
      email: storedEmail,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> updateUserData(BuildContext context, WidgetRef ref) async {
    if (state.name.isEmpty || state.email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Name and Email cannot be empty!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      final url =
          Uri.parse("https://api-jfnhkjk4nq-uc.a.run.app/updateUserDetails");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": state.phoneNumber,
          "name": state.name,
          "email": state.email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        ref.refresh(userProfileProvider);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedName', state.name);
        await prefs.setString('email', state.email);

        Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pop(context);
        ref.refresh(profileProvider);
        ref.refresh(userProfileProvider);
      } else {
        throw Exception(responseData['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      print("Error updating profile: $e");
      Fluttertoast.showToast(
        msg: "Failed to update profile. Try again later.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

class EditProfilePage extends ConsumerStatefulWidget {
  final String nameFromConstructor;
  final String EMAILFromConstructor;

  const EditProfilePage({super.key,required this.EMAILFromConstructor, required this.nameFromConstructor});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();

    Future.microtask(() {
      final profileNotifier = ref.read(profileProvider.notifier);
      profileNotifier.fetchUserData(
          nameFromConstructor: widget.nameFromConstructor);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    _nameController.value = TextEditingValue(text: profile.name);
    _emailController.value = TextEditingValue(text: profile.email);

    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProfileTextField(
              controller: _nameController,
              label: "Name",
              onChanged: (value) {
                ref.read(profileProvider.notifier).state =
                    profile.copyWith(name: value);
              },
            ),
            const SizedBox(height: 15),
            ProfileTextField(
              controller: _emailController,
              label: "Email ID",
              onChanged: (value) {
                ref.read(profileProvider.notifier).state =
                    profile.copyWith(email: value);
              },
            ),
            const SizedBox(height: 30),
            profile.isLoading
                ? LoadingAnimationWidget.inkDrop(
                    color: Color(0xFF273847),
                    size: 25,
                  )
                : ElevatedButton(
                    onPressed: () {
                      profileNotifier.updateUserData(context, ref);
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF273847),
                    ),
                    child: Text(
                      "Update",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
