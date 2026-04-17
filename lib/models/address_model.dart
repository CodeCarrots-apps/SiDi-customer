import 'dart:convert';

class AddressModel {
  AddressModel({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  final String id;
  String label;
  String line1;
  String line2;
  double latitude;
  double longitude;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String,
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse('${json['latitude'] ?? ''}') ?? 0.0,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse('${json['longitude'] ?? ''}') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'line1': line1,
      'line2': line2,
      'latitude': latitude,
      'longitude': longitude,
    };
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
