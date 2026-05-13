import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidi/models/service_cart_item.dart';

class ServiceCartService {
  static const String _cartKey = 'service_booking_cart';

  static Future<List<ServiceCartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return ServiceCartItem.listFromJson(raw);
  }

  static Future<bool> contains(String uniqueKey) async {
    final items = await loadCart();
    return items.any((item) => item.uniqueKey == uniqueKey);
  }

  static Future<List<ServiceCartItem>> addItem(ServiceCartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await loadCart();
    final exists = items.any(
      (existing) => existing.uniqueKey == item.uniqueKey,
    );
    if (!exists) {
      items.add(item);
      await prefs.setString(_cartKey, ServiceCartItem.listToJson(items));
    }
    return items;
  }

  static Future<List<ServiceCartItem>> removeItem(String uniqueKey) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await loadCart();
    items.removeWhere((item) => item.uniqueKey == uniqueKey);
    await prefs.setString(_cartKey, ServiceCartItem.listToJson(items));
    return items;
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
