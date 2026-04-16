import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/edit_result.dart';
import '../models/payment_method_model.dart';
import '../constant/constants.dart';

class EditPaymentMethodScreen extends StatefulWidget {
  const EditPaymentMethodScreen({super.key, this.paymentMethod});

  final PaymentMethodModel? paymentMethod;

  @override
  State<EditPaymentMethodScreen> createState() =>
      _EditPaymentMethodScreenState();
}

class _EditPaymentMethodScreenState extends State<EditPaymentMethodScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _detailsController;
  late final TextEditingController _brandController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.paymentMethod?.label ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.paymentMethod?.details ?? '',
    );
    _brandController = TextEditingController(
      text: widget.paymentMethod?.brand ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailsController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  void _save() {
    final method = PaymentMethodModel(
      id:
          widget.paymentMethod?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim().isEmpty
          ? 'Payment method'
          : _labelController.text.trim(),
      details: _detailsController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? 'other'
          : _brandController.text.trim(),
    );
    Navigator.pop(context, EditResult<PaymentMethodModel>(item: method));
  }

  void _delete() {
    Navigator.pop(context, const EditResult<PaymentMethodModel>(deleted: true));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentMethod != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kEspressoColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Payment' : 'Add Payment',
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
              _buildField(label: 'Method Label', controller: _labelController),
              const SizedBox(height: 16),
              _buildField(label: 'Details', controller: _detailsController),
              const SizedBox(height: 16),
              _buildField(
                label: 'Brand (visa/apple/other)',
                controller: _brandController,
              ),
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
