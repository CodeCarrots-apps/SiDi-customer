import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:location/location.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/models/stylist.dart';

import 'confirmationscreen.dart';
import 'waitinglistscreen.dart';

import '../models/address_model.dart';
import '../models/booking.dart';
import '../models/booking_models.dart';
import '../models/edit_result.dart';
import '../services/booking_service.dart';
import '../services/appointments_sync_service.dart';
import '../services/local_storage_service.dart';
import 'edit_address_screen.dart';
import '../controller/payment_controller.dart';
import '../controller/wallet_controller.dart';
import '../services/payment_service.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({
    super.key,
    required this.selectedDateDisplay,
    required this.selectedDateIso,
    required this.selectedTime,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceImage,
    this.servicePrice = '',
    this.stylist,
    this.beauticianId,
    this.services = const [],
  });

  final String selectedDateDisplay;
  final String selectedDateIso;
  final String selectedTime;
  final String serviceId;
  final String serviceTitle;
  final String serviceImage;
  final String servicePrice;
  final Stylist? stylist;
  final String? beauticianId;
  final List<ServiceCartItem> services;

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  final PaymentController paymentController = Get.put(PaymentController());
  final WalletController _walletCtrl = Get.find<WalletController>();

  int selectedAddressIndex = 0;
  bool _isLoading = true;
  bool _isBooking = false;

  List<AddressModel> _addresses = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kBackgroundLight,
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(),
                              const SizedBox(height: 18),
                              _buildAppointmentSummary(),
                              if (_addonServices.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildAddonsSection(),
                              ],
                              const SizedBox(height: 26),
                              ...List.generate(
                                _addresses.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: _buildAddressCard(index),
                                ),
                              ),
                              _buildAddTile(
                                icon: Icons.add,
                                label: 'Add New Address',
                                onTap: () => _openAddressEditor(),
                              ),
                              const SizedBox(height: 32),
                              _buildPaymentHeader(),
                              const SizedBox(height: 18),
                              ...List.generate(
                                paymentController.options.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildPaymentCard(index),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: kEspressoColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'CONFIRM APPOINTMENT',
                style: AppFonts.inter(
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (_isBooking) const _BookingProgressOverlay(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final addresses = await LocalStorageService.loadAddresses();

    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    await LocalStorageService.saveAddresses(_addresses);
  }


  // ── Add-on helpers ──────────────────────────────────────────────────────────

  List<ServiceCartItem> get _addonServices =>
      widget.services.where((s) => s.serviceId != widget.serviceId).toList();

  double _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  String get _displayTotalPrice {
    if (widget.servicePrice.isEmpty) return '';
    final addons = _addonServices;
    if (addons.isEmpty) return widget.servicePrice;
    final base = _parsePrice(widget.servicePrice);
    final addonTotal = addons.fold<double>(
      0,
      (sum, a) => sum + _parsePrice(a.price),
    );
    final total = base + addonTotal;
    final symbol = widget.servicePrice.replaceAll(RegExp(r'[\d.,\s]'), '');
    final formatted = total.truncateToDouble() == total
        ? total.toInt().toString()
        : total.toStringAsFixed(2);
    return '$symbol$formatted';
  }

  // ────────────────────────────────────────────────────────────────────────────

  Future<BookingAddress?> _resolveBookingAddress(
    AddressModel addressModel,
  ) async {
    final line2Parts = addressModel.line2.split(',');
    final city = line2Parts.first.trim();
    final pincodeMatch = RegExp(r'\d{5,6}').firstMatch(addressModel.line2);

    var latitude = addressModel.latitude;
    var longitude = addressModel.longitude;

    if (latitude == 0.0 && longitude == 0.0) {
      try {
        final location = Location();
        final serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled && !(await location.requestService())) {
          throw Exception('Location service disabled');
        }

        var permissionStatus = await location.hasPermission();
        if (permissionStatus == PermissionStatus.denied) {
          permissionStatus = await location.requestPermission();
        }
        if (permissionStatus != PermissionStatus.granted) {
          throw Exception('Location permission denied');
        }

        final currentLocation = await location.getLocation().timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception('Location request timed out'),
        );
        latitude = currentLocation.latitude ?? 0.0;
        longitude = currentLocation.longitude ?? 0.0;
      } catch (error) {
        debugPrint('GPS resolution failed (proceeding without coords): $error');
      }
    }

    return BookingAddress(
      address: addressModel.line1,
      city: city.isEmpty ? 'Unknown' : city,
      pincode: pincodeMatch?.group(0) ?? '000000',
      latitude: latitude,
      longitude: longitude,
    );
  }

  String _to24Hour(String time) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([APMapm]{2})\s*$',
    ).firstMatch(time);
    if (match == null) return time;

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  // Future<void> _confirmAppointment() async {
  //   if (_addresses.isEmpty) return;

  //   final confirmed = await _showConfirmationSheet();
  //   if (!confirmed) return;

  //   // Validate that booking is not for today (API requirement)
  //   final today = DateTime.now();
  //   final todayDate = DateTime(today.year, today.month, today.day);
  //   final selectedDateParts = widget.selectedDateIso.split('-');
  //   final selectedDateOnly = DateTime(
  //     int.parse(selectedDateParts[0]),
  //     int.parse(selectedDateParts[1]),
  //     int.parse(selectedDateParts[2]),
  //   );

  //   setState(() => _isBooking = true);

  //   try {
  //     await _runBookingFlow();
  //   } catch (e) {
  //     debugPrint('Unexpected booking error: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Something went wrong. Please try again.'),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isBooking = false);
  //   }
  // }

  Future<void> _confirmAppointment() async {
    if (_addresses.isEmpty) return;

    final totalStr = _displayTotalPrice;

    if (totalStr.isNotEmpty &&
        paymentController.selected.type == PaymentOptionType.wallet) {
      final balance = _walletCtrl.wallet.value?.balance ?? 0;
      final total = _parsePrice(totalStr);

      if (balance < total) {
        if (!mounted) return;
        final splitConfirmed = await _showSplitPaymentSheet(balance, total);
        if (!splitConfirmed) return;
        final confirmed = await _showConfirmationSheet();
        if (!confirmed) return;
        setState(() => _isBooking = true);
        try {
          await _runBookingFlow();
        } catch (e) {
          debugPrint('Unexpected booking error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isBooking = false);
        }
        return;
      }
    }

    final confirmed = await _showConfirmationSheet();
    if (!confirmed) return;

    setState(() => _isBooking = true);

    try {
      await _runBookingFlow();
    } catch (e) {
      debugPrint('Unexpected booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Future<bool> _showConfirmationSheet() async {
    if (_addresses.isEmpty) return false;
    final address = _addresses[selectedAddressIndex];
    final serviceLabel = <String>[
      widget.serviceTitle,
      ..._addonServices.map((item) => item.title),
    ].join(', ');

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirm Booking',
              style: AppFonts.playfairDisplay(
                fontSize: 26,
                fontStyle: FontStyle.normal,
              ),
            ),
            const SizedBox(height: 20),
            _confirmRow(Icons.spa_outlined, 'Service', serviceLabel),
            if (widget.servicePrice.isNotEmpty)
              _confirmRow(
                Icons.payments_outlined,
                _addonServices.isEmpty ? 'Price' : 'Total Price',
                _displayTotalPrice,
              ),
            _confirmRow(
              Icons.calendar_today_outlined,
              'Date',
              widget.selectedDateDisplay,
            ),
            _confirmRow(
              Icons.access_time_outlined,
              'Time',
              widget.selectedTime,
            ),
            _confirmRow(Icons.location_on_outlined, 'Address', address.line1),
            _confirmRow(
              Icons.payment_outlined,
              'Payment',
              paymentController.isSplitPayment.value
                  ? 'Wallet + ${paymentController.splitOption.label.replaceAll('Pay Using ', '')}'
                  : paymentController.selected.label,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetCtx, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: kEspressoColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetCtx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kEspressoColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: AppFonts.inter(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result == true;
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kWarmGrey600),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: AppFonts.inter(fontSize: 13, color: kWarmGrey600),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kEspressoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runBookingFlow() async {
    final bookingAddress = await _resolveBookingAddress(
      _addresses[selectedAddressIndex],
    );
    if (bookingAddress == null) return;

    final addonIds = _addonServices.map((s) => s.serviceId).toList();
    final serviceIds = [widget.serviceId, ...addonIds];

    String? paymentMethod;
    double? walletAmount;
    if (paymentController.isSplitPayment.value) {
      paymentMethod = 'wallet';
      walletAmount = paymentController.walletAmount.value;
    } else {
      switch (paymentController.selected.type) {
        case PaymentOptionType.wallet:
          paymentMethod = 'wallet';
          walletAmount = _parsePrice(_displayTotalPrice);
          break;
        case PaymentOptionType.upi:
          paymentMethod = 'upi';
          break;
        case PaymentOptionType.onsite:
          paymentMethod = 'payOnSite';
          break;
      }
    }

    final response = await BookingService.createBooking(
      serviceIds: serviceIds,
      bookingDate: widget.selectedDateIso,
      bookingTime: _to24Hour(widget.selectedTime),
      locationType: 'home',
      address: bookingAddress,
      addonIds: addonIds.isEmpty ? null : addonIds,
      paymentMethod: paymentMethod,
      walletAmount: walletAmount,
    );

    if (!mounted) return;

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final totalStr = _displayTotalPrice;
    if (totalStr.isNotEmpty) {
      final total = _parsePrice(totalStr);
      final bookingId = response.booking?.id ?? 'booking-${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('BOOKING FLOW: paymentMethod=$paymentMethod isSplitPayment=${paymentController.isSplitPayment.value}');

      if (paymentController.isSplitPayment.value) {
        final remainingMethod = paymentController.splitOption.type;

        if (remainingMethod == PaymentOptionType.upi) {
          String? orderId = response.razorpayOrderId;
          debugPrint('SPLIT UPI: orderId from create response = $orderId');

          if (orderId == null) {
            debugPrint('SPLIT UPI: calling updatePartialPayment for UPI');
            final partialResponse = await BookingService.updatePartialPayment(
              bookingId: bookingId,
              remainingPaymentMethod: 'upi',
            );

            if (!partialResponse.success) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(partialResponse.message),
                  duration: const Duration(seconds: 4),
                ),
              );
              return;
            }

            orderId = partialResponse.razorpayOrderId ??
                partialResponse.booking?.razorpayOrderId ??
                partialResponse.partialPayment?['razorpayOrderId'] as String?;
            debugPrint('SPLIT UPI: orderId from updatePartialPayment = $orderId partialPayment=${partialResponse.partialPayment}');
          }

          if (orderId == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to get payment order ID. Please try again.'),
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }

          final paymentResult = await PaymentService.processPayment(
            paymentCtrl: paymentController,
            walletCtrl: _walletCtrl,
            totalAmount: total,
            bookingId: bookingId,
            serviceName: widget.serviceTitle,
            razorpayOrderId: orderId,
            context: context,
          );

          if (paymentResult != PaymentResult.success) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFFD32F2F),
                content: Text(
                  paymentResult == PaymentResult.cancelled
                      ? 'UPI payment was cancelled.'
                      : 'Payment failed. Please try again.',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }

          _walletCtrl.fetchWallet();
        } else {
          debugPrint('SPLIT ONSITE: calling updatePartialPayment for payOnSite');
          await BookingService.updatePartialPayment(
            bookingId: bookingId,
            remainingPaymentMethod: 'payOnSite',
          );
          _walletCtrl.fetchWallet();
        }
      } else if (paymentMethod == 'upi') {
        final orderId = response.razorpayOrderId;
        debugPrint('FULL UPI: orderId from create response = $orderId');

        if (orderId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Missing payment order ID from server.'),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        final paymentResult = await PaymentService.processPayment(
          paymentCtrl: paymentController,
          walletCtrl: null,
          totalAmount: total,
          bookingId: bookingId,
          serviceName: widget.serviceTitle,
          razorpayOrderId: orderId,
          context: context,
        );

        if (paymentResult != PaymentResult.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFD32F2F),
              content: Text(
                paymentResult == PaymentResult.cancelled
                    ? 'UPI payment was cancelled.'
                    : 'Payment failed. Please try again.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      } else if (paymentMethod == 'wallet') {
        _walletCtrl.fetchWallet();
      }
    }

    final status = (response.booking?.status ?? '').toLowerCase().trim();
    final isWaitingList = <String>{
      'pending',
      'waitlist',
      'waiting',
      'waiting_list',
      'queued',
      'queue',
    }.contains(status);

    final confirmedBooking = Booking(
      id: response.booking?.id.isNotEmpty == true
          ? response.booking!.id
          : 'local-${DateTime.now().millisecondsSinceEpoch}',
      title: response.booking?.title.isNotEmpty == true
          ? response.booking!.title
          : widget.serviceTitle,
      time: response.booking?.time.isNotEmpty == true
          ? response.booking!.time
          : widget.selectedTime,
      bookingDate: response.booking?.bookingDate.isNotEmpty == true
          ? response.booking!.bookingDate
          : widget.selectedDateIso,
      serviceId: response.booking?.serviceId.isNotEmpty == true
          ? response.booking!.serviceId
          : widget.serviceId,
      stylist: response.booking?.stylist.isNotEmpty == true
          ? response.booking!.stylist
          : (widget.stylist?.fullName ?? ''),
      image: response.booking?.image.isNotEmpty == true
          ? response.booking!.image
          : widget.serviceImage,
      status: response.booking?.status.isNotEmpty == true
          ? response.booking!.status
          : (isWaitingList ? 'pending' : 'confirmed'),
      jobId: response.booking?.jobId ?? '',
    );

    await AppointmentsSyncService.notifyBookingEvent(
      booking: confirmedBooking,
      isWaitingList: isWaitingList,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWaitingList
              ? 'Your booking request is on the waiting list.'
              : 'Appointment booked successfully.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => isWaitingList
            ? WaitingListScreen(
                response: response,
                serviceTitle: widget.serviceTitle,
                serviceImage: widget.serviceImage,
                selectedTime: widget.selectedTime,
                selectedDate: widget.selectedDateDisplay,
                stylistName: widget.stylist?.fullName,
                stylistImage: widget.stylist?.profileImage,
                stylistTag: widget.stylist != null
                    ? widget.stylist!.skills.isNotEmpty
                          ? widget.stylist!.skills.join(', ')
                          : 'Beautician'
                    : null,
              )
            : ConfirmationScreen(
                response: response,
                serviceTitle: widget.serviceTitle,
                serviceImage: widget.serviceImage,
                selectedTime: widget.selectedTime,
                selectedDate: widget.selectedDateDisplay,
                stylistName: widget.stylist?.fullName,
                stylistImage: widget.stylist?.profileImage,
                servicePrice: widget.servicePrice,
                stylistTag: widget.stylist != null
                    ? widget.stylist!.skills.isNotEmpty
                          ? widget.stylist!.skills.join(', ')
                          : 'Beautician'
                    : null,
              ),
      ),
      (route) => route.isFirst,
    );
  }


  Future<void> _openAddressEditor({AddressModel? address, int? index}) async {
    final result = await Navigator.push<EditResult<AddressModel>>(
      context,
      MaterialPageRoute(builder: (_) => EditAddressScreen(address: address)),
    );

    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        setState(() {
          _addresses.removeAt(index);
          selectedAddressIndex = _addresses.isEmpty
              ? 0
              : selectedAddressIndex.clamp(0, _addresses.length - 1);
        });
        await _saveAddresses();
      }
      return;
    }

    final savedAddress = result.item!;
    setState(() {
      if (index != null) {
        _addresses[index] = savedAddress;
      } else {
        _addresses.add(savedAddress);
        selectedAddressIndex = _addresses.length - 1;
      }
    });
    await _saveAddresses();
  }

  Future<bool> _showSplitPaymentSheet(double balance, double total) async {
    final f = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 0);
    final remainder = total - balance;

    paymentController.enableSplit(balance, total);

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kAccentGold.withAlpha(25),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 28,
                    color: kAccentGold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Split Payment',
                  style: AppFonts.playfairDisplay(
                    fontSize: 24,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Your wallet balance covers part of the total.',
                  textAlign: TextAlign.center,
                  style: AppFonts.inter(
                    fontSize: 13,
                    color: kWarmGrey600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWarmGrey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kEspressoColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay from Wallet',
                            style: AppFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kEspressoColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.format(balance),
                            style: AppFonts.inter(
                              fontSize: 13,
                              color: kWarmGrey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${f.format(balance)}',
                      style: AppFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kEspressoColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kWarmGrey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: kWarmGrey600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWarmGrey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kAccentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        paymentController.options[
                                paymentController.splitIndex.value]
                            .icon,
                        size: 18,
                        color: kAccentGold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remaining via',
                            style: AppFonts.inter(
                              fontSize: 11,
                              color: kWarmGrey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              paymentController.options.length,
                              (i) {
                                if (i == 0) return const SizedBox.shrink();
                                final active =
                                    paymentController.splitIndex.value == i;
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      paymentController.selectSplitMethod(i);
                                      setSheetState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? kEspressoColor
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                          color: active
                                              ? kEspressoColor
                                              : kWarmGrey200,
                                        ),
                                      ),
                                      child: Text(
                                        paymentController.options[i].label
                                            .replaceAll('Pay Using ', ''),
                                        style: AppFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: active
                                              ? Colors.white
                                              : kCharcoalColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${f.format(remainder)}',
                      style: AppFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kAccentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppFonts.inter(
                        fontSize: 13,
                        color: kWarmGrey600,
                      ),
                    ),
                    Text(
                      f.format(total),
                      style: AppFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kCharcoalColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: kEspressoColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kEspressoColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Confirm Split',
                        style: AppFonts.inter(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: kEspressoColor),
            ),
            const Spacer(),
            Text(
              'STEP 3 OF 3',
              style: AppFonts.inter(
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: kWarmGrey600,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: const _BookingStepBar(currentStep: 3),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Addresses',
          style: AppFonts.playfairDisplay(
            fontSize: 34,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your location for service',
          style: AppFonts.inter(fontSize: 13, color: kWarmGrey600, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAppointmentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: opacity(kEspressoColor, 0.1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Date',
                style: AppFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: kWarmGrey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.selectedDateDisplay,
                style: AppFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kEspressoColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Time',
                style: AppFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: kWarmGrey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.selectedTime,
                style: AppFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kEspressoColor,
                ),
              ),
            ],
          ),
          if (widget.servicePrice.isNotEmpty) ...[
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _addonServices.isEmpty ? 'Price' : 'Total Price',
                  style: AppFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: kWarmGrey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayTotalPrice,
                  style: AppFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kEspressoColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddonsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DFD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 14,
                color: Color(0xFFC3A76D),
              ),
              const SizedBox(width: 8),
              Text(
                'ADD-ONS',
                style: AppFonts.inter(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC3A76D),
                ),
              ),
              const Spacer(),
              Text(
                '${_addonServices.length} selected',
                style: AppFonts.inter(fontSize: 11, color: kWarmGrey600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._addonServices.map(
            (addon) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: addon.imageUrl.isNotEmpty
                          ? Image.network(
                              addon.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.spa_outlined,
                                size: 16,
                                color: Color(0xFFC3A76D),
                              ),
                            )
                          : const Icon(
                              Icons.spa_outlined,
                              size: 16,
                              color: Color(0xFFC3A76D),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      addon.title,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kEspressoColor,
                      ),
                    ),
                  ),
                  Text(
                    addon.price,
                    style: AppFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC3A76D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(int index) {
    final address = _addresses[index];
    final selected = selectedAddressIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedAddressIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? kEspressoColor : opacity(kEspressoColor, 0.08),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kWarmGrey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      address.label.toUpperCase().contains('OFFICE')
                          ? Icons.work_outline
                          : address.label.toUpperCase().contains('HOTEL')
                          ? Icons.hotel_outlined
                          : Icons.home_outlined,
                      size: 18,
                      color: kEspressoColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    address.label,
                    style: AppFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: kEspressoColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        _openAddressEditor(address: address, index: index),
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: kEspressoColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _addresses.removeAt(index);
                        selectedAddressIndex = _addresses.isEmpty
                            ? 0
                            : selectedAddressIndex.clamp(
                                0,
                                _addresses.length - 1,
                              );
                      });
                      await _saveAddresses();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: kEspressoColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                address.line1,
                style: AppFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kEspressoColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                address.line2,
                style: AppFonts.inter(fontSize: 13, color: kWarmGrey600),
              ),
              const SizedBox(height: 18),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: kChampagneColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        address.line2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.inter(
                          fontSize: 12,
                          color: kWarmGrey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: AppFonts.playfairDisplay(
            fontSize: 34,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred payment',
          style: AppFonts.inter(fontSize: 13, color: kWarmGrey600, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(int index) {
    final option = paymentController.options[index];
    final selected = paymentController.selectedIndex.value == index;

    return GestureDetector(
      onTap: () {
        paymentController.selectPayment(index);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? kEspressoColor : opacity(kEspressoColor, 0.1),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kWarmGrey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, size: 24, color: kEspressoColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: kEspressoColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: AppFonts.inter(
                        fontSize: 12,
                        color: kWarmGrey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kEspressoColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: opacity(kEspressoColor, 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kBackgroundLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: kEspressoColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kEspressoColor,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: kWarmGrey600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingStepBar extends StatelessWidget {
  const _BookingStepBar({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Service', 'Schedule', 'Confirm'];
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 1.5,
              color: i ~/ 2 < currentStep - 1
                  ? const Color(0xFFC5B38A)
                  : const Color(0xFFE8E5DF),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < currentStep - 1;
        final active = idx == currentStep - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? const Color(0xFFC5B38A)
                    : active
                    ? const Color(0xFF2C1A0E)
                    : const Color(0xFFF3F2F0),
              ),
              child: Center(
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : const Color(0xFF78716C),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              labels[idx],
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? const Color(0xFF2C1A0E)
                    : const Color(0xFF78716C),
                letterSpacing: 0.3,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BookingProgressOverlay extends StatelessWidget {
  const _BookingProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x38000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 44),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 48,
                  offset: Offset(0, 24),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(kEspressoColor),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Booking Your Appointment',
                  textAlign: TextAlign.center,
                  style: AppFonts.playfairDisplay(
                    fontSize: 22,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    color: kEspressoColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please wait while we confirm\nyour details',
                  textAlign: TextAlign.center,
                  style: AppFonts.inter(
                    fontSize: 13,
                    color: kWarmGrey600,
                    height: 1.65,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
