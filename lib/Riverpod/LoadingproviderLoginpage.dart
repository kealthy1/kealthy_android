import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether an operation is loading
final loadingProvider = StateProvider<bool>((ref) => false);

/// Holds the phone number state
final phoneNumberProvider = StateProvider<String>((ref) => '');
