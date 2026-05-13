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

  Booking({
    required this.id,
    required this.title,
    required this.time,
    this.bookingDate = '',
    this.serviceId = '',
    required this.stylist,
    required this.image,
    this.status = '',
    this.jobId = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : null;
    final beautician = json['beautician'] is Map<String, dynamic>
        ? json['beautician'] as Map<String, dynamic>
        : null;

    return Booking(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title:
          json['title'] ??
          json['serviceName'] ??
          service?['name'] ??
          service?['title'] ??
          '',
      time:
          json['time'] ??
          json['bookingTime'] ??
          json['scheduledTime'] ??
          json['slot'] ??
          '',
      bookingDate:
          json['bookingDate'] ?? json['date'] ?? json['scheduledDate'] ?? '',
      serviceId:
          (json['serviceId'] ??
                  json['service_id'] ??
                  service?['_id'] ??
                  service?['id'] ??
                  '')
              .toString(),
      stylist:
          json['stylist'] ??
          json['beauticianName'] ??
          beautician?['name'] ??
          beautician?['username'] ??
          '',
      image:
          json['image'] ??
          json['photoUrl'] ??
          service?['image'] ??
          service?['photoUrl'] ??
          '',
      status: json['status'] ?? '',
      jobId: json['jobId'] ?? json['job_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<Booking> bookings) {
    return json.encode(bookings.map((booking) => booking.toJson()).toList());
  }
}
