import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';
import '../models/payment_method_model.dart';

class LocalStorageService {
  static const _addressesKey = 'saved_addresses';
  static const _paymentMethodsKey = 'saved_payment_methods';

  static Future<List<AddressModel>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_addressesKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return AddressModel.listFromJson(saved);
  }

  static Future<void> saveAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressesKey, AddressModel.listToJson(addresses));
  }

  static Future<List<PaymentMethodModel>> loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_paymentMethodsKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return PaymentMethodModel.listFromJson(saved);
  }

  static Future<void> savePaymentMethods(
    List<PaymentMethodModel> paymentMethods,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _paymentMethodsKey,
      PaymentMethodModel.listToJson(paymentMethods),
    );
  }
}
