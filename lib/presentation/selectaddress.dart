import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/models/stylist.dart';

import 'confirmationscreen.dart';
import 'waitinglistscreen.dart';

import '../models/address_model.dart';
import '../models/booking_models.dart';
import '../models/edit_result.dart';
import '../models/payment_method_model.dart';
import '../models/booking.dart';
import '../services/local_storage_service.dart';
import '../services/service_cart_service.dart';
import 'edit_address_screen.dart';
import 'edit_payment_method_screen.dart';

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
  int selectedAddressIndex = 0;
  int selectedPaymentIndex = 0;
  bool _isLoading = true;
  bool _isBooking = false;

  List<AddressModel> _addresses = [];
  List<PaymentMethodModel> _paymentMethods = [];

  List<ServiceCartItem> get _selectedServices {
    if (widget.services.isNotEmpty) {
      return widget.services;
    }

    return [
      ServiceCartItem(
        serviceId: widget.serviceId,
        title: widget.serviceTitle,
        price: widget.servicePrice,
        duration: '',
        imageUrl: widget.serviceImage,
        beauticianId: widget.beauticianId,
      ),
    ];
  }

  String get _serviceSummaryTitle {
    final items = _selectedServices;
    if (items.isEmpty) {
      return widget.serviceTitle;
    }
    if (items.length == 1) {
      return items.first.title;
    }
    return '${items.first.title} + ${items.length - 1} more';
  }

  String get _serviceCountLabel {
    final count = _selectedServices.length;
    return count == 1 ? '1 service' : '$count services';
  }

  String get _servicePriceLabel {
    final items = _selectedServices;
    if (items.length == 1 && items.first.price.isNotEmpty) {
      return items.first.price;
    }

    var total = 0.0;
    var parsedCount = 0;
    for (final item in items) {
      final numeric = double.tryParse(
        item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (numeric != null) {
        total += numeric;
        parsedCount++;
      }
    }

    if (parsedCount == items.length && parsedCount > 0) {
      return 'AED ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)}';
    }

    return widget.servicePrice;
  }

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
                                _paymentMethods.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildPaymentCard(index),
                                ),
                              ),
                              _buildAddTile(
                                icon: Icons.add,
                                label: 'Add New Payment',
                                onTap: () => _openPaymentEditor(),
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
                style: GoogleFonts.inter(
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
    final payments = await LocalStorageService.loadPaymentMethods();

    setState(() {
      _addresses = addresses.isNotEmpty ? addresses : _defaultAddresses();
      _paymentMethods = payments.isNotEmpty
          ? payments
          : _defaultPaymentMethods();
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    await LocalStorageService.saveAddresses(_addresses);
  }

  Future<void> _savePaymentMethods() async {
    await LocalStorageService.savePaymentMethods(_paymentMethods);
  }

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
        // Don't block the booking — proceed with 0.0 coords
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

    if (period == 'PM' && hour < 12) {
      hour += 12;
    }
    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  Future<void> _confirmAppointment() async {
    if (_addresses.isEmpty) return;

    final confirmed = await _showConfirmationSheet();
    if (!confirmed) return;

    setState(() {
      _isBooking = true;
    });

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
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationSheet() async {
    if (_addresses.isEmpty) return false;
    final address = _addresses[selectedAddressIndex];
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
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _confirmRow(Icons.spa_outlined, 'Service', _serviceSummaryTitle),
            if (_selectedServices.length > 1)
              _confirmRow(
                Icons.shopping_bag_outlined,
                'Included',
                _serviceCountLabel,
              ),
            if (_servicePriceLabel.isNotEmpty)
              _confirmRow(Icons.payments_outlined, 'Price', _servicePriceLabel),
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
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(fontSize: 13, color: kWarmGrey600),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
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
    final primaryService = _selectedServices.first;

    // Build and save a local booking immediately.
    final localBooking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _serviceSummaryTitle,
      time: _to24Hour(widget.selectedTime),
      bookingDate: widget.selectedDateIso,
      serviceId: primaryService.serviceId,
      stylist: widget.stylist?.fullName ?? '',
      image: primaryService.imageUrl,
      status: 'pending',
    );
    await LocalStorageService.addCachedBooking(localBooking);
    debugPrint('Booking saved locally: id=${localBooking.id}');

    // Simulate processing for 15 seconds.
    await Future.delayed(const Duration(seconds: 15));

    if (!mounted) return;

    final response = BookingCreateResponse(
      success: true,
      message: 'Appointment booked successfully.',
      booking: localBooking,
    );

    final status = (response.booking?.status ?? '').toLowerCase().trim();
    final isWaitingList = <String>{
      'pending',
      'waitlist',
      'waiting',
      'waiting_list',
      'queued',
      'queue',
    }.contains(status);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWaitingList
              ? 'Your booking request is on the waiting list.'
              : 'Appointment booked successfully.',
        ),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isWaitingList
            ? WaitingListScreen(
                response: response,
                serviceTitle: _serviceSummaryTitle,
                serviceImage: primaryService.imageUrl,
                selectedTime: widget.selectedTime,
                selectedDate: widget.selectedDateDisplay,
                stylistName: widget.stylist?.fullName,
                stylistImage: widget.stylist?.profileImage,
                services: _selectedServices,
                stylistTag: widget.stylist != null
                    ? widget.stylist!.skills.isNotEmpty
                          ? widget.stylist!.skills.join(', ')
                          : 'Beautician'
                    : null,
              )
            : ConfirmationScreen(
                response: response,
                serviceTitle: _serviceSummaryTitle,
                serviceImage: primaryService.imageUrl,
                selectedTime: widget.selectedTime,
                selectedDate: widget.selectedDateDisplay,
                stylistName: widget.stylist?.fullName,
                stylistImage: widget.stylist?.profileImage,
                servicePrice: _servicePriceLabel,
                services: _selectedServices,
                stylistTag: widget.stylist != null
                    ? widget.stylist!.skills.isNotEmpty
                          ? widget.stylist!.skills.join(', ')
                          : 'Beautician'
                    : null,
              ),
      ),
    );

    if (widget.services.isNotEmpty) {
      await ServiceCartService.clearCart();
    }
  }

  List<AddressModel> _defaultAddresses() {
    return [
      AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'HOME',
        line1: '123 Elegant Ave, Penthouse 4B',
        line2: 'New York, NY 10012',
      ),
      AddressModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        label: 'OFFICE',
        line1: '456 Corporate Plaza, Suite 200',
        line2: 'Manhattan, NY 10001',
      ),
    ];
  }

  List<PaymentMethodModel> _defaultPaymentMethods() {
    return [
      PaymentMethodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'Apple Pay',
        details: '',
        brand: 'apple',
      ),
      PaymentMethodModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        label: 'Visa ending in 4242',
        details: '',
        brand: 'visa',
      ),
      PaymentMethodModel(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        label: 'Cash Onsite',
        details: 'Pay cash at appointment',
        brand: 'cash',
      ),
    ];
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

  Future<void> _openPaymentEditor({
    PaymentMethodModel? paymentMethod,
    int? index,
  }) async {
    final result = await Navigator.push<EditResult<PaymentMethodModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPaymentMethodScreen(paymentMethod: paymentMethod),
      ),
    );

    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        setState(() {
          _paymentMethods.removeAt(index);
          selectedPaymentIndex = _paymentMethods.isEmpty
              ? 0
              : selectedPaymentIndex.clamp(0, _paymentMethods.length - 1);
        });
        await _savePaymentMethods();
      }
      return;
    }

    final savedMethod = result.item!;
    setState(() {
      if (index != null) {
        _paymentMethods[index] = savedMethod;
      } else {
        _paymentMethods.add(savedMethod);
        selectedPaymentIndex = _paymentMethods.length - 1;
      }
    });
    await _savePaymentMethods();
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
              style: GoogleFonts.inter(
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
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your location for service',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: kWarmGrey600,
            height: 1.5,
          ),
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
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: kWarmGrey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.selectedDateDisplay,
                style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: kWarmGrey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.selectedTime,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kEspressoColor,
                ),
              ),
            ],
          ),
          if (_servicePriceLabel.isNotEmpty) ...[
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: kWarmGrey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _servicePriceLabel,
                  style: GoogleFonts.inter(
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
          boxShadow: [
            const BoxShadow(
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
                    style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kEspressoColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                address.line2,
                style: GoogleFonts.inter(fontSize: 13, color: kWarmGrey600),
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
                        style: GoogleFonts.inter(
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
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred payment',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: kWarmGrey600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(int index) {
    final payment = _paymentMethods[index];
    final selected = selectedPaymentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedPaymentIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? kEspressoColor : opacity(kEspressoColor, 0.1),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x08000000),
              blurRadius: 12,
              offset: const Offset(0, 8),
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
                child: Icon(payment.icon, size: 24, color: kEspressoColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  payment.label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kEspressoColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    _openPaymentEditor(paymentMethod: payment, index: index),
                icon: const Icon(Icons.edit, size: 18, color: kEspressoColor),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    _paymentMethods.removeAt(index);
                    selectedPaymentIndex = _paymentMethods.isEmpty
                        ? 0
                        : selectedPaymentIndex.clamp(
                            0,
                            _paymentMethods.length - 1,
                          );
                  });
                  await _savePaymentMethods();
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: kEspressoColor,
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
                  style: GoogleFonts.inter(
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withValues(alpha: 0.22),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 44),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: kEspressoColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please wait while we confirm\nyour details',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
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
      ),
    );
  }
}
