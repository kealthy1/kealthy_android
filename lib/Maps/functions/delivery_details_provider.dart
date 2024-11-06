import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class to store delivery details
class DeliveryDetails {
  final String name;
  final String address;
  final String phone;

  DeliveryDetails({required this.name, required this.address, required this.phone});
}

// StateNotifier to manage delivery details state
class DeliveryDetailsNotifier extends StateNotifier<DeliveryDetails> {
  DeliveryDetailsNotifier()
      : super(DeliveryDetails(name: '', address: '', phone: ''));

  void updateDetails({String? name, String? address, String? phone}) {
    state = DeliveryDetails(
      name: name ?? state.name,
      address: address ?? state.address,
      phone: phone ?? state.phone,
    );
  }
}

// Riverpod provider for the delivery details state
final deliveryDetailsProvider =
    StateNotifierProvider<DeliveryDetailsNotifier, DeliveryDetails>((ref) {
  return DeliveryDetailsNotifier();
});
