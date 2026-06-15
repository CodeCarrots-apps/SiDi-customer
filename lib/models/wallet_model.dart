enum TransactionType { credit, debit }

class Wallet {
  Wallet({
    required this.balance,
    this.points = 0,
    this.currency = 'INR',
    this.transactions = const [],
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json['balance'] ?? 0).toDouble(),
      points: (json['points'] ?? 0).toInt(),
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  final double balance;
  final int points;
  final String currency;
  final List<WalletTransaction> transactions;

  Wallet copyWith({List<WalletTransaction>? transactions, double? balance}) {
    return Wallet(
      balance: balance ?? this.balance,
      points: points,
      currency: currency,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletTransaction {
  WalletTransaction({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.amount,
    required this.type,
    required this.date,
    this.status = 'completed',
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final isCredit = json['type']?.toString().toLowerCase() == 'credit';
    return WalletTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ??
          (isCredit ? 'Added to wallet' : 'Service payment'),
      subtitle: json['subtitle']?.toString() ??
          json['description']?.toString() ??
          '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: isCredit ? TransactionType.credit : TransactionType.debit,
      date: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'completed',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String status;

  bool get isCredit => type == TransactionType.credit;
}

class WalletOrderResponse {
  WalletOrderResponse({
    required this.success,
    required this.message,
    this.order,
    this.prefill,
  });

  factory WalletOrderResponse.fromJson(Map<String, dynamic> json) {
    return WalletOrderResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      order: json['order'] != null
          ? WalletOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      prefill: json['prefill'] != null
          ? WalletPrefill.fromJson(json['prefill'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final String message;
  final WalletOrder? order;
  final WalletPrefill? prefill;
}

class WalletOrder {
  WalletOrder({
    required this.id,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory WalletOrder.fromJson(Map<String, dynamic> json) {
    return WalletOrder(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String? ?? '',
    );
  }

  final String id;
  final int amount;
  final String currency;
  final String keyId;
}

class WalletPrefill {
  WalletPrefill({
    required this.name,
    required this.email,
    required this.contact,
  });

  factory WalletPrefill.fromJson(Map<String, dynamic> json) {
    return WalletPrefill(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
    );
  }

  final String name;
  final String email;
  final String contact;
}

class WalletVerifyResponse {
  WalletVerifyResponse({
    required this.success,
    required this.message,
    this.balance,
    this.currency,
    this.transactionId,
    this.transactionAmount,
    this.transactionDate,
    this.transactionStatus,
  });

  factory WalletVerifyResponse.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'] as Map<String, dynamic>?;
    final tx = json['transaction'] as Map<String, dynamic>?;
    return WalletVerifyResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      balance: wallet != null ? (wallet['balance'] ?? 0).toDouble() : null,
      currency: wallet?['currency'] as String?,
      transactionId: tx?['id']?.toString(),
      transactionAmount: tx != null ? (tx['amount'] ?? 0).toDouble() : null,
      transactionDate: tx?['date'] != null
          ? DateTime.tryParse(tx!['date'].toString())
          : null,
      transactionStatus: tx?['status'] as String?,
    );
  }

  final bool success;
  final String message;
  final double? balance;
  final String? currency;
  final String? transactionId;
  final double? transactionAmount;
  final DateTime? transactionDate;
  final String? transactionStatus;
}

class TransactionsResponse {
  TransactionsResponse({
    required this.success,
    this.transactions = const [],
    this.total = 0,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    final List rawTx = json['transactions'] as List? ?? [];
    return TransactionsResponse(
      success: json['success'] == true,
      transactions: rawTx
          .map((tx) =>
              WalletTransaction.fromJson(tx as Map<String, dynamic>))
          .toList(),
      total: (json['total'] ?? 0).toInt(),
    );
  }

  final bool success;
  final List<WalletTransaction> transactions;
  final int total;
}

class UsePointsResponse {
  UsePointsResponse({
    required this.success,
    required this.message,
    this.discountAmount,
    this.remainingPoints,
  });

  factory UsePointsResponse.fromJson(Map<String, dynamic> json) {
    return UsePointsResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      remainingPoints: (json['remainingPoints'] ?? 0).toInt(),
    );
  }

  final bool success;
  final String message;
  final double? discountAmount;
  final int? remainingPoints;
}

class PayBookingResponse {
  PayBookingResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.receipt,
  });

  factory PayBookingResponse.fromJson(Map<String, dynamic> json) {
    return PayBookingResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      transactionId: json['transactionId'] as String?,
      receipt: json['receipt'] != null
          ? BookingReceipt.fromJson(json['receipt'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final String message;
  final String? transactionId;
  final BookingReceipt? receipt;
}

class BookingReceipt {
  BookingReceipt({
    this.bookingId,
    this.amount,
    this.status,
    this.pointsEarned,
  });

  factory BookingReceipt.fromJson(Map<String, dynamic> json) {
    return BookingReceipt(
      bookingId: json['bookingId'] as String?,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] as String?,
      pointsEarned: (json['pointsEarned'] ?? 0).toInt(),
    );
  }

  final String? bookingId;
  final double? amount;
  final String? status;
  final int? pointsEarned;
}

class BookingReceiptResponse {
  BookingReceiptResponse({
    required this.success,
    this.receipt,
  });

  factory BookingReceiptResponse.fromJson(Map<String, dynamic> json) {
    return BookingReceiptResponse(
      success: json['success'] == true,
      receipt: json['receipt'] != null
          ? BookingReceiptDetail.fromJson(
              json['receipt'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final BookingReceiptDetail? receipt;
}

class BookingReceiptDetail {
  BookingReceiptDetail({
    this.bookingId,
    this.totalAmount,
    this.finalAmount,
    this.paymentMethod,
    this.status,
  });

  factory BookingReceiptDetail.fromJson(Map<String, dynamic> json) {
    return BookingReceiptDetail(
      bookingId: json['bookingId'] as String?,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      status: json['status'] as String?,
    );
  }

  final String? bookingId;
  final double? totalAmount;
  final double? finalAmount;
  final String? paymentMethod;
  final String? status;
}
