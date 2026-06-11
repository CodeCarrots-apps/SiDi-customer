import 'package:get/get.dart';
import 'package:sidi/models/wallet_model.dart';

class WalletController extends GetxController {
  var wallet = Rx<Wallet?>(null);
  var loading = true.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
  }

  Future<void> fetchWallet() async {
    loading.value = true;
    errorMessage.value = null;

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      wallet.value = Wallet(
        balance: 1250.00,
        currency: 'INR',
        transactions: [
          WalletTransaction(
            id: '1',
            title: 'Hair Styling - Elena',
            subtitle: 'Service payment',
            amount: 450.00,
            type: TransactionType.debit,
            date: DateTime.now().subtract(const Duration(hours: 2)),
            status: 'completed',
          ),
          WalletTransaction(
            id: '2',
            title: 'Added to wallet',
            subtitle: 'Online transfer',
            amount: 2000.00,
            type: TransactionType.credit,
            date: DateTime.now().subtract(const Duration(days: 1)),
            status: 'completed',
          ),
          WalletTransaction(
            id: '3',
            title: 'Facial Treatment - Maya',
            subtitle: 'Service payment',
            amount: 350.00,
            type: TransactionType.debit,
            date: DateTime.now().subtract(const Duration(days: 3)),
            status: 'completed',
          ),
          WalletTransaction(
            id: '4',
            title: 'Cashback Reward',
            subtitle: 'Weekly cashback',
            amount: 50.00,
            type: TransactionType.credit,
            date: DateTime.now().subtract(const Duration(days: 5)),
            status: 'completed',
          ),
          WalletTransaction(
            id: '5',
            title: 'Manicure - Sophie',
            subtitle: 'Service payment',
            amount: 280.00,
            type: TransactionType.debit,
            date: DateTime.now().subtract(const Duration(days: 7)),
            status: 'completed',
          ),
        ],
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void deductBalance(double amount) {
    final w = wallet.value;
    if (w == null) return;
    final newBalance = w.balance - amount;
    wallet.value = Wallet(
      balance: newBalance,
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
}
