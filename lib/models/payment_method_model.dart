import 'dart:convert';
import 'package:flutter/material.dart';

class PaymentMethodModel {
  PaymentMethodModel({
    required this.id,
    required this.label,
    required this.details,
    required this.brand,
  });

  final String id;
  String label;
  String details;
  String brand;

  IconData get icon {
    switch (brand.toLowerCase()) {
      case 'apple':
        return Icons.apple;
      case 'visa':
      case 'mastercard':
        return Icons.credit_card;
      case 'cash':
      case 'cash onsite':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      label: json['label'] as String,
      details: json['details'] as String,
      brand: json['brand'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'details': details, 'brand': brand};
  }

  static List<PaymentMethodModel> listFromJson(String source) {
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map(
          (item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  static String listToJson(List<PaymentMethodModel> methods) {
    return jsonEncode(methods.map((method) => method.toJson()).toList());
  }
}
