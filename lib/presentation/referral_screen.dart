import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/referral_model.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with TickerProviderStateMixin {
  final Dio _dio = Dio();

  bool _isLoading = true;
  String? _errorMessage;
  ReferralWallet? _wallet;

  // Animation controllers
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;

  late Animation<double> _progressAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _loadWallet();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token is missing.';
      });
      return;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.referralWallet,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      if (response.statusCode == 200 && data['success'] == true) {
        final wallet = ReferralWallet.fromJson(
          data['data'] as Map<String, dynamic>? ?? data,
        );
        if (!mounted) return;
        setState(() {
          _wallet = wallet;
          _isLoading = false;
        });
        _runEntryAnimations(wallet.progressFraction);
      } else {
        _handleError(
          (data['message'] as String?) ?? 'Unable to load referral data.',
        );
      }
    } on DioException catch (error) {
      // ── Fallback: use demo data so the screen is still usable ──────────────
      // Remove this block once the API is live and replace with _handleError().
      final demoWallet = ReferralWallet(
        referralCode: 'SIDI-DEMO',
        pointsBalance: 180,
        pointsToRedeem: 500,
        totalReferrals: 3,
        history: [
          ReferralEntry(
            referredName: 'Amara J.',
            pointsEarned: 50,
            date: '2026-05-01T00:00:00.000Z',
            status: 'completed',
          ),
          ReferralEntry(
            referredName: 'Priya M.',
            pointsEarned: 50,
            date: '2026-04-20T00:00:00.000Z',
            status: 'completed',
          ),
          ReferralEntry(
            referredName: 'Lena R.',
            pointsEarned: 80,
            date: '2026-05-10T00:00:00.000Z',
            status: 'pending',
          ),
        ],
      );
      if (!mounted) return;
      setState(() {
        _wallet = demoWallet;
        _isLoading = false;
      });
      _runEntryAnimations(demoWallet.progressFraction);
      debugPrint('[ReferralScreen] API unavailable, using demo data: $error');
    } catch (_) {
      _handleError('Something went wrong. Please try again.');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _runEntryAnimations(double targetProgress) {
    _progressAnim = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  Future<void> _copyCode() async {
    final code = _wallet?.referralCode ?? '';
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kEspressoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        content: Text(
          'Referral code copied!',
          style: AppFonts.inter(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Future<void> _shareCode() async {
    final code = _wallet?.referralCode ?? '';
    if (code.isEmpty) return;
    await Share.share(
      'Join SiDi and get premium beauty services! Use my referral code $code '
      'when you sign up and we both earn reward points. '
      'Download SiDi now! 💅',
      subject: 'Join SiDi with my referral code',
    );
  }

  Future<void> _redeemPoints() async {
    final wallet = _wallet;
    if (wallet == null || wallet.pointsBalance < wallet.pointsToRedeem) return;

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.referralRedeem,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loader

      final data = response.data ?? <String, dynamic>{};
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kAccentGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            content: Text(
              'Your free service has been added to your account!',
              style: AppFonts.inter(color: Colors.white, fontSize: 13),
            ),
          ),
        );
        _loadWallet(forceRefresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((data['message'] as String?) ?? 'Redemption failed.'),
          ),
        );
      }
    } on DioException {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to redeem. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);

    return Scaffold(
      backgroundColor: kWarmGrey50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kWarmGrey50,
            surfaceTintColor: kWarmGrey50,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 16 * scale,
                color: kCharcoalColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'REFER & EARN',
              style: AppFonts.inter(
                fontSize: 11 * scale,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
                color: kCharcoalColor,
              ),
            ),
          ),
          if (_isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildShimmer(scale),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(hasScrollBody: false, child: _buildError(scale))
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                8 * scale,
                20 * scale,
                100 * scale,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(scale),
                        SizedBox(height: 20 * scale),
                        _buildProgressCard(scale),
                        SizedBox(height: 20 * scale),
                        _buildHowItWorks(scale),
                        SizedBox(height: 20 * scale),
                        _buildHistory(scale),
                      ],
                    ),
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, (1 - _fadeAnim.value) * 12),
                      child: Transform.scale(
                        scale: 0.985 + (_fadeAnim.value * 0.015),
                        child: child,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Hero – referral code card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroCard(double scale) {
    final code = _wallet?.referralCode ?? '';

    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: kEspressoColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            'YOUR REFERRAL CODE',
            style: AppFonts.inter(
              fontSize: 9 * scale,
              letterSpacing: 4,
              color: kAccentGold,
            ),
          ),
          SizedBox(height: 16 * scale),
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 28 * scale,
                vertical: 14 * scale,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: kAccentGold, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                code,
                style: AppFonts.inter(
                  fontSize: 26 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.copy_rounded,
                  label: 'COPY',
                  onTap: _copyCode,
                  scale: scale,
                  outlined: true,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _actionButton(
                  icon: Icons.ios_share_rounded,
                  label: 'SHARE',
                  onTap: _shareCode,
                  scale: scale,
                  outlined: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double scale,
    required bool outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : kAccentGold,
          border: outlined ? Border.all(color: kAccentGold) : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14 * scale, color: Colors.white),
            SizedBox(width: 6 * scale),
            Text(
              label,
              style: AppFonts.inter(
                fontSize: 10 * scale,
                letterSpacing: 3,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Progress / Wallet card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProgressCard(double scale) {
    final wallet = _wallet!;
    final canRedeem = wallet.pointsBalance >= wallet.pointsToRedeem;

    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kWarmGrey200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REWARD WALLET',
                style: AppFonts.inter(
                  fontSize: 9 * scale,
                  letterSpacing: 4,
                  color: kAccentGold,
                ),
              ),
              Text(
                '${wallet.totalReferrals} referral${wallet.totalReferrals != 1 ? 's' : ''}',
                style: AppFonts.inter(
                  fontSize: 10 * scale,
                  color: kWarmGrey600,
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${wallet.pointsBalance}',
                style: AppFonts.playfairDisplay(
                  fontSize: 48 * scale,
                  color: kCharcoalColor,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6 * scale, left: 4 * scale),
                child: Text(
                  '/ ${wallet.pointsToRedeem} pts',
                  style: AppFonts.inter(
                    fontSize: 12 * scale,
                    color: kWarmGrey600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: _progressAnim.value,
                  minHeight: 6 * scale,
                  backgroundColor: kWarmGrey200,
                  valueColor: const AlwaysStoppedAnimation<Color>(kAccentGold),
                );
              },
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            canRedeem
                ? 'You\'ve earned a free service! Redeem now.'
                : '${wallet.pointsToRedeem - wallet.pointsBalance} pts away from a free service',
            style: AppFonts.inter(
              fontSize: 11 * scale,
              color: canRedeem ? kAccentGold : kWarmGrey600,
            ),
          ),
          if (canRedeem) ...[
            SizedBox(height: 18 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _redeemPoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: Text(
                  'REDEEM FREE SERVICE',
                  style: AppFonts.inter(
                    fontSize: 10 * scale,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  How it works
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHowItWorks(double scale) {
    final steps = [
      _StepData(
        icon: Icons.share_outlined,
        title: 'Share your code',
        description: 'Send your unique referral code to friends and family.',
      ),
      _StepData(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Friend signs up',
        description: 'They register on SiDi using your referral code.',
      ),
      _StepData(
        icon: Icons.stars_outlined,
        title: 'You earn points',
        description:
            'You receive 50 pts per referral, 80 pts when they book their first service.',
      ),
      _StepData(
        icon: Icons.card_giftcard_outlined,
        title: 'Redeem for free service',
        description:
            'Once you hit ${_wallet?.pointsToRedeem ?? 500} pts, unlock a complimentary service.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale),
          child: Text(
            'HOW IT WORKS',
            style: AppFonts.inter(
              fontSize: 9 * scale,
              letterSpacing: 4,
              color: kAccentGold,
            ),
          ),
        ),
        SizedBox(height: 14 * scale),
        ...steps.asMap().entries.map((entry) {
          return _buildStepRow(entry.value, entry.key, steps.length, scale);
        }),
      ],
    );
  }

  Widget _buildStepRow(_StepData step, int index, int total, double scale) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline
          SizedBox(
            width: 36 * scale,
            child: Column(
              children: [
                Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    color: kWarmGrey100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(step.icon, size: 16 * scale, color: kAccentGold),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: kWarmGrey200,
                      margin: EdgeInsets.symmetric(vertical: 4 * scale),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: index < total - 1 ? 20 * scale : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8 * scale),
                  Text(
                    step.title,
                    style: AppFonts.inter(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                      color: kCharcoalColor,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    step.description,
                    style: AppFonts.inter(
                      fontSize: 12 * scale,
                      color: kWarmGrey600,
                      height: 1.4,
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

  // ─────────────────────────────────────────────────────────────────────────
  //  Referral history
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHistory(double scale) {
    final history = _wallet?.history ?? [];
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale),
          child: Text(
            'REFERRAL HISTORY',
            style: AppFonts.inter(
              fontSize: 9 * scale,
              letterSpacing: 4,
              color: kAccentGold,
            ),
          ),
        ),
        SizedBox(height: 14 * scale),
        ...history.asMap().entries.map((entry) {
          return _buildHistoryRow(entry.value, scale);
        }),
      ],
    );
  }

  Widget _buildHistoryRow(ReferralEntry entry, double scale) {
    final date = _formatDate(entry.date);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 14 * scale,
        horizontal: 16 * scale,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kWarmGrey200)),
      ),
      child: Row(
        children: [
          Container(
            width: 38 * scale,
            height: 38 * scale,
            decoration: BoxDecoration(
              color: kWarmGrey100,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                entry.referredName.isNotEmpty
                    ? entry.referredName[0].toUpperCase()
                    : '?',
                style: AppFonts.playfairDisplay(
                  fontSize: 16 * scale,
                  color: kAccentGold,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.referredName,
                  style: AppFonts.inter(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w400,
                    color: kCharcoalColor,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  date,
                  style: AppFonts.inter(
                    fontSize: 10 * scale,
                    color: kWarmGrey600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${entry.pointsEarned} pts',
                style: AppFonts.inter(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: entry.isCompleted ? kAccentGold : kWarmGrey600,
                ),
              ),
              SizedBox(height: 2 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: entry.isCompleted
                      ? kAccentGold.withAlpha(25)
                      : kWarmGrey100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  entry.status.toUpperCase(),
                  style: AppFonts.inter(
                    fontSize: 8 * scale,
                    letterSpacing: 1.5,
                    color: entry.isCompleted ? kAccentGold : kWarmGrey600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Shimmer / Error
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildShimmer(double scale) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          children: [
            Container(
              height: 200 * scale,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 20 * scale),
            Container(
              height: 160 * scale,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 20 * scale),
            Container(
              height: 240 * scale,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppFonts.inter(fontSize: 14 * scale, color: kCharcoalColor),
          ),
          SizedBox(height: 20 * scale),
          OutlinedButton(
            onPressed: () => _loadWallet(forceRefresh: true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kWarmGrey200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Text(
              'RETRY',
              style: AppFonts.inter(
                fontSize: 12 * scale,
                letterSpacing: 2,
                color: kAccentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
