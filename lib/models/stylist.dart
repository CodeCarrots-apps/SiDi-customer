class Stylist {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String bio;
  final List<String> skills;
  final int experience;
  final String tier;
  final bool isVerified;
  final String status;
  final double rating;

  /// 🔥 NEW (IMPORTANT)
  final String profileImage;
  final String city;

  Stylist({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bio,
    required this.skills,
    required this.experience,
    required this.tier,
    required this.isVerified,
    required this.status,
    required this.rating,
    required this.profileImage,
    required this.city,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    final rawImage = json['profileImage'];

    return Stylist(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bio: json['bio'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? 0,
      tier: json['tier'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),

      /// ✅ FIXED IMAGE
      profileImage: (rawImage != null && rawImage.toString().isNotEmpty)
          ? 'https://sidi.mobilegear.co.in$rawImage'
          : '',

      /// ✅ CITY
      city: json['location']?['city'] ?? '',
    );
  }

  /// 🔥 OPTIONAL: UI HELPERS (Highly Recommended)

  String get displayName => fullName;

  String get displayRole =>
      skills.isNotEmpty ? skills.join(', ') : 'Beautician';

  String get displayImage => profileImage.isNotEmpty
      ? profileImage
      : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}';

  String get subtitle => '$displayRole • $city';
}
