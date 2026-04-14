class UserProfile {
  UserProfile({required this.user, required this.stats});

  final UserData user;
  final ProfileStats stats;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final statsJson =
        json['stats'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return UserProfile(
      user: UserData.fromJson(userJson),
      stats: ProfileStats.fromJson(statsJson),
    );
  }
}

class UserData {
  UserData({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.favoriteBeauticians,
  });

  final String username;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final List<FavoriteStylist> favoriteBeauticians;

  factory UserData.fromJson(Map<String, dynamic> json) {
    final favorites =
        (json['favoriteBeauticians'] as List<dynamic>?) ?? <dynamic>[];

    return UserData(
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      profileImage: (json['profileImage'] as String?) ?? '',
      favoriteBeauticians: favorites
          .whereType<Map<String, dynamic>>()
          .map(FavoriteStylist.fromJson)
          .toList(),
    );
  }
}

class FavoriteStylist {
  FavoriteStylist({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.rating,
    required this.tier,
  });

  final String id;
  final String fullName;
  final String profileImage;
  final double rating;
  final String tier;

  factory FavoriteStylist.fromJson(Map<String, dynamic> json) {
    return FavoriteStylist(
      id: (json['_id'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      profileImage: (json['profileImage'] as String?) ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
      tier: (json['tier'] as String?) ?? '',
    );
  }
}

class ProfileStats {
  ProfileStats({
    required this.totalBookings,
    required this.totalReviews,
    required this.memberSince,
    required this.tier,
  });

  final int totalBookings;
  final int totalReviews;
  final String memberSince;
  final String tier;

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalBookings: (json['totalBookings'] as int?) ?? 0,
      totalReviews: (json['totalReviews'] as int?) ?? 0,
      memberSince: (json['memberSince'] as String?) ?? '',
      tier: (json['tier'] as String?) ?? 'Member',
    );
  }
}
