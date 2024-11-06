import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
final placeSuggestionsProvider =
    StateNotifierProvider<PlaceSuggestionsNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return PlaceSuggestionsNotifier();
});

class PlaceSuggestionsNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  PlaceSuggestionsNotifier() : super([]);

  Future<void> fetchPlaceSuggestions(String input) async {
    const String apiKey = 'AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA';
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request =
        '$baseUrl?input=$input&key=$apiKey&components=country:in';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        List<Map<String, dynamic>> suggestions = [];
        for (var prediction in data['predictions']) {
          suggestions.add({
            'description': prediction['description'],
            'placeId': prediction['place_id'],
          });
        }
        state = suggestions;
      }
    } else {
    }
  }

  void clearPlaceSuggestions() {
    state = []; 
  }

  @override
  void dispose() {
    clearPlaceSuggestions();
    super.dispose();
  }
}
