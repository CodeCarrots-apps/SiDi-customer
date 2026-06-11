import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sidi/controller/payment_controller.dart';
import 'package:sidi/controller/wallet_controller.dart';
import 'package:sidi/utils/app_constants.dart';

enum PaymentResult { success, failed, cancelled }

class PaymentService {
  static Future<PaymentResult> processPayment({
    required PaymentController paymentCtrl,
    required WalletController? walletCtrl,
    required double totalAmount,
    required String bookingId,
    required String serviceName,
    BuildContext? context,
  }) async {
    final selected = paymentCtrl.selected.type;

    if (selected == PaymentOptionType.wallet) {
      if (walletCtrl == null) return PaymentResult.failed;
      return _processWalletPayment(
        walletCtrl: walletCtrl,
        paymentCtrl: paymentCtrl,
        totalAmount: totalAmount,
        bookingId: bookingId,
        context: context,
      );
    }

    if (selected == PaymentOptionType.upi) {
      return _processUpiPayment(
        totalAmount: totalAmount,
        bookingId: bookingId,
        serviceName: serviceName,
        context: context,
      );
    }

    return PaymentResult.success;
  }

  static Future<PaymentResult> _processWalletPayment({
    required WalletController walletCtrl,
    required PaymentController paymentCtrl,
    required double totalAmount,
    required String bookingId,
    BuildContext? context,
  }) async {
    final balance = walletCtrl.wallet.value?.balance ?? 0;

    if (paymentCtrl.isSplitPayment.value) {
      final walletPart = paymentCtrl.walletAmount.value;
      final remainderPart = paymentCtrl.remainderAmount.value;
      final secondMethod = paymentCtrl.splitOption.type;

      if (secondMethod == PaymentOptionType.upi) {
        final upiResult = await _processUpiPayment(
          totalAmount: remainderPart,
          bookingId: bookingId,
          serviceName: 'Split payment remainder',
          context: context,
        );
        if (upiResult != PaymentResult.success) return upiResult;
      }

      walletCtrl.deductBalance(walletPart);
      return PaymentResult.success;
    }

    if (balance < totalAmount) {
      return PaymentResult.failed;
    }

    walletCtrl.deductBalance(totalAmount);
    return PaymentResult.success;
  }

  static Future<PaymentResult> _processUpiPayment({
    required double totalAmount,
    required String bookingId,
    required String serviceName,
    BuildContext? context,
  }) async {
    final tr = 'SIDI${DateTime.now().millisecondsSinceEpoch}';

    final upiUrl = _buildUpiUrl(
      pa: AppConstants.upiMerchantId,
      pn: 'SiDi Beauty',
      am: totalAmount.toStringAsFixed(2),
      tn: 'Booking $bookingId - $serviceName',
      cu: 'INR',
      tr: tr,
    );

    final uri = Uri.parse(upiUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return PaymentResult.failed;
    }

    if (context != null) {
      await _waitForAppForeground();
      if (!context.mounted) return PaymentResult.cancelled;

      return (await showDialog<PaymentResult>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('UPI Payment'),
              content: const Text(
                'Did you complete the payment in the UPI app?',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(ctx, PaymentResult.cancelled),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(ctx, PaymentResult.failed),
                  child: const Text('Payment Failed'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(ctx, PaymentResult.success),
                  child: const Text('Payment Completed'),
                ),
              ],
            ),
          )) ??
          PaymentResult.failed;
    }

    return PaymentResult.success;
  }

  static Future<void> _waitForAppForeground() async {
    if (WidgetsBinding.instance.lifecycleState ==
        AppLifecycleState.resumed) {
      return;
    }
    final completer = Completer<void>();
    final observer = _AppLifecycleObserver(completer);
    WidgetsBinding.instance.addObserver(observer);
    await completer.future;
    WidgetsBinding.instance.removeObserver(observer);
  }

  static String _buildUpiUrl({
    required String pa,
    required String pn,
    required String am,
    required String tn,
    required String cu,
    String? tr,
  }) {
    return 'upi://pay?pa=${Uri.encodeComponent(pa)}'
        '&pn=${Uri.encodeComponent(pn)}'
        '&am=$am'
        '&tn=${Uri.encodeComponent(tn)}'
        '&cu=$cu'
        '${tr != null ? '&tr=${Uri.encodeComponent(tr)}' : ''}';
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  final Completer<void> completer;
  _AppLifecycleObserver(this.completer);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      completer.complete();
    }
  }
}
