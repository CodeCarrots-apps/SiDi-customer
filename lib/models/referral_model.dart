// class ReferralWallet {
//   ReferralWallet({
//     required this.referralCode,
//     required this.pointsBalance,
//     required this.pointsToRedeem,
//     required this.totalReferrals,
//     required this.history,
//   });

//   /// User's unique referral code.
//   final String referralCode;

//   /// Current accumulated points.
//   final int pointsBalance;

//   /// Points needed to unlock a free service.
//   final int pointsToRedeem;

//   /// Total number of successful referrals made.
//   final int totalReferrals;

//   /// Per-referral history entries.
//   final List<ReferralEntry> history;

//   double get progressFraction =>
//       (pointsBalance / pointsToRedeem).clamp(0.0, 1.0);

//   factory ReferralWallet.fromJson(Map<String, dynamic> json) {
//     final historyList = (json['history'] as List<dynamic>?) ?? <dynamic>[];

//     return ReferralWallet(
//       referralCode: (json['referralCode'] as String?) ?? '',
//       pointsBalance: (json['pointsBalance'] as int?) ?? 0,
//       pointsToRedeem: (json['pointsToRedeem'] as int?) ?? 500,
//       totalReferrals: (json['totalReferrals'] as int?) ?? 0,
//       history: historyList
//           .whereType<Map<String, dynamic>>()
//           .map(ReferralEntry.fromJson)
//           .toList(),
//     );
//   }

//   /// Placeholder used while loading or when the API is unavailable.
//   factory ReferralWallet.empty() => ReferralWallet(
//     referralCode: '------',
//     pointsBalance: 0,
//     pointsToRedeem: 500,
//     totalReferrals: 0,
//     history: [],
//   );
// }

// class ReferralEntry {
//   ReferralEntry({
//     required this.referredName,
//     required this.pointsEarned,
//     required this.date,
//     required this.status,
//   });

//   final String referredName;
//   final int pointsEarned;
//   final String date;

//   /// e.g. 'completed', 'pending'
//   final String status;

//   bool get isCompleted => status.toLowerCase() == 'completed';

//   factory ReferralEntry.fromJson(Map<String, dynamic> json) {
//     return ReferralEntry(
//       referredName: (json['referredName'] as String?) ?? 'Friend',
//       pointsEarned: (json['pointsEarned'] as int?) ?? 0,
//       date: (json['date'] as String?) ?? '',
//       status: (json['status'] as String?) ?? 'pending',
//     );
//   }
// }

class ReferralWallet {
  ReferralWallet({
    required this.referralCode,
    required this.pointsBalance,
    required this.pointsToRedeem,
    required this.totalReferrals,
    required this.history,
  });

  /// User's unique referral code.
  final String referralCode;

  /// Current accumulated points.
  final int pointsBalance;

  /// Points needed to unlock a free service.
  final int pointsToRedeem;

  /// Total number of successful referrals made.
  final int totalReferrals;

  /// Per-referral history entries.
  final List<ReferralEntry> history;

  double get progressFraction =>
      (pointsBalance / pointsToRedeem).clamp(0.0, 1.0);

  factory ReferralWallet.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    final referrals = (json['referrals'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(ReferralEntry.fromJson)
        .toList();

    return ReferralWallet(
      referralCode: ((json['userId'] as String?) ?? '')
          .substring(0, ((json['userId'] as String?) ?? '').length >= 8 ? 8 : 0)
          .toUpperCase(),

      pointsBalance: _parseInt(stats['walletPoints']),

      pointsToRedeem: 500,

      totalReferrals: _parseInt(stats['totalReferrals']),

      history: referrals,
    );
  }

  factory ReferralWallet.empty() => ReferralWallet(
    referralCode: '------',
    pointsBalance: 0,
    pointsToRedeem: 500,
    totalReferrals: 0,
    history: [],
  );

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class ReferralEntry {
  ReferralEntry({
    required this.referredName,
    required this.pointsEarned,
    required this.date,
    required this.status,
  });

  final String referredName;
  final int pointsEarned;
  final String date;

  /// e.g. 'completed', 'pending'
  final String status;

  bool get isCompleted => status.toLowerCase() == 'completed';

  factory ReferralEntry.fromJson(Map<String, dynamic> json) {
    return ReferralEntry(
      referredName:
          (json['referredUserName'] as String?) ??
          (json['username'] as String?) ??
          'Friend',

      pointsEarned: _parseInt(json['pointsEarned']),

      date: (json['createdAt'] as String?) ?? (json['date'] as String?) ?? '',

      status: (json['status'] as String?) ?? 'pending',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
