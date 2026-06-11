enum TransactionType { credit, debit }

class Wallet {
  Wallet({
    required this.balance,
    this.currency = 'INR',
    required this.transactions,
  });

  final double balance;
  final String currency;
  final List<WalletTransaction> transactions;
}

class WalletTransaction {
  WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    this.status = 'completed',
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String status;

  bool get isCredit => type == TransactionType.credit;
}
