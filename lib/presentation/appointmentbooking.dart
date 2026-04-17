import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sidi/models/booking_models.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.service,
    required this.response,
  });

  final String service;
  final BookingCreateResponse response;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  void _retry() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.response;
    if (!response.success) {
      return _buildError(
        message: response.message,
        context: context,
        showClose: true,
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 36,
                        color: Color(0xFFC5A059),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Confirmed",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        response.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B6B6B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        Text(
                          "SERVICE",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFFC5A059),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.service,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Booking ID',
                            response.booking?.id ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Status',
                            response.booking?.status ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Job ID',
                            response.booking?.id ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Price',
                            '₹${response.estimatedPrice ?? 0}',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Travel Fee',
                            '₹${response.travelFee ?? 0}',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Addons',
                            '₹${response.addonsAmount ?? 0}',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Broadcasted Count',
                            '${response.broadcastedCount ?? 0}',
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xFFC5A059),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              "RETURN TO HOME",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _retry,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: BorderSide(
                                color: const Color(
                                  0xFFC5A059,
                                ).withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              "BOOK AGAIN",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: const Color(0xFFC5A059),
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
          ),
        ],
      ),
    );
  }

  Widget _buildError({
    required String message,
    required BuildContext context,
    bool showClose = true,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showClose)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                Text(
                  'Booking failed',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retry,
                  child: Text(
                    'Retry',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
