import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<void> saveOrderItems(
      List<Map<String, dynamic>> orderItems) async {
    final prefs = await SharedPreferences.getInstance();

    int index = 0;
    while (prefs.containsKey('item_name_$index')) {
      prefs.remove('item_name_$index');
      prefs.remove('item_quantity_$index');
      prefs.remove('item_price_$index');
      index++;
    }

    List<String> itemNames = [];
    for (int i = 0; i < orderItems.length; i++) {
      final item = orderItems[i];
      prefs.setString('item_name_$i', item['item_name']);
      prefs.setInt('item_quantity_$i', item['item_quantity']);
      prefs.setDouble('item_price_$i', item['item_price']);
      itemNames.add(item['item_name']);
    }

    prefs.setStringList('order_item_names', itemNames);

    print("Order items saved to SharedPreferences successfully.");
    printAllValues();
  }

  static Future<List<Map<String, dynamic>>> getOrderItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> orderItems = [];

    int index = 0;
    while (true) {
      String? itemName = prefs.getString('item_name_$index');
      int? itemQuantity = prefs.getInt('item_quantity_$index');
      double? itemPrice = prefs.getDouble('item_price_$index');

      if (itemQuantity == null) {
        break;
      }

      orderItems.add({
        'item_name': itemName,
        'item_quantity': itemQuantity,
        'item_price': itemPrice,
      });
      index++;
    }

    print("Fetched order items:");
    for (var item in orderItems) {
      print(item);
    }
    return orderItems;
  }

  static Future<List<String>> getOrderItemNames() async {
    final prefs = await SharedPreferences.getInstance();
    final itemNames = prefs.getStringList('order_item_names') ?? [];

    print("Fetched order item names: $itemNames");
    return itemNames;
  }

  static Future<void> removeOrderItemByName(String itemNameToRemove) async {
    List<Map<String, dynamic>> orderItems = await getOrderItems();

    List<Map<String, dynamic>> updatedOrderItems = orderItems
        .where((item) => item['item_name'] != itemNameToRemove)
        .toList();

    await saveOrderItems(updatedOrderItems);

    if (updatedOrderItems.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('order_id');
      print("All items removed. Cleared order_id.");
    }

    print("Updated order items after removal:");
    for (var item in updatedOrderItems) {
      print(item);
    }
  }

  static Future<void> printAllValues() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print("All SharedPreferences values:");

    for (String key in keys) {
      print("$key: ${prefs.get(key)}");
    }
  }
}
