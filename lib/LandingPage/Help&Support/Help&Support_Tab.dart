import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Myprofile/Myprofile.dart';
import 'Providers.dart';
import 'Recent_Tickets.dart';
import 'on_going_Tickets.dart';
import 'package:fluttertoast/fluttertoast.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class SupportDeskScreen extends ConsumerStatefulWidget {
  const SupportDeskScreen({super.key});

  @override
  _SupportDeskScreenState createState() => _SupportDeskScreenState();
}

class _SupportDeskScreenState extends ConsumerState<SupportDeskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    final userName = userProfile.name;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF273847),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Kealthy Support",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: "poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Welcome, \n",
                          style: TextStyle(
                            fontFamily: "poppins",
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: userName,
                          style: const TextStyle(
                            fontFamily: "poppins",
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showOpenTicketBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Open a Ticket",
                        style: TextStyle(
                            color: Color(0xFF273847),
                            fontWeight: FontWeight.bold,
                            fontFamily: "poppins"),
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade900),
                          onPressed: () {
                            showAlertLog(
                              context: context,
                              title: "Contact Support",
                              message:
                                  "Would you like to contact a support executive? Our team is here to assist you",
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 199, 57, 47)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Dismiss",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 57, 161, 75)),
                                      onPressed: () {
                                        FlutterPhoneDirectCaller.callNumber(
                                            "8848673425");
                                      },
                                      child: const Text(
                                        "Call Now",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Contact Us",
                          style: TextStyle(
                              color: Colors.white, fontFamily: "poppins"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.pending_actions),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.check_circle_sharp),
                      child: Text(
                        'Solved',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                OngoingTicketsPage(),
                RecentTicketsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showOpenTicketBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const OpenTicketBottomSheet(),
      );
    },
  );
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isValidValue = value != null && items.contains(value);

    return DropdownButtonFormField<String>(
      value: isValidValue ? value : null,
      onChanged: onChanged,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: "Poppins"),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .toSet()
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontFamily: "Poppins"),
                ),
              ))
          .toList(),
    );
  }
}

class OpenTicketBottomSheet extends ConsumerWidget {
  const OpenTicketBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotifier = ref.read(ticketFormProvider.notifier);
    final dropdownState = ref.watch(dropdownProvider);
    final dropdownNotifier = ref.read(dropdownProvider.notifier);
    final isLoading = ref.watch(loadingProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Open a Ticket 💬",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: dropdownState.firstDropdownValue,
              hintText: "Select Category",
              items: ["Orders", "Payments", "Report Bug", "Feedback"],
              onChanged: (value) {
                if (value != null) dropdownNotifier.updateFirstDropdown(value);
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: dropdownState.secondDropdownValue,
              hintText: "Select",
              items: dropdownState.secondDropdownOptions,
              onChanged: (value) {
                if (value != null) dropdownNotifier.updateSecondDropdown(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 7,
              maxLength: 200,
              onChanged: (value) => formNotifier.updateDescription(value),
              decoration: InputDecoration(
                hintText: "Enter Ticket Description",
                hintStyle: const TextStyle(fontFamily: "Poppins"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final category = dropdownState.firstDropdownValue;
                        final subCategory = dropdownState.secondDropdownValue;
                        // ignore: invalid_use_of_protected_member
                        final description = formNotifier.state.description;

                        if (category == null || category.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please select a category.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        if (subCategory == null || subCategory.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please select a sub-category.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        if (description == null || description.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please enter a description.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        ref.read(loadingProvider.notifier).state = true;

                        try {
                          await saveTicketToFirestore(
                            category: category,
                            subCategory: subCategory,
                            description: description,
                          );

                          formNotifier.resetForm();
                          dropdownNotifier.updateFirstDropdown("");
                          Navigator.pop(context);
                        } finally {
                          ref.read(loadingProvider.notifier).state = false;
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF273847),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveTicketToFirestore({
  required String category,
  required String subCategory,
  required String description,
}) async {
  try {
    String ticketId = _generateUniqueTicketId();

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber') ?? 'Unknown';

    await FirebaseFirestore.instance.collection('Help').add({
      'ticketId': ticketId,
      'phoneNumber': phoneNumber,
      'category': category,
      'subCategory': subCategory,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'notsolved',
    });

    Fluttertoast.showToast(
      msg: "Ticket submitted successfully! Ticket ID: $ticketId",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Failed to submit ticket: $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}

String _generateUniqueTicketId() {
  Random random = Random();
  return (random.nextInt(900000) + 100000).toString();
}
