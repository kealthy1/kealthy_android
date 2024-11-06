import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final placeSearchProvider =
    StateNotifierProvider<PlaceSearchNotifier, List<String>>((ref) {
  return PlaceSearchNotifier();
});

class PlaceSearchNotifier extends StateNotifier<List<String>> {
  PlaceSearchNotifier() : super([]);

  Future<void> fetchPlaceSuggestions(String input) async {
    final suggestions = await getPlaceSuggestionsFromAPI(input);
    state = suggestions;
  }

  // Get LatLng from a place name
  Future<LatLng> getLatLngFromPlace(String placeName) async {
    return await getLatLngFromAPI(placeName);
  }

  Future<List<String>> getPlaceSuggestionsFromAPI(String input) async {
    const String apiKey = 'AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA';
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> predictions =
          json.decode(response.body)['predictions'];
      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to load place suggestions');
    }
  }

  Future<LatLng> getLatLngFromAPI(String placeName) async {
    const String apiKey = 'AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA';
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$placeName&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final location =
          json.decode(response.body)['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      throw Exception('Failed to load LatLng for the place');
    }
  }
}
