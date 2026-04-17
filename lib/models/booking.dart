import 'dart:convert';

class Booking {
  final String id;
  final String title;
  final String time;
  final String stylist;
  final String image;
  final String status;
  final String jobId;

  Booking({
    required this.id,
    required this.title,
    required this.time,
    required this.stylist,
    required this.image,
    this.status = '',
    this.jobId = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? json['serviceName'] ?? '',
      time: json['time'] ?? json['bookingTime'] ?? json['slot'] ?? '',
      stylist: json['stylist'] ?? json['beauticianName'] ?? '',
      image: json['image'] ?? json['photoUrl'] ?? '',
      status: json['status'] ?? '',
      jobId: json['jobId'] ?? json['job_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
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
