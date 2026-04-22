class Beautician {
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

  Beautician({
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
  });

  factory Beautician.fromJson(Map<String, dynamic> json) {
    return Beautician(
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
    );
  }
}
