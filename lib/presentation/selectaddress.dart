import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import '../models/address_model.dart';
import '../models/edit_result.dart';
import '../models/payment_method_model.dart';
import '../services/local_storage_service.dart';
import 'edit_address_screen.dart';
import 'edit_payment_method_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
  });

  final String selectedDate;
  final String selectedTime;

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  int selectedAddressIndex = 0;
  int selectedPaymentIndex = 0;
  bool _isLoading = true;

  List<AddressModel> _addresses = [];
  List<PaymentMethodModel> _paymentMethods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: kEspressoColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Text(
            'CONFIRM & PAY',
            style: GoogleFonts.inter(
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: kEspressoColor),
        ),
        const Spacer(),

        const Spacer(),
        const SizedBox(width: 42),
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
                widget.selectedDate,
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
                    child: const Icon(
                      Icons.home,
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
                height: 118,
                decoration: BoxDecoration(
                  color: kWarmGrey50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.location_on, size: 32, color: kWarmGrey600),
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
