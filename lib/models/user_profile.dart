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

class FavoriteService {
  FavoriteService({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.image1,
    this.image2,
    this.category,
  });

  final String id;
  final String name;
  final double price;
  final int duration;
  final String image1;
  final String? image2;
  final String? category;

  factory FavoriteService.fromJson(Map<String, dynamic> json) {
    return FavoriteService(
      id: (json['_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      duration: (json['duration'] as int?) ?? 0,
      image1: (json['image1'] as String?) ?? '',
      image2: (json['image2'] as String?),
      category: (json['category'] as String?),
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

class NearbyBeautician {
  NearbyBeautician({
    required this.id,
    required this.name,
    required this.distance,
    required this.rating,
  });

  final String id;
  final String name;
  final double distance;
  final double rating;

  factory NearbyBeautician.fromJson(Map<String, dynamic> json) {
    return NearbyBeautician(
      id: (json['_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      distance: (json['distance'] is num)
          ? (json['distance'] as num).toDouble()
          : 0.0,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
    );
  }
}

class AllBeautician {
  AllBeautician({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.rating,
    required this.tier,
    this.skills,
    this.experience,
    this.status,
    this.isVerified,
  });

  final String id;
  final String fullName;
  final String profileImage;
  final double rating;
  final String tier;
  final List<String>? skills;
  final int? experience;
  final String? status;
  final bool? isVerified;

  factory AllBeautician.fromJson(Map<String, dynamic> json) {
    return AllBeautician(
      id: (json['_id'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      profileImage: (json['profileImage'] as String?) ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
      tier: (json['tier'] as String?) ?? '',
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      experience: (json['experience'] as int?),
      status: (json['status'] as String?),
      isVerified: (json['isVerified'] as bool?),
    );
  }
}
