import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kEspressoColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add Address',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kEspressoColor,
          ),
        ),
      ),
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(label: 'Label', controller: _labelController),
              const SizedBox(height: 16),
              _buildField(label: 'Address', controller: _line1Controller),
              const SizedBox(height: 16),
              _buildField(label: 'City / State', controller: _line2Controller),
              const Spacer(),
              Row(
                children: [
                  if (isEditing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: kEspressoColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size.fromHeight(54),
                        ),
                        child: Text(
                          'DELETE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: kEspressoColor,
                          ),
                        ),
                      ),
                    ),
                  if (isEditing) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kEspressoColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: Text(
                        'SAVE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            letterSpacing: 1.5,
            color: kWarmGrey600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: opacity(kEspressoColor, 0.1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}
