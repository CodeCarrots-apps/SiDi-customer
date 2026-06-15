import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sidi/models/wallet_model.dart';
import 'package:sidi/utils/token_storage.dart';

class WalletService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/payment';

  static Dio _dio(String token) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static Future<Wallet> getWallet() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);

    debugPrint('WALLET_SERVICE: Fetching /wallet info...');
    final walletRes = await dio.get('/wallet');
    debugPrint('WALLET_SERVICE: /wallet response: ${walletRes.data}');
    if (walletRes.statusCode != 200 || walletRes.data['success'] != true) {
      throw Exception('Failed to fetch wallet info');
    }

    final walletData = walletRes.data['wallet'] ?? {};
    final wallet = Wallet.fromJson(walletData as Map<String, dynamic>);

    debugPrint('WALLET_SERVICE: Fetching /transactions...');
    final txRes = await dio.get('/transactions');
    debugPrint('WALLET_SERVICE: /transactions response: ${txRes.data}');
    List<WalletTransaction> transactions = [];
    if (txRes.statusCode == 200 && txRes.data['success'] == true) {
      final List rawTx = txRes.data['transactions'] ?? [];
      transactions = rawTx
          .map((tx) => WalletTransaction.fromJson(tx as Map<String, dynamic>))
          .toList();
    }

    return Wallet(
      balance: wallet.balance,
      points: wallet.points,
      currency: wallet.currency,
      transactions: transactions,
    );
  }

  static Future<TransactionsResponse> getTransactions({
    int? page,
    int? limit,
    String? type,
    String? period,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (type != null) queryParams['type'] = type;
    if (period != null) queryParams['period'] = period;

    debugPrint('WALLET_SERVICE: Fetching /transactions with params: $queryParams');
    final response = await dio.get('/transactions', queryParameters: queryParams);
    debugPrint('WALLET_SERVICE: /transactions response: ${response.data}');

    return TransactionsResponse.fromJson(response.data);
  }

  static Future<WalletOrderResponse> addMoney(double amount) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    debugPrint('WALLET_SERVICE: Posting /wallet/add with amount: $amount');
    final response = await dio.post('/wallet/add', data: {
      'amount': amount,
    });
    debugPrint('WALLET_SERVICE: /wallet/add response: ${response.data}');

    return WalletOrderResponse.fromJson(response.data);
  }

  static Future<WalletVerifyResponse> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    debugPrint('WALLET_SERVICE: Posting /wallet/verify-payment');
    final response = await dio.post('/wallet/verify-payment', data: {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });
    debugPrint(
        'WALLET_SERVICE: /wallet/verify-payment response: ${response.data}');

    return WalletVerifyResponse.fromJson(response.data);
  }

  static Future<UsePointsResponse> usePoints(int points) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    debugPrint('WALLET_SERVICE: Posting /wallet/use-points with points: $points');
    final response = await dio.post('/wallet/use-points', data: {
      'points': points,
    });
    debugPrint('WALLET_SERVICE: /wallet/use-points response: ${response.data}');

    return UsePointsResponse.fromJson(response.data);
  }

  static Future<PayBookingResponse> payBooking({
    required String bookingId,
    required String paymentMethod,
    double? walletAmount,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    final data = <String, dynamic>{
      'paymentMethod': paymentMethod,
    };
    if (walletAmount != null) data['walletAmount'] = walletAmount;

    debugPrint(
        'WALLET_SERVICE: Posting /booking/$bookingId/pay with data: $data');
    final response =
        await dio.post('/booking/$bookingId/pay', data: data);
    debugPrint(
        'WALLET_SERVICE: /booking/$bookingId/pay response: ${response.data}');

    return PayBookingResponse.fromJson(response.data);
  }

  static Future<BookingReceiptResponse> getBookingReceipt(
      String bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dio = _dio(token);
    debugPrint('WALLET_SERVICE: Fetching /booking/$bookingId/receipt');
    final response = await dio.get('/booking/$bookingId/receipt');
    debugPrint(
        'WALLET_SERVICE: /booking/$bookingId/receipt response: ${response.data}');

    return BookingReceiptResponse.fromJson(response.data);
  }
}
