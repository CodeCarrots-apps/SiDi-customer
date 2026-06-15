import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sidi/models/wallet_model.dart';
import 'package:sidi/services/wallet_service.dart';
import 'package:sidi/utils/app_constants.dart';

class WalletController extends GetxController {
  var wallet = Rx<Wallet?>(null);
  var loading = true.obs;
  var errorMessage = RxnString();
  var transactionsLoading = false.obs;
  var transactionsResponse = Rx<TransactionsResponse?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
  }

  Future<void> fetchWallet() async {
    loading.value = true;
    errorMessage.value = null;

    try {
      wallet.value = await WalletService.getWallet();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchTransactions({
    int? page,
    int? limit,
    String? type,
    String? period,
  }) async {
    transactionsLoading.value = true;
    try {
      transactionsResponse.value = await WalletService.getTransactions(
        page: page,
        limit: limit,
        type: type,
        period: period,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      transactionsLoading.value = false;
    }
  }

  Future<bool> usePoints(int points) async {
    try {
      final res = await WalletService.usePoints(points);
      if (res.success) {
        await fetchWallet();
        Get.snackbar(
          'Success',
          res.message,
          backgroundColor: const Color(0xFF2B8C4D),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar('Error', res.message);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> payBooking({
    required String bookingId,
    required String paymentMethod,
    double? walletAmount,
  }) async {
    try {
      final res = await WalletService.payBooking(
        bookingId: bookingId,
        paymentMethod: paymentMethod,
        walletAmount: walletAmount,
      );
      if (res.success) {
        await fetchWallet();
        Get.snackbar(
          'Success',
          res.message,
          backgroundColor: const Color(0xFF2B8C4D),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar('Error', res.message);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<BookingReceiptResponse?> getBookingReceipt(String bookingId) async {
    try {
      return await WalletService.getBookingReceipt(bookingId);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  void deductBalance(double amount) {
    final w = wallet.value;
    if (w == null) return;
    final newBalance = w.balance - amount;
    wallet.value = Wallet(
      balance: newBalance,
      points: w.points,
      currency: w.currency,
      transactions: [
        WalletTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Service payment',
          subtitle: 'Booking deduction',
          amount: amount,
          type: TransactionType.debit,
          date: DateTime.now(),
          status: 'completed',
        ),
        ...w.transactions,
      ],
    );
  }

  Future<bool> addMoney(double amount) async {
    try {
      final orderRes = await WalletService.addMoney(amount);

      if (!orderRes.success) {
        Get.snackbar('Error', orderRes.message);
        return false;
      }

      if (orderRes.order == null) {
        Get.snackbar('Error', 'No payment order returned from server.');
        return false;
      }

      final razorpay = Razorpay();
      final completer = Completer<bool>();

      void onSuccess(PaymentSuccessResponse response) async {
        debugPrint(
            'WALLET_CTRL: Razorpay success - paymentId=${response.paymentId}');
        final verifyRes = await WalletService.verifyPayment(
          razorpayOrderId: response.orderId ?? orderRes.order!.id,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
        debugPrint('WALLET_CTRL: verify result success=${verifyRes.success}');
        if (verifyRes.success) {
          await fetchWallet();
          completer.complete(true);
        } else {
          Get.snackbar('Error', verifyRes.message);
          completer.complete(false);
        }
      }

      void onError(PaymentFailureResponse response) {
        debugPrint(
            'WALLET_CTRL: Razorpay error - code=${response.code} message=${response.message}');
        Get.snackbar(
            'Payment Failed', response.message ?? 'Payment was unsuccessful.');
        completer.complete(false);
      }

      void onExternalWallet(ExternalWalletResponse response) {
        debugPrint('WALLET_CTRL: Razorpay external wallet');
        completer.complete(false);
      }

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

      final opts = <String, dynamic>{
        'key': AppConstants.razorpayKey,
        'amount': orderRes.order!.amount,
        'name': 'SiDi Beauty',
        'description': 'Wallet Top-up',
        'order_id': orderRes.order!.id,
        'timeout': 300,
      };

      if (orderRes.prefill != null) {
        opts['prefill'] = {
          'name': orderRes.prefill!.name,
          'email': orderRes.prefill!.email,
          'contact': orderRes.prefill!.contact,
        };
      }

      debugPrint(
          'WALLET_CTRL: Opening Razorpay with order_id=${orderRes.order!.id} amount=${orderRes.order!.amount}');
      try {
        razorpay.open(opts);
        debugPrint('WALLET_CTRL: razorpay.open() returned successfully');
      } catch (e) {
        debugPrint('WALLET_CTRL: razorpay.open() threw: $e');
        Get.snackbar('Error', 'Failed to open payment gateway.');
        razorpay.clear();
        return false;
      }

      final result = await completer.future;
      debugPrint('WALLET_CTRL: completer resolved with $result');
      razorpay.clear();
      return result;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}
