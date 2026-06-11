import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PaymentOptionType { wallet, upi, onsite }

class PaymentOption {
  PaymentOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final PaymentOptionType type;
  final String label;
  final String subtitle;
  final IconData icon;
}

class PaymentController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final RxBool isSplitPayment = false.obs;
  final RxInt splitIndex = 1.obs;
  final RxDouble walletAmount = 0.0.obs;
  final RxDouble remainderAmount = 0.0.obs;

  final List<PaymentOption> options = [
    PaymentOption(
      type: PaymentOptionType.wallet,
      label: 'Pay Using Wallet',
      subtitle: 'Balance: \u20B91,250.00',
      icon: Icons.account_balance_wallet_rounded,
    ),
    PaymentOption(
      type: PaymentOptionType.upi,
      label: 'Pay Using UPI',
      subtitle: 'Google Pay, PhonePe, Paytm',
      icon: Icons.qr_code_scanner_rounded,
    ),
    PaymentOption(
      type: PaymentOptionType.onsite,
      label: 'Pay On-site',
      subtitle: 'Cash, Card, UPI at venue',
      icon: Icons.payments_rounded,
    ),
  ];

  PaymentOption get selected => options[selectedIndex.value];
  PaymentOption get splitOption => options[splitIndex.value];

  void selectPayment(int index) {
    selectedIndex.value = index;
    isSplitPayment.value = false;
  }

  void enableSplit(double walletBal, double total) {
    walletAmount.value = walletBal;
    remainderAmount.value = total - walletBal;
    isSplitPayment.value = true;
  }

  void selectSplitMethod(int index) {
    splitIndex.value = index;
  }

  void disableSplit() {
    isSplitPayment.value = false;
  }
}
