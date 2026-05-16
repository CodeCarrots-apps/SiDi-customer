import 'dart:convert';

class Booking {
  final String id;
  final String title;
  final String time;
  final String bookingDate;
  final String serviceId;
  final String stylist;
  final String image;
  final String status;
  final String jobId;

  const Booking({
    required this.id,
    required this.title,
    required this.time,
    required this.bookingDate,
    required this.serviceId,
    required this.stylist,
    required this.image,
    required this.status,
    required this.jobId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? service = _asMap(json['service']);

    final List<Map<String, dynamic>> services = json['services'] is List
        ? (json['services'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : [];

    final Map<String, dynamic>? primaryService =
        service ?? (services.isNotEmpty ? services.first : null);

    final Map<String, dynamic>? nestedService = _asMap(
      primaryService?['service'],
    );

    final Map<String, dynamic>? beautician = _asMap(json['beautician']);

    final Map<String, dynamic>? timeSlot = _asMap(json['timeSlot']);

    final dynamic rawServiceId =
        json['serviceId'] ??
        json['service_id'] ??
        nestedService?['_id'] ??
        nestedService?['id'] ??
        primaryService?['_id'] ??
        primaryService?['id'] ??
        ((json['serviceIds'] is List && (json['serviceIds'] as List).isNotEmpty)
            ? (json['serviceIds'] as List).first
            : null);

    final String resolvedServiceId = rawServiceId is Map<String, dynamic>
        ? (rawServiceId['_id'] ?? rawServiceId['id'] ?? '').toString()
        : (rawServiceId ?? '').toString();

    return Booking(
      id: _asString(json['_id'] ?? json['id']),
      title: _asString(
        json['title'] ??
            json['serviceName'] ??
            primaryService?['serviceName'] ??
            primaryService?['name'] ??
            nestedService?['name'] ??
            primaryService?['title'],
      ),
      time: _asString(
        json['time'] ??
            json['bookingTime'] ??
            json['scheduledTime'] ??
            json['startTime'] ??
            json['selectedTime'] ??
            json['slot'] ??
            _composeTimeSlot(timeSlot),
      ),
      bookingDate: _asString(
        json['bookingDate'] ?? json['date'] ?? json['scheduledDate'],
      ),
      serviceId: resolvedServiceId,
      stylist: _asString(
        json['stylist'] ??
            json['beauticianName'] ??
            beautician?['fullName'] ??
            beautician?['name'] ??
            beautician?['username'],
      ),
      image: _asString(
        json['image'] ??
            json['photoUrl'] ??
            primaryService?['image'] ??
            primaryService?['photoUrl'] ??
            primaryService?['image2'] ??
            nestedService?['image'] ??
            nestedService?['photoUrl'] ??
            beautician?['profileImage'],
      ),
      status: _asString(json['status']),
      jobId: _asString(json['jobId'] ?? json['job_id']),
    );
  }

  static String? _composeTimeSlot(Map<String, dynamic>? timeSlot) {
    if (timeSlot == null) return null;

    final start = _asString(timeSlot['startTime']).trim();
    final end = _asString(timeSlot['endTime']).trim();

    if (start.isEmpty && end.isEmpty) return null;
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    return start.isNotEmpty ? start : end;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'time': time,
      'bookingDate': bookingDate,
      'serviceId': serviceId,
      'stylist': stylist,
      'image': image,
      'status': status,
      'jobId': jobId,
    };
  }

  static List<Booking> listFromJson(String jsonString) {
    final dynamic decoded = json.decode(jsonString);

    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Booking.fromJson)
        .toList();
  }

  static String listToJson(List<Booking> bookings) {
    return json.encode(bookings.map((booking) => booking.toJson()).toList());
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Booking copyWith({
    String? id,
    String? title,
    String? time,
    String? bookingDate,
    String? serviceId,
    String? stylist,
    String? image,
    String? status,
    String? jobId,
  }) {
    return Booking(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      bookingDate: bookingDate ?? this.bookingDate,
      serviceId: serviceId ?? this.serviceId,
      stylist: stylist ?? this.stylist,
      image: image ?? this.image,
      status: status ?? this.status,
      jobId: jobId ?? this.jobId,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, title: $title, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Booking &&
        other.id == id &&
        other.title == title &&
        other.time == time &&
        other.bookingDate == bookingDate &&
        other.serviceId == serviceId &&
        other.stylist == stylist &&
        other.image == image &&
        other.status == status &&
        other.jobId == jobId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      time,
      bookingDate,
      serviceId,
      stylist,
      image,
      status,
      jobId,
    );
  }
}
