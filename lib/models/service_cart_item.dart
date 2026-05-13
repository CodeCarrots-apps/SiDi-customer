import 'dart:convert';

class ServiceCartItem {
  const ServiceCartItem({
    required this.serviceId,
    required this.title,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.description = '',
    this.curatedServiceId,
    this.beauticianId,
  });

  final String serviceId;
  final String title;
  final String price;
  final String duration;
  final String imageUrl;
  final String description;
  final String? curatedServiceId;
  final String? beauticianId;

  String get uniqueKey => curatedServiceId?.isNotEmpty == true
      ? '${serviceId}_$curatedServiceId'
      : serviceId;

  factory ServiceCartItem.fromJson(Map<String, dynamic> json) {
    return ServiceCartItem(
      serviceId: (json['serviceId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      curatedServiceId: json['curatedServiceId']?.toString(),
      beauticianId: json['beauticianId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'title': title,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl,
      'description': description,
      'curatedServiceId': curatedServiceId,
      'beauticianId': beauticianId,
    };
  }

  static List<ServiceCartItem> listFromJson(String raw) {
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ServiceCartItem.fromJson)
        .toList();
  }

  static String listToJson(List<ServiceCartItem> items) {
    return json.encode(items.map((item) => item.toJson()).toList());
  }
}
