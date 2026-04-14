class Booking {
  final String id;
  final String title;
  final String time;
  final String stylist;
  final String image;

  Booking({
    required this.id,
    required this.title,
    required this.time,
    required this.stylist,
    required this.image,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      stylist: json['stylist'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
