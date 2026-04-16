import 'dart:convert';

class AddressModel {
  AddressModel({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
  });

  final String id;
  String label;
  String line1;
  String line2;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'line1': line1, 'line2': line2};
  }

  static List<AddressModel> listFromJson(String source) {
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<AddressModel> addresses) {
    return jsonEncode(addresses.map((address) => address.toJson()).toList());
  }
}
