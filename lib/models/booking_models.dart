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

  BookingCreateResponse({
    required this.success,
    required this.message,
    this.booking,
    this.estimatedPrice,
    this.addonsAmount,
    this.travelFee,
    this.assignedBeautician,
    this.broadcastedCount,
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

  BookingDetail({
    required this.id,
    required this.status,
    required this.timeline,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final timelineJson = json['timeline'];
    return BookingDetail(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: json['status'] ?? '',
      timeline: timelineJson is List
          ? timelineJson
                .whereType<Map<String, dynamic>>()
                .map(BookingTimelineItem.fromJson)
                .toList()
          : [],
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

  MyBookingsResponse({
    required this.success,
    required this.message,
    required this.bookings,
    required this.total,
    required this.currentPage,
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
    );
  }
}

class GenericBookingActionResponse {
  final bool success;
  final String message;
  final int? refundAmount;
  final Booking? booking;

  GenericBookingActionResponse({
    required this.success,
    required this.message,
    this.refundAmount,
    this.booking,
  });

  factory GenericBookingActionResponse.fromJson(Map<String, dynamic> json) {
    return GenericBookingActionResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      refundAmount: json['refundAmount'] is int
          ? json['refundAmount'] as int
          : int.tryParse('${json['refundAmount'] ?? ''}'),
      booking: json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AvailableSlotsResponse {
  final bool success;
  final String message;
  final List<String> availableSlots;

  AvailableSlotsResponse({
    required this.success,
    required this.message,
    required this.availableSlots,
  });

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      availableSlots: json['availableSlots'] is List
          ? (json['availableSlots'] as List).whereType<String>().toList()
          : [],
    );
  }
}
