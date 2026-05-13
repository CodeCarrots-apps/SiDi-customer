import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidi/utils/token_storage.dart';

class RewardsWalletSummary {
  const RewardsWalletSummary({
    required this.currentPoints,
    required this.totalPointsEarned,
    required this.freeServiceCredits,
    required this.pointsRequiredForFreeService,
    required this.bookingsRewarded,
    required this.referredFriends,
    required this.referralCode,
  });

  final int currentPoints;
  final int totalPointsEarned;
  final int freeServiceCredits;
  final int pointsRequiredForFreeService;
  final int bookingsRewarded;
  final int referredFriends;
  final String referralCode;

  int get pointsToNextFreeService {
    final remaining = pointsRequiredForFreeService - currentPoints;
    return remaining <= 0 ? 0 : remaining;
  }

  double get progressToNextFreeService {
    if (pointsRequiredForFreeService <= 0) {
      return 0;
    }
    return (currentPoints / pointsRequiredForFreeService)
        .clamp(0, 1)
        .toDouble();
  }

  bool get hasUnlockedFreeService => freeServiceCredits > 0;
}

class RewardGrantResult {
  const RewardGrantResult({
    required this.summary,
    required this.pointsAdded,
    required this.newFreeServices,
    required this.wasDuplicate,
  });

  final RewardsWalletSummary summary;
  final int pointsAdded;
  final int newFreeServices;
  final bool wasDuplicate;
}

class RewardsWalletService {
  static const int pointsPerBooking = 25;
  static const int pointsPerReferral = 40;
  static const int freeServiceThreshold = 100;

  static const String _currentPointsKey = 'rewards_current_points';
  static const String _totalPointsKey = 'rewards_total_points';
  static const String _freeServiceCreditsKey = 'rewards_free_service_credits';
  static const String _bookingsRewardedKey = 'rewards_bookings_rewarded';
  static const String _referredFriendsKey = 'rewards_referred_friends';
  static const String _referralCodeKey = 'rewards_referral_code';
  static const String _rewardedBookingIdsKey = 'rewards_rewarded_booking_ids';
  static const String _rewardedReferralIdsKey = 'rewards_rewarded_referral_ids';

  static Future<RewardsWalletSummary> loadSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _scopeId();
    final referralCode = await _ensureReferralCode(prefs, scope);

    return RewardsWalletSummary(
      currentPoints: prefs.getInt(_key(_currentPointsKey, scope)) ?? 0,
      totalPointsEarned: prefs.getInt(_key(_totalPointsKey, scope)) ?? 0,
      freeServiceCredits:
          prefs.getInt(_key(_freeServiceCreditsKey, scope)) ?? 0,
      pointsRequiredForFreeService: freeServiceThreshold,
      bookingsRewarded: prefs.getInt(_key(_bookingsRewardedKey, scope)) ?? 0,
      referredFriends: prefs.getInt(_key(_referredFriendsKey, scope)) ?? 0,
      referralCode: referralCode,
    );
  }

  static Future<RewardGrantResult> awardBookingPoints({
    required String bookingId,
    int points = pointsPerBooking,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _scopeId();
    final rewardedIds =
        prefs.getStringList(_key(_rewardedBookingIdsKey, scope)) ?? <String>[];
    final normalizedBookingId = bookingId.trim();

    if (normalizedBookingId.isNotEmpty &&
        rewardedIds.contains(normalizedBookingId)) {
      return RewardGrantResult(
        summary: await loadSummary(),
        pointsAdded: 0,
        newFreeServices: 0,
        wasDuplicate: true,
      );
    }

    final result = await _applyReward(
      prefs: prefs,
      scope: scope,
      pointsToAdd: points,
      bookingsDelta: 1,
      rewardedIdListKey: _rewardedBookingIdsKey,
      rewardedId: normalizedBookingId,
    );

    return RewardGrantResult(
      summary: result.summary,
      pointsAdded: points,
      newFreeServices: result.newFreeServices,
      wasDuplicate: false,
    );
  }

  static Future<RewardGrantResult> awardReferralPoints({
    required String referralId,
    int points = pointsPerReferral,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _scopeId();
    final rewardedIds =
        prefs.getStringList(_key(_rewardedReferralIdsKey, scope)) ?? <String>[];
    final normalizedReferralId = referralId.trim();

    if (normalizedReferralId.isNotEmpty &&
        rewardedIds.contains(normalizedReferralId)) {
      return RewardGrantResult(
        summary: await loadSummary(),
        pointsAdded: 0,
        newFreeServices: 0,
        wasDuplicate: true,
      );
    }

    final result = await _applyReward(
      prefs: prefs,
      scope: scope,
      pointsToAdd: points,
      referralsDelta: 1,
      rewardedIdListKey: _rewardedReferralIdsKey,
      rewardedId: normalizedReferralId,
    );

    return RewardGrantResult(
      summary: result.summary,
      pointsAdded: points,
      newFreeServices: result.newFreeServices,
      wasDuplicate: false,
    );
  }

  static Future<bool> redeemFreeService() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _scopeId();
    final creditsKey = _key(_freeServiceCreditsKey, scope);
    final currentCredits = prefs.getInt(creditsKey) ?? 0;
    if (currentCredits <= 0) {
      return false;
    }

    await prefs.setInt(creditsKey, currentCredits - 1);
    return true;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _scopeId();
    await Future.wait([
      prefs.remove(_key(_currentPointsKey, scope)),
      prefs.remove(_key(_totalPointsKey, scope)),
      prefs.remove(_key(_freeServiceCreditsKey, scope)),
      prefs.remove(_key(_bookingsRewardedKey, scope)),
      prefs.remove(_key(_referredFriendsKey, scope)),
      prefs.remove(_key(_referralCodeKey, scope)),
      prefs.remove(_key(_rewardedBookingIdsKey, scope)),
      prefs.remove(_key(_rewardedReferralIdsKey, scope)),
    ]);
  }

  static Future<_RewardMutationResult> _applyReward({
    required SharedPreferences prefs,
    required String scope,
    required int pointsToAdd,
    int bookingsDelta = 0,
    int referralsDelta = 0,
    String? rewardedIdListKey,
    String? rewardedId,
  }) async {
    final currentPointsKey = _key(_currentPointsKey, scope);
    final totalPointsKey = _key(_totalPointsKey, scope);
    final freeServiceCreditsKey = _key(_freeServiceCreditsKey, scope);
    final currentPoints = prefs.getInt(currentPointsKey) ?? 0;
    final currentTotalPoints = prefs.getInt(totalPointsKey) ?? 0;
    final currentFreeServices = prefs.getInt(freeServiceCreditsKey) ?? 0;
    final updatedPoints = currentPoints + pointsToAdd;
    final unlockedFreeServices = updatedPoints ~/ freeServiceThreshold;
    final rolloverPoints = updatedPoints % freeServiceThreshold;

    await prefs.setInt(currentPointsKey, rolloverPoints);
    await prefs.setInt(totalPointsKey, currentTotalPoints + pointsToAdd);
    await prefs.setInt(
      freeServiceCreditsKey,
      currentFreeServices + unlockedFreeServices,
    );

    if (bookingsDelta != 0) {
      final bookingsRewardedKey = _key(_bookingsRewardedKey, scope);
      final currentBookings = prefs.getInt(bookingsRewardedKey) ?? 0;
      await prefs.setInt(bookingsRewardedKey, currentBookings + bookingsDelta);
    }

    if (referralsDelta != 0) {
      final referredFriendsKey = _key(_referredFriendsKey, scope);
      final currentReferrals = prefs.getInt(referredFriendsKey) ?? 0;
      await prefs.setInt(referredFriendsKey, currentReferrals + referralsDelta);
    }

    if (rewardedIdListKey != null &&
        rewardedId != null &&
        rewardedId.isNotEmpty) {
      final scopedRewardedIdListKey = _key(rewardedIdListKey, scope);
      final rewardedIds =
          prefs.getStringList(scopedRewardedIdListKey) ?? <String>[];
      await prefs.setStringList(scopedRewardedIdListKey, <String>[
        ...rewardedIds,
        rewardedId,
      ]);
    }

    return _RewardMutationResult(
      summary: await loadSummary(),
      newFreeServices: unlockedFreeServices,
    );
  }

  static Future<String> _ensureReferralCode(
    SharedPreferences prefs,
    String scope,
  ) async {
    final referralCodeKey = _key(_referralCodeKey, scope);
    final existingCode = prefs.getString(referralCodeKey);
    if (existingCode != null && existingCode.isNotEmpty) {
      return existingCode;
    }

    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final buffer = StringBuffer('SIDI-');
    for (var i = 0; i < 6; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    final generatedCode = buffer.toString();
    await prefs.setString(referralCodeKey, generatedCode);
    return generatedCode;
  }

  static Future<String> _scopeId() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return 'guest';
    }

    var checksum = 17;
    for (final codeUnit in token.codeUnits) {
      checksum = (checksum * 31 + codeUnit) & 0x7fffffff;
    }
    return 'u${token.length}_${checksum.toRadixString(16)}';
  }

  static String _key(String baseKey, String scope) => '${baseKey}_$scope';
}

class _RewardMutationResult {
  const _RewardMutationResult({
    required this.summary,
    required this.newFreeServices,
  });

  final RewardsWalletSummary summary;
  final int newFreeServices;
}
