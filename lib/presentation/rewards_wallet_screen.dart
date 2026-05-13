import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/services/rewards_wallet_service.dart';

class RewardsWalletScreen extends StatefulWidget {
  const RewardsWalletScreen({super.key});

  @override
  State<RewardsWalletScreen> createState() => _RewardsWalletScreenState();
}

class _RewardsWalletScreenState extends State<RewardsWalletScreen> {
  RewardsWalletSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final summary = await RewardsWalletService.loadSummary();
    if (!mounted) {
      return;
    }

    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  Future<void> _copyReferralCode() async {
    final code = _summary?.referralCode;
    if (code == null || code.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Referral code $code copied.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarmGrey50,
      appBar: AppBar(
        backgroundColor: kWarmGrey50,
        surfaceTintColor: kWarmGrey50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'REWARDS & REFERRAL',
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
            color: kCharcoalColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSummary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 18),
                  _buildProgressCard(),
                  const SizedBox(height: 18),
                  _buildReferralCard(),
                  const SizedBox(height: 18),
                  _buildRulesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _summary!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1913), Color(0xFF3D2F20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rewards Wallet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.hasUnlockedFreeService
                ? 'You already have ${summary.freeServiceCredits} complimentary ${summary.freeServiceCredits == 1 ? 'service' : 'services'} waiting in your wallet.'
                : 'Keep collecting points through bookings and referrals to unlock complimentary services.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildHeroMetric(
                  '${summary.currentPoints}',
                  'Current Points',
                ),
              ),
              Expanded(
                child: _buildHeroMetric(
                  '${summary.freeServiceCredits}',
                  'Free Services',
                ),
              ),
              Expanded(
                child: _buildHeroMetric(
                  '${summary.totalPointsEarned}',
                  'Lifetime Points',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final summary = _summary!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kWarmGrey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Complimentary Service',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: kEspressoColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.hasUnlockedFreeService
                ? 'A service credit has already been unlocked. New points are now building toward your next one.'
                : '${summary.pointsToNextFreeService} more points needed to unlock a complimentary service.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: kWarmGrey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: summary.progressToNextFreeService,
              backgroundColor: const Color(0xFFE9E1D5),
              valueColor: const AlwaysStoppedAnimation<Color>(kAccentGold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric(
                  '${summary.bookingsRewarded}',
                  'Rewarded Bookings',
                ),
              ),
              Expanded(
                child: _buildSmallMetric(
                  '${summary.referredFriends}',
                  'Referral Rewards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    final summary = _summary!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DDCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral Option',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: kEspressoColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Share your code with a friend. When referral rewards are credited, the bonus lands in the same wallet and counts toward free-service unlocks.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: kWarmGrey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kWarmGrey200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    summary.referralCode,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: kEspressoColor,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: _copyReferralCode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kWarmGrey200),
                    foregroundColor: kEspressoColor,
                  ),
                  child: const Text('COPY'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kWarmGrey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: kEspressoColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleRow(
            '25 points',
            'Added to the wallet after every confirmed booking.',
          ),
          const SizedBox(height: 12),
          _buildRuleRow(
            '40 points',
            'Reserved for each successful referral reward credit.',
          ),
          const SizedBox(height: 12),
          _buildRuleRow(
            '100 points',
            'Automatically converts into one complimentary service credit.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            color: kEspressoColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.4,
            color: kWarmGrey600,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleRow(String value, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFE5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kEspressoColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: kWarmGrey600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
