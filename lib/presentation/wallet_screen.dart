import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/controller/wallet_controller.dart';
import 'package:sidi/models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late final WalletController controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WalletController());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
              'WALLET',
              style: AppFonts.inter(
                fontSize: 11 * scale,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
                color: kCharcoalColor,
              ),
            ),
          ),
          Obx(() {
            if (controller.loading.value) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _buildShimmer(scale),
              );
            }
            if (controller.errorMessage.value != null ||
                controller.wallet.value == null) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(scale, controller),
              );
            }
            final w = controller.wallet.value!;
            final totalCredits = w.transactions
                .where((t) => t.isCredit)
                .fold<double>(0, (s, t) => s + t.amount);
            final totalDebits = w.transactions
                .where((t) => !t.isCredit)
                .fold<double>(0, (s, t) => s + t.amount);

            return SliverPadding(
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
                    builder: (context, _) => Transform.translate(
                      offset: Offset(0, (1 - _fadeAnim.value) * 16),
                      child: Transform.scale(
                        scale: 0.98 + (_fadeAnim.value * 0.02),
                        child: _buildBalanceCard(w, scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, _) => Opacity(
                      opacity: _fadeAnim.value,
                      child: _buildStatsRow(totalCredits, totalDebits, scale),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, _) => Opacity(
                      opacity: _fadeAnim.value,
                      child: _buildQuickActions(scale),
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, _) => Opacity(
                      opacity: _fadeAnim.value,
                      child: _buildTransactionHistory(w, scale),
                    ),
                  ),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Wallet wallet, double scale) {
    final formatter = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 2);
    final formatted = formatter.format(wallet.balance);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kEspressoColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40 * scale,
            right: -30 * scale,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 180 * scale,
                height: 180 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kAccentGold.withAlpha(30),
                    width: 20 * scale,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50 * scale,
            left: -40 * scale,
            child: Container(
              width: 140 * scale,
              height: 140 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kAccentGold.withAlpha(15),
                  width: 30 * scale,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              22 * scale,
              24 * scale,
              24 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28 * scale,
                      height: 28 * scale,
                      decoration: BoxDecoration(
                        color: kAccentGold.withAlpha(30),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 14 * scale,
                        color: kAccentGold,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      'TOTAL BALANCE',
                      style: AppFonts.inter(
                        fontSize: 9 * scale,
                        letterSpacing: 3,
                        color: kAccentGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                Text(
                  formatted,
                  style: AppFonts.playfairDisplay(
                    fontSize: 44 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'AVAILABLE BALANCE',
                  style: AppFonts.inter(
                    fontSize: 9 * scale,
                    letterSpacing: 3,
                    color: opacity(kAccentGold, 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    double totalCredits,
    double totalDebits,
    double scale,
  ) {
    final f = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 0);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kWarmGrey200),
            ),
            child: Row(
              children: [
                Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B8C4D).withAlpha(20),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 14 * scale,
                    color: const Color(0xFF2B8C4D),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREDITS',
                      style: AppFonts.inter(
                        fontSize: 7 * scale,
                        letterSpacing: 2,
                        color: kWarmGrey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      f.format(totalCredits),
                      style: AppFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: kCharcoalColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kWarmGrey200),
            ),
            child: Row(
              children: [
                Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: BoxDecoration(
                    color: kWarmGrey100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 14 * scale,
                    color: kWarmGrey600,
                  ),
                ),
                SizedBox(width: 10 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPENT',
                      style: AppFonts.inter(
                        fontSize: 7 * scale,
                        letterSpacing: 2,
                        color: kWarmGrey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      f.format(totalDebits),
                      style: AppFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: kCharcoalColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(double scale) {
    return Row(
      children: [
        Expanded(child: _actionCard(Icons.add_circle_outline, 'ADD MONEY', scale)),
        SizedBox(width: 10 * scale),
        Expanded(child: _actionCard(Icons.send_rounded, 'SEND', scale)),
        SizedBox(width: 10 * scale),
        Expanded(
          child: _actionCard(Icons.receipt_long_outlined, 'HISTORY', scale),
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kWarmGrey200),
      ),
      child: Column(
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: kAccentGold.withAlpha(20),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(icon, size: 16 * scale, color: kAccentGold),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: AppFonts.inter(
              fontSize: 8 * scale,
              letterSpacing: 2,
              color: kCharcoalColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(Wallet wallet, double scale) {
    final grouped = _groupTransactions(wallet.transactions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2 * scale),
              child: Text(
                'RECENT TRANSACTIONS',
                style: AppFonts.inter(
                  fontSize: 9 * scale,
                  letterSpacing: 3,
                  color: kAccentGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'View all',
              style: AppFonts.inter(
                fontSize: 9 * scale,
                letterSpacing: 1,
                color: kCharcoalColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 14 * scale),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: kWarmGrey200),
          ),
          child: Column(
            children: [
              ...grouped.entries.expand((entry) {
                return [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16 * scale,
                      12 * scale,
                      16 * scale,
                      4 * scale,
                    ),
                    child: Text(
                      entry.key,
                      style: AppFonts.inter(
                        fontSize: 9 * scale,
                        color: kWarmGrey600,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (tx) => _buildTransactionRow(tx, scale),
                  ),
                ];
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(WalletTransaction tx, double scale) {
    final f = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 0);
    final formatted = f.format(tx.amount);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12 * scale,
        horizontal: 16 * scale,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kWarmGrey100)),
      ),
      child: Row(
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: tx.isCredit
                  ? const Color(0xFF2B8C4D).withAlpha(15)
                  : kWarmGrey100,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              tx.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14 * scale,
              color: tx.isCredit
                  ? const Color(0xFF2B8C4D)
                  : kCharcoalColor.withAlpha(150),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppFonts.inter(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: kCharcoalColor,
                  ),
                ),
                SizedBox(height: 1 * scale),
                Text(
                  tx.subtitle,
                  style: AppFonts.inter(
                    fontSize: 9 * scale,
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
                '${tx.isCredit ? '+' : '-'}$formatted',
                style: AppFonts.inter(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: tx.isCredit
                      ? const Color(0xFF2B8C4D)
                      : kCharcoalColor,
                ),
              ),
              SizedBox(height: 2 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 1 * scale,
                ),
                decoration: BoxDecoration(
                  color: kAccentGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Completed',
                  style: AppFonts.inter(
                    fontSize: 7 * scale,
                    letterSpacing: 1,
                    color: kAccentGold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<WalletTransaction>> _groupTransactions(
    List<WalletTransaction> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    Map<String, List<WalletTransaction>> grouped = {};
    for (final tx in transactions) {
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String label;
      if (d == today) {
        label = 'TODAY';
      } else if (d == yesterday) {
        label = 'YESTERDAY';
      } else if (d.isAfter(thisWeek)) {
        label = 'THIS WEEK';
      } else if (d.isAfter(thisMonth)) {
        label = 'THIS MONTH';
      } else {
        label = 'EARLIER';
      }
      grouped.putIfAbsent(label, () => []).add(tx);
    }
    return grouped;
  }

  Widget _buildShimmer(double scale) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          children: [
            Container(
              height: 180 * scale,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60 * scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Container(
                    height: 60 * scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 10 * scale,
                    ),
                    child: Container(
                      height: 64 * scale,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 28 * scale),
            Container(
              height: 200 * scale,
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

  Widget _buildError(double scale, WalletController controller) {
    final msg = controller.errorMessage.value ??
        'Unable to load wallet. Please try again.';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            msg,
            textAlign: TextAlign.center,
            style: AppFonts.inter(
              fontSize: 14 * scale,
              color: kCharcoalColor,
            ),
          ),
          SizedBox(height: 20 * scale),
          OutlinedButton(
            onPressed: () => controller.fetchWallet(),
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
}
