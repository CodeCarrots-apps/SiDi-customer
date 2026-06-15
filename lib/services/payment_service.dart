import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sidi/controller/payment_controller.dart';
import 'package:sidi/controller/wallet_controller.dart';
import 'package:sidi/services/booking_service.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/models/booking_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

enum PaymentResult { success, failed, cancelled }

class PaymentService {
  static Future<PaymentResult> processPayment({
    required PaymentController paymentCtrl,
    required WalletController? walletCtrl,
    required double totalAmount,
    required String bookingId,
    required String serviceName,
    String? razorpayOrderId,
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
        razorpayOrderId: razorpayOrderId,
        context: context,
      );
    }

    if (selected == PaymentOptionType.upi) {
      return _processUpiPayment(
        totalAmount: totalAmount,
        bookingId: bookingId,
        serviceName: serviceName,
        razorpayOrderId: razorpayOrderId,
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
    String? razorpayOrderId,
    BuildContext? context,
  }) async {
    if (paymentCtrl.isSplitPayment.value) {
      final remainderPart = paymentCtrl.remainderAmount.value;
      final secondMethod = paymentCtrl.splitOption.type;

      if (secondMethod == PaymentOptionType.upi) {
        final upiResult = await _processUpiPayment(
          totalAmount: remainderPart,
          bookingId: bookingId,
          serviceName: 'Split payment remainder',
          razorpayOrderId: razorpayOrderId,
          isPartial: true,
          context: context,
        );
        if (upiResult != PaymentResult.success) return upiResult;
      }

      return PaymentResult.success;
    }

    return PaymentResult.success;
  }

  static Future<PaymentResult> _processUpiPayment({
    required double totalAmount,
    required String bookingId,
    required String serviceName,
    String? razorpayOrderId,
    bool isPartial = false,
    BuildContext? context,
  }) async {
    if (razorpayOrderId == null) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Missing order ID from server. Cannot process payment.',
            ),
          ),
        );
      }
      return PaymentResult.failed;
    }

    final completer = Completer<PaymentResult>();
    final razorpay = Razorpay();

    void handlePaymentSuccess(PaymentSuccessResponse response) async {
      GenericBookingActionResponse verifyResult;

      if (isPartial) {
        verifyResult = await BookingService.verifyPartialUpiPayment(
          bookingId: bookingId,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
      } else {
        verifyResult = await BookingService.verifyUpiPayment(
          bookingId: bookingId,
          razorpayOrderId: razorpayOrderId,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
      }

      if (verifyResult.success) {
        completer.complete(PaymentResult.success);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(verifyResult.message)));
        }
        completer.complete(PaymentResult.failed);
      }
    }

    void handlePaymentError(PaymentFailureResponse response) {
      completer.complete(PaymentResult.failed);
    }

    void handleExternalWallet(ExternalWalletResponse response) {
      completer.complete(PaymentResult.failed);
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    final options = {
      'key': AppConstants.razorpayKey,
      'amount': (totalAmount * 100).toInt(),
      'name': 'SiDi Beauty',
      'description': 'Booking $bookingId - $serviceName',
      'order_id': razorpayOrderId,
      'timeout': 300,
    };

    try {
      razorpay.open(options);
    } catch (e) {
      completer.complete(PaymentResult.failed);
    }

    final result = await completer.future;
    razorpay.clear();

    return result;
  }
}
