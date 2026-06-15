import 'package:sidi/models/booking.dart';

class BookingAddress {
  final String address;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? unit;
  final String? gateCode;

  BookingAddress({
    required this.address,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.unit,
    this.gateCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      'address': address,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (unit != null && unit!.isNotEmpty) {
      payload['unit'] = unit;
    }
    if (gateCode != null && gateCode!.isNotEmpty) {
      payload['gateCode'] = gateCode;
    }

    return payload;
  }
}

class BookingCreateResponse {
  final bool success;
  final String message;
  final Booking? booking;
  final int? estimatedPrice;
  final int? addonsAmount;
  final int? travelFee;
  final dynamic assignedBeautician;
  final int? broadcastedCount;
  final int? totalServices;
  final int? totalServicePrice;
  final int? totalDiscount;
  final int? estimatedTotalAmount;
  final int? estimatedDuration;
  final String? razorpayOrderId;
  final String? paymentMethod;
  final double? walletDeducted;
  final double? walletAmount;
  final double? remainingAmount;

  BookingCreateResponse({
    required this.success,
    required this.message,
    this.booking,
    this.estimatedPrice,
    this.addonsAmount,
    this.travelFee,
    this.assignedBeautician,
    this.broadcastedCount,
    this.totalServices,
    this.totalServicePrice,
    this.totalDiscount,
    this.estimatedTotalAmount,
    this.estimatedDuration,
    this.razorpayOrderId,
    this.paymentMethod,
    this.walletDeducted,
    this.walletAmount,
    this.remainingAmount,
  });

  factory BookingCreateResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      booking: json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
      estimatedPrice: json['estimatedPrice'] is int
          ? json['estimatedPrice'] as int
          : int.tryParse('${json['estimatedPrice'] ?? ''}'),
      addonsAmount: json['addonsAmount'] is int
          ? json['addonsAmount'] as int
          : int.tryParse('${json['addonsAmount'] ?? ''}'),
      travelFee: json['travelFee'] is int
          ? json['travelFee'] as int
          : int.tryParse('${json['travelFee'] ?? ''}'),
      assignedBeautician: json['assignedBeautician'],
      broadcastedCount: json['broadcastedCount'] is int
          ? json['broadcastedCount'] as int
          : int.tryParse('${json['broadcastedCount'] ?? ''}'),
      totalServices: json['totalServices'] is int
          ? json['totalServices'] as int
          : int.tryParse('${json['totalServices'] ?? ''}'),
      totalServicePrice: json['totalServicePrice'] is int
          ? json['totalServicePrice'] as int
          : int.tryParse('${json['totalServicePrice'] ?? ''}'),
      totalDiscount: json['totalDiscount'] is int
          ? json['totalDiscount'] as int
          : int.tryParse('${json['totalDiscount'] ?? ''}'),
      estimatedTotalAmount: json['estimatedTotalAmount'] is int
          ? json['estimatedTotalAmount'] as int
          : int.tryParse('${json['estimatedTotalAmount'] ?? ''}'),
      estimatedDuration: json['estimatedDuration'] is int
          ? json['estimatedDuration'] as int
          : int.tryParse('${json['estimatedDuration'] ?? ''}'),
      razorpayOrderId: json['razorpayOrderId'] is String
          ? json['razorpayOrderId'] as String
          : null,
      paymentMethod: json['paymentMethod'] is String
          ? json['paymentMethod'] as String
          : null,
      walletDeducted: json['walletDeducted'] is num
          ? (json['walletDeducted'] as num).toDouble()
          : null,
      walletAmount: json['walletAmount'] is num
          ? (json['walletAmount'] as num).toDouble()
          : null,
      remainingAmount: json['remainingAmount'] is num
          ? (json['remainingAmount'] as num).toDouble()
          : null,
    );
  }
}

class BookingTimelineItem {
  final String status;
  final DateTime date;

  BookingTimelineItem({required this.status, required this.date});

  factory BookingTimelineItem.fromJson(Map<String, dynamic> json) {
    return BookingTimelineItem(
      status: json['status'] ?? '',
      date:
          DateTime.tryParse(json['date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class BookingDetail {
  final String id;
  final String status;
  final List<BookingTimelineItem> timeline;
  final int? totalAmount;
  final int? addonsAmount;
  final int? travelFee;
  final int? finalAmount;
  final String? bookingDate;
  final Map<String, dynamic>? timeSlot;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? customer;
  final String? jobId;
  final List<Map<String, dynamic>>? services;
  final List<Map<String, dynamic>>? addons;

  BookingDetail({
    required this.id,
    required this.status,
    required this.timeline,
    this.totalAmount,
    this.addonsAmount,
    this.travelFee,
    this.finalAmount,
    this.bookingDate,
    this.timeSlot,
    this.address,
    this.customer,
    this.jobId,
    this.services,
    this.addons,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final timelineJson = json['timeline'];
    final servicesRaw = json['services'];
    final addonsRaw = json['addons'];
    return BookingDetail(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: json['status'] ?? '',
      timeline: timelineJson is List
          ? timelineJson
                .whereType<Map<String, dynamic>>()
                .map(BookingTimelineItem.fromJson)
                .toList()
          : [],
      totalAmount: json['totalAmount'] is int
          ? json['totalAmount'] as int
          : int.tryParse('${json['totalAmount'] ?? ''}'),
      addonsAmount: json['addonsAmount'] is int
          ? json['addonsAmount'] as int
          : int.tryParse('${json['addonsAmount'] ?? ''}'),
      travelFee: json['travelFee'] is int
          ? json['travelFee'] as int
          : int.tryParse('${json['travelFee'] ?? ''}'),
      finalAmount: json['finalAmount'] is int
          ? json['finalAmount'] as int
          : int.tryParse('${json['finalAmount'] ?? ''}'),
      bookingDate: json['bookingDate'] is String ? json['bookingDate'] as String : null,
      timeSlot: json['timeSlot'] is Map ? Map<String, dynamic>.from(json['timeSlot']) : null,
      address: json['address'] is Map ? Map<String, dynamic>.from(json['address']) : null,
      customer: json['customer'] is Map ? Map<String, dynamic>.from(json['customer']) : null,
      jobId: json['jobId'] is String ? json['jobId'] as String : null,
      services: servicesRaw is List
          ? servicesRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : null,
      addons: addonsRaw is List
          ? addonsRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : null,
    );
  }
}

class BookingDetailResponse {
  final bool success;
  final String message;
  final BookingDetail? booking;

  BookingDetailResponse({
    required this.success,
    required this.message,
    this.booking,
  });

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingDetailResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      booking: json['booking'] is Map<String, dynamic>
          ? BookingDetail.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MyBookingsResponse {
  final bool success;
  final String message;
  final List<Booking> bookings;
  final int total;
  final int currentPage;
  final int totalPages;

  MyBookingsResponse({
    required this.success,
    required this.message,
    required this.bookings,
    required this.total,
    required this.currentPage,
    this.totalPages = 0,
  });

  factory MyBookingsResponse.fromJson(Map<String, dynamic> json) {
    final bookingsJson = json['bookings'];
    return MyBookingsResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      bookings: bookingsJson is List
          ? bookingsJson
                .whereType<Map<String, dynamic>>()
                .map(Booking.fromJson)
                .toList()
          : [],
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total'] ?? ''}') ?? 0,
      currentPage: json['currentPage'] is int
          ? json['currentPage'] as int
          : int.tryParse('${json['currentPage'] ?? ''}') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse('${json['totalPages'] ?? ''}') ?? 0,
    );
  }
}

class GenericBookingActionResponse {
  final bool success;
  final String message;
  final int? refundAmount;
  final Booking? booking;
  final String? razorpayOrderId;
  final String? paymentMethod;
  final String? paymentStatus;
  final Map<String, dynamic>? razorpayPayment;
  final Map<String, dynamic>? partialPayment;
  final double? walletDeducted;
  final double? walletAmount;
  final double? remainingAmount;
  final int? estimatedTotalAmount;

  GenericBookingActionResponse({
    required this.success,
    required this.message,
    this.refundAmount,
    this.booking,
    this.razorpayOrderId,
    this.paymentMethod,
    this.paymentStatus,
    this.razorpayPayment,
    this.partialPayment,
    this.walletDeducted,
    this.walletAmount,
    this.remainingAmount,
    this.estimatedTotalAmount,
  });

  factory GenericBookingActionResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parseMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    return GenericBookingActionResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      refundAmount: json['refundAmount'] is int
          ? json['refundAmount'] as int
          : int.tryParse('${json['refundAmount'] ?? ''}'),
      booking: json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      razorpayPayment: parseMap(json['razorpayPayment']),
      partialPayment: parseMap(json['partialPayment'] ??
          (json['booking'] is Map ? (json['booking'] as Map)['partialPayment'] : null)),
      walletDeducted: json['walletDeducted'] is num
          ? (json['walletDeducted'] as num).toDouble()
          : null,
      walletAmount: json['walletAmount'] is num
          ? (json['walletAmount'] as num).toDouble()
          : null,
      remainingAmount: json['remainingAmount'] is num
          ? (json['remainingAmount'] as num).toDouble()
          : null,
      estimatedTotalAmount: json['estimatedTotalAmount'] is int
          ? json['estimatedTotalAmount'] as int
          : int.tryParse('${json['estimatedTotalAmount'] ?? ''}'),
    );
  }
}

class AvailableSlotsResponse {
  final bool success;
  final String message;
  final List<String> availableSlots;
  final int? totalDuration;

  AvailableSlotsResponse({
    required this.success,
    required this.message,
    required this.availableSlots,
    this.totalDuration,
  });

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      availableSlots: json['availableSlots'] is List
          ? (json['availableSlots'] as List).whereType<String>().toList()
          : [],
      totalDuration: json['totalDuration'] is int
          ? json['totalDuration'] as int
          : int.tryParse('${json['totalDuration'] ?? ''}'),
    );
  }
}
