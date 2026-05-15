import 'dart:convert';

enum AppNotificationCategory { appointments, updates }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.category,
    this.bookingId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final AppNotificationCategory category;
  final String? bookingId;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      category: AppNotificationCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => AppNotificationCategory.updates,
      ),
      bookingId: json['bookingId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
      'bookingId': bookingId,
    };
  }

  static List<AppNotification> listFromJson(String jsonString) {
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<AppNotification> notifications) {
    return json.encode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
  }
}
