import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

final phoneNumberProvider = StateProvider<String>((ref) => '');
final showPhoneFieldProvider = StateProvider<bool>((ref) => false);