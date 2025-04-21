import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Cart/SlotsBooking.dart';
import 'package:kealthy/Cart/adress&slot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login/Guest_Alert.dart';
import '../Login/login_page.dart';
import '../Maps/SelectAdress.dart';
import '../Payment/COD_Page.dart';
import '../Payment/SavedAdress.dart';
import '../Services/FirestoreCart.dart';
import 'Categories.dart';

final checkoutLoadingProvider = StateProvider<bool>((ref) => true);
final selectedETAProviders = StateProvider<DateTime?>((ref) => null);

class ShowCart extends ConsumerWidget {
  const ShowCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedSlotProvider);

    final cartItems = ref.watch(sharedPreferencesCartProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    ref.watch(selectedETAProviders);

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(selectedSlotProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Cart',
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
          ),
          elevation: 0.5,
        ),
        body: SafeArea(
          child: cartItems.isEmpty
              ? const Center(
                  child: CircleAvatar(
                    radius: 180,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        AssetImage("assets/kealthycart-removebg-preview.png"),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Column(
                          children: [
                            CategoryContainer(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _buildCheckoutSection(
                      screenWidth,
                      screenHeight,
                      totalPrice,
                      cartItems,
                      context,
                      ref,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(
    double screenWidth,
    double screenHeight,
    double totalPrice,
    List<SharedPreferencesCartItem> cartItems,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildTotal(cartItems, screenWidth, screenHeight),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    final isLoading = ref.watch(checkoutLoadingProvider);

                    return isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF273847),
                                strokeWidth: 4.0,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final phoneNumber =
                                        prefs.getString('phoneNumber') ?? '';

                                    if (phoneNumber.isEmpty) {
                                      GuestDialog.show(
                                        context: context,
                                        title: "Login Required",
                                        content: "Please log in to continue.",
                                        navigateTo: LoginFields(),
                                      );
                                      return;
                                    }

                                    await prefs.remove("selectedSlot");
                                    // ignore: unused_result
                                    ref.refresh(CODloadingProvider);
                                    // ignore: unused_result
                                    ref.refresh(selectedSlotProvider);
                                    // ignore: unused_result
                                    ref.refresh(selectedSlotProviders);
                                    // ignore: unused_result
                                    ref.refresh(etaTimeProvider);
                                    // ignore: unused_result
                                    ref.refresh(distanceProvider);
                                    // ignore: unused_result
                                    ref.refresh(etaTimeProvider);
                                    // ignore: unused_result
                                    ref.refresh(selectedETAProvider);
                                    // ignore: unused_result
                                    ref.refresh(selectedETAProviders);

                                    final selectedRoad = prefs
                                        .getString('selectedAddressMessage');
                                    final distance =
                                        prefs.getDouble("selectedDistance");
                                    if (selectedRoad == null ||
                                        selectedRoad.isEmpty) {
                                      Navigator.push(
                                        context,
                                        CupertinoModalPopupRoute(
                                          builder: (context) => SelectAdress(
                                            totalPrice: totalPrice,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (distance == null) {
                                      Navigator.push(
                                        context,
                                        CupertinoModalPopupRoute(
                                          builder: (context) => SelectAdress(
                                            totalPrice: totalPrice,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    ref
                                        .read(checkoutLoadingProvider.notifier)
                                        .state = true;

                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      await prefs.remove("cookinginstrcutions");
                                      await prefs
                                          .remove("deliveryInstructions");
                                      for (String key
                                          in prefs.getKeys().toList()) {
                                        if (key.startsWith('item_')) {
                                          await prefs.remove(key);
                                        }
                                      }
                                      for (int i = 0;
                                          i < cartItems.length;
                                          i++) {
                                        SharedPreferencesCartItem item =
                                            cartItems[i];
                                        await prefs.setString(
                                            'item_name_$i', item.name);
                                        await prefs.setString(
                                            'item_EAN_$i', item.EAN);
                                        await prefs.setInt(
                                            'item_quantity_$i', item.quantity);
                                        await prefs.setDouble(
                                            'item_price_$i', item.price);
                                      }

                                      prefs.getString('selectedRoad');

                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => AdressSlot(
                                                  totalprice: totalPrice,
                                                )),
                                      );
                                    } finally {
                                      ref
                                          .read(
                                              checkoutLoadingProvider.notifier)
                                          .state = false;
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF273847),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: FutureBuilder<String?>(
                              future: SharedPreferences.getInstance().then(
                                  (prefs) => prefs
                                      .getString('selectedAddressMessage')),
                              builder: (context, snapshot) {
                                final savedAddressId = snapshot.data;
                                final buttonText = (savedAddressId == null ||
                                        savedAddressId.isEmpty)
                                    ? 'Select Address'
                                    : 'Continue';

                                return Text(
                                  buttonText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal(
    List<SharedPreferencesCartItem> cartItems,
    double screenWidth,
    double screenHeight,
  ) {
    final total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Total Bill',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.description_outlined,
              size: 24.0,
              color: Color(0xFF273847),
            ),
          ],
        ),
        Text(
          '₹${total.toStringAsFixed(0)}/-',
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
