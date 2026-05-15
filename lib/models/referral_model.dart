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
    final historyList = (json['history'] as List<dynamic>?) ?? <dynamic>[];

    return ReferralWallet(
      referralCode: (json['referralCode'] as String?) ?? '',
      pointsBalance: (json['pointsBalance'] as int?) ?? 0,
      pointsToRedeem: (json['pointsToRedeem'] as int?) ?? 500,
      totalReferrals: (json['totalReferrals'] as int?) ?? 0,
      history: historyList
          .whereType<Map<String, dynamic>>()
          .map(ReferralEntry.fromJson)
          .toList(),
    );
  }

  /// Placeholder used while loading or when the API is unavailable.
  factory ReferralWallet.empty() => ReferralWallet(
    referralCode: '------',
    pointsBalance: 0,
    pointsToRedeem: 500,
    totalReferrals: 0,
    history: [],
  );
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
      referredName: (json['referredName'] as String?) ?? 'Friend',
      pointsEarned: (json['pointsEarned'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
    );
  }
}
