import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:location/location.dart';
import 'package:sidi/constant/app_fonts.dart';

import '../models/address_model.dart';
import '../models/edit_result.dart';
import '../constant/constants.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key, this.address});

  final AddressModel? address;

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  final Dio _dio = Dio();
  final Location _location = Location();

  bool _isFetchingLocation = false;
  String? _locationErrorText;

  static const List<String> _addressLabels = ['HOME', 'WORK', 'HOTEL', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.address?.label ?? 'HOME',
    );
    _line1Controller = TextEditingController(text: widget.address?.line1 ?? '');
    _line2Controller = TextEditingController(text: widget.address?.line2 ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    super.dispose();
  }

  void _save() {
    final savedAddress = AddressModel(
      id:
          widget.address?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim().isEmpty
          ? 'HOME'
          : _labelController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
    );
    Navigator.pop(context, EditResult<AddressModel>(item: savedAddress));
  }

  void _delete() {
    Navigator.pop(context, const EditResult<AddressModel>(deleted: true));
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationErrorText = null;
    });

    try {
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location service is turned off on this device.');
        }
      }

      var permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
      }

      if (permissionStatus != PermissionStatus.granted &&
          permissionStatus != PermissionStatus.grantedLimited) {
        throw Exception(
          permissionStatus == PermissionStatus.deniedForever
              ? 'Location permission is permanently denied. Enable it from app settings.'
              : 'Location permission denied. Please allow location access.',
        );
      }

      final currentLocation = await _location.getLocation().timeout(
        const Duration(seconds: 12),
      );

      final lat = currentLocation.latitude;
      final lon = currentLocation.longitude;
      if (lat == null || lon == null) {
        throw Exception('Unable to fetch current coordinates');
      }

      var address = '';

      try {
        final response = await _dio.get(
          'https://sidi.mobilegear.co.in/api/mobileapp/services/location',
          queryParameters: {'lat': lat, 'lng': lon},
        );

        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final locationData = data['location'] as Map<String, dynamic>?;
          address = (locationData?['address'] as String?)?.trim() ?? '';
        }
      } catch (_) {
        // Fall back to reverse geocoding when the primary location API fails.
      }

      if (address.isEmpty) {
        final reverseResponse = await _dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {'lat': lat, 'lon': lon, 'format': 'jsonv2'},
          options: Options(
            headers: {
              'User-Agent': 'SiDiCustomerApp/1.0 (edit-address)',
              'Accept-Language': 'en',
            },
          ),
        );

        final reverseData = reverseResponse.data as Map<String, dynamic>;
        address = (reverseData['display_name'] as String?)?.trim() ?? '';
      }

      if (address.isEmpty) {
        throw Exception(
          'Could not resolve a readable address from your location.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isFetchingLocation = false;
        _line2Controller.text = address;
      });
    } catch (error) {
      debugPrint('Current location fetch failed: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _isFetchingLocation = false;
        _locationErrorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  bool get _canSave => _line1Controller.text.trim().isNotEmpty;

  void _pickLabel(String label) {
    setState(() {
      _labelController.text = label;
    });
  }

  String get _normalizedLabel {
    final value = _labelController.text.trim().toUpperCase();
    if (_addressLabels.contains(value)) {
      return value;
    }
    return 'OTHER';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
    final selectedLabel = _normalizedLabel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kEspressoColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add Address',
          style: AppFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kEspressoColor,
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: _delete,
              child: Text(
                'DELETE',
                style: AppFonts.inter(
                  color: const Color(0xFFE23744),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Address Details' : 'Add New Address',
                      style: AppFonts.playfairDisplay(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: kEspressoColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update where your service should reach',
                      style: AppFonts.inter(
                        fontSize: 13,
                        color: kWarmGrey600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: opacity(kEspressoColor, 0.1)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter Complete Address',
                                  style: AppFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: kEspressoColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your order will be delivered to this location',
                                  style: AppFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: kWarmGrey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isFetchingLocation
                            ? null
                            : _fetchCurrentLocation,
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _isFetchingLocation
                              ? 'Fetching Current Location...'
                              : 'Use Current Location',
                          style: AppFonts.inter(
                            fontSize: 13,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kEspressoColor,
                          side: BorderSide(color: opacity(kEspressoColor, 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    if (_locationErrorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _locationErrorText!,
                        style: AppFonts.inter(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'SAVE ADDRESS AS',
                      style: AppFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kWarmGrey600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _addressLabels
                          .map(
                            (label) => _buildAddressTypeChip(
                              label: label,
                              selected: label == selectedLabel,
                              onTap: () => _pickLabel(label),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: opacity(kEspressoColor, 0.08),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 14,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildField(
                            label: 'HOUSE / FLAT / BLOCK NO.',
                            hint: 'E.g. 221B, Green Residency',
                            controller: _line1Controller,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            label: 'AREA / STREET / CITY',
                            hint: 'E.g. MG Road, Bengaluru',
                            controller: _line2Controller,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: opacity(kEspressoColor, 0.08)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    disabledBackgroundColor: const Color(0xFFF4C9A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(54),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'SAVE CHANGES' : 'SAVE ADDRESS',
                    style: AppFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTypeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF2E5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF7A00) : const Color(0xFFE9E7E4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppFonts.inter(
            color: selected ? const Color(0xFFFF7A00) : kWarmGrey600,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.inter(
            fontSize: 10,
            letterSpacing: 1.2,
            color: kWarmGrey600,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: AppFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kEspressoColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.inter(
              color: opacity(kWarmGrey600, 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: opacity(kEspressoColor, 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: opacity(kEspressoColor, 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF7A00),
                width: 1.4,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
