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
}
