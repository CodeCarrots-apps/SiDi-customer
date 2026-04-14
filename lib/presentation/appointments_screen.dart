import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = BookingService.fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);

    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            centerTitle: true,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              10 * scale,
              16 * scale,
              24 * scale,
            ),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder<List<Booking>>(
                future: _futureBookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load bookings'));
                  }
                  final bookings = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6 * scale),
                      Text(
                        'Appointments',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 36 * scale,
                          fontStyle: FontStyle.italic,
                          color: kCharcoalColor,
                        ),
                      ),
                      SizedBox(height: 22 * scale),
                      _buildSectionLabel('RECENT', scale),
                      SizedBox(height: 6 * scale),
                      Divider(color: kWarmGrey200, height: 1),
                      SizedBox(height: 12 * scale),
                      ...bookings
                          .take(2)
                          .map(
                            (b) => Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: _buildRecentAppointment(
                                image: b.image.isNotEmpty
                                    ? b.image
                                    : 'https://via.placeholder.com/66x78',
                                title: b.title,
                                time: b.time,
                                stylist: b.stylist,
                                scale: scale,
                              ),
                            ),
                          ),
                      SizedBox(height: 18 * scale),
                      _buildSectionLabel('EARLIER', scale),
                      SizedBox(height: 6 * scale),
                      Divider(color: kWarmGrey200, height: 1),
                      SizedBox(height: 10 * scale),
                      ...bookings
                          .skip(2)
                          .map(
                            (b) => _buildEarlierAppointment(
                              image: b.image.isNotEmpty
                                  ? b.image
                                  : 'https://via.placeholder.com/38',
                              title: b.title,
                              subtitle: b.stylist,
                              scale: scale,
                            ),
                          ),
                      if (bookings.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 24 * scale),
                          child: Center(child: Text(' ')),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: kCharcoalColor,
      ),
    );
  }

  Widget _buildRecentAppointment({
    required String image,
    required String title,
    required String time,
    required String stylist,
    required double scale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            image,
            width: 66 * scale,
            height: 78 * scale,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24 * scale,
                  fontStyle: FontStyle.italic,
                  color: kCharcoalColor,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 11 * scale,
                  color: kWarmGrey600,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                stylist,
                style: GoogleFonts.inter(
                  fontSize: 9 * scale,
                  letterSpacing: 1.6,
                  color: kWarmGrey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarlierAppointment({
    required String image,
    required String title,
    required String subtitle,
    required double scale,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              image,
              width: 38 * scale,
              height: 38 * scale,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24 * scale,
                    fontStyle: FontStyle.italic,
                    color: kCharcoalColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10 * scale,
                    color: kWarmGrey600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: kCharcoalColor,
              side: BorderSide(color: kWarmGrey200),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 7 * scale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'REBOOK',
              style: GoogleFonts.inter(
                fontSize: 9 * scale,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
