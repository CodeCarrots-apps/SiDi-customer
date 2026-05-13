import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/booking_models.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/services/rewards_wallet_service.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.response,
    required this.serviceTitle,
    required this.serviceImage,
    required this.selectedTime,
    required this.selectedDate,
    this.servicePrice,
    this.stylistName,
    required this.stylistImage,
    this.stylistTag,
    this.services = const [],
  });

  final BookingCreateResponse response;
  final String serviceTitle;
  final String serviceImage;
  final String selectedTime;
  final String selectedDate;
  final String? servicePrice;
  final String? stylistName;
  final String? stylistImage;
  final String? stylistTag;
  final List<ServiceCartItem> services;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  RewardsWalletSummary? _walletSummary;
  RewardGrantResult? _rewardGrantResult;
  bool _isLoadingRewards = false;

  List<ServiceCartItem> get _selectedServices => widget.services;

  @override
  void initState() {
    super.initState();
    if (widget.response.success) {
      _awardRewardPoints();
    }
  }

  void _retry() {
    Navigator.pop(context);
  }

  Future<void> _awardRewardPoints() async {
    setState(() {
      _isLoadingRewards = true;
    });

    final bookingId = widget.response.booking?.id.isNotEmpty == true
        ? widget.response.booking!.id
        : '${widget.serviceTitle}-${widget.selectedDate}-${widget.selectedTime}';
    final rewardGrantResult = await RewardsWalletService.awardBookingPoints(
      bookingId: bookingId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _rewardGrantResult = rewardGrantResult;
      _walletSummary = rewardGrantResult.summary;
      _isLoadingRewards = false;
    });
  }

  Future<void> _copyReferralCode() async {
    final referralCode = _walletSummary?.referralCode;
    if (referralCode == null || referralCode.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: referralCode));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Referral code $referralCode copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.response;
    if (!response.success) {
      return _buildError(
        message: response.message,
        context: context,
        showClose: true,
      );
    }

    const statusChipLabel = 'BOOKING CONFIRMED';
    const statusChipColor = Color(0xFF2D7A4F);
    const statusChipIcon = Icons.check_circle_rounded;
    final statusDateText = '${widget.selectedDate}  ·  ${widget.selectedTime}';

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      semanticLabel: 'Back',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'BOOKING STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: screenHeight * 0.32, // Responsive height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          image: DecorationImage(
                            image: NetworkImage(
                              (widget.serviceImage.isNotEmpty)
                                  ? widget.serviceImage
                                  : 'https://via.placeholder.com/600x420',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.60),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 18,
                              left: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: statusChipColor.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusChipIcon,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusChipLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.4,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.serviceTitle,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 28,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        statusDateText,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(
                                widget.stylistImage ??
                                    'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
                              ),
                              // foregroundImage: null,
                              // Accessibility label
                              child: Semantics(label: 'Stylist profile image'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.stylistName ?? 'Your Stylist',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.stylistTag ?? 'Beautician',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF8C8C8C),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         border: Border.all(
                            //           color: const Color(0xFFDDD6C3),
                            //         ),
                            //         shape: BoxShape.circle,
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(
                            //           Icons.chat_bubble_outline,
                            //           size: 18,
                            //           color: Color(0xFF1A1A1A),
                            //           semanticLabel: 'Chat',
                            //         ),
                            //         onPressed:
                            //             null, // Disabled until implemented
                            //         tooltip: 'Chat (coming soon)',
                            //       ),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         border: Border.all(
                            //           color: const Color(0xFFDDD6C3),
                            //         ),
                            //         shape: BoxShape.circle,
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(
                            //           Icons.call,
                            //           size: 18,
                            //           color: Color(0xFF1A1A1A),
                            //           semanticLabel: 'Call',
                            //         ),
                            //         onPressed:
                            //             null, // Disabled until implemented
                            //         tooltip: 'Call (coming soon)',
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Booking reference
                    if (widget.response.booking?.id != null &&
                        widget.response.booking!.id.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0E8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8E2D8)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                size: 16,
                                color: kChampagneColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Booking Ref:  ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: kWarmGrey600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.response.booking!.id,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kEspressoColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_selectedServices.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildServicesCard(),
                      ),
                    if (_selectedServices.length > 1)
                      const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRewardsWalletCard(),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5A059),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'GO TO HOME',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialTab: 1),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'VIEW MY APPOINTMENTS',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: kChampagneColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Booking Timeline widget and method removed

  Widget _buildError({
    required String message,
    required BuildContext context,
    bool showClose = true,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showClose)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                Text(
                  'Booking failed',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retry,
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsWalletCard() {
    final walletSummary = _walletSummary;
    final rewardGrantResult = _rewardGrantResult;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8DFC9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8D4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.wallet_giftcard_rounded,
                  color: Color(0xFF9A6E2E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards Wallet',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rewardGrantResult?.wasDuplicate == true
                          ? 'Points for this booking were already added.'
                          : 'Every confirmed booking adds points to your wallet.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kWarmGrey600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (rewardGrantResult != null && !rewardGrantResult.wasDuplicate)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D7A4F),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '+${rewardGrantResult.pointsAdded} pts',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoadingRewards)
            const Center(child: CircularProgressIndicator())
          else if (walletSummary != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildRewardMetric(
                    '${walletSummary.currentPoints}',
                    'Wallet Points',
                  ),
                ),
                Expanded(
                  child: _buildRewardMetric(
                    '${walletSummary.freeServiceCredits}',
                    'Free Services',
                  ),
                ),
                Expanded(
                  child: _buildRewardMetric(
                    '${walletSummary.referredFriends}',
                    'Referrals',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: walletSummary.progressToNextFreeService,
                backgroundColor: const Color(0xFFE9E1D5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFC79B52),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              walletSummary.hasUnlockedFreeService
                  ? 'Complimentary service unlocked. It is now stored in your wallet.'
                  : '${walletSummary.pointsToNextFreeService} more points unlock your next complimentary service.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: kWarmGrey600,
                height: 1.45,
              ),
            ),
            if (rewardGrantResult != null &&
                rewardGrantResult.newFreeServices > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF6F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'You just unlocked ${rewardGrantResult.newFreeServices} free service ${rewardGrantResult.newFreeServices == 1 ? 'credit' : 'credits'}.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D7A4F),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7DDCF)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referral Code',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            color: kWarmGrey600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          walletSummary.referralCode,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: kEspressoColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Share it with a friend. Referral rewards are ready to be credited into the same wallet flow.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: kWarmGrey600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _copyReferralCode,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE1D6C6)),
                      foregroundColor: kEspressoColor,
                    ),
                    child: const Text('COPY'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: kEspressoColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.4,
            color: kWarmGrey600,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booked Services',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: kEspressoColor,
            ),
          ),
          const SizedBox(height: 14),
          ..._selectedServices.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kChampagneColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kEspressoColor,
                      ),
                    ),
                  ),
                  if (service.price.isNotEmpty)
                    Text(
                      service.price,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kWarmGrey600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
