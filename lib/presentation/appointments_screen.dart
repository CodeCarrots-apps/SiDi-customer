import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR SCHEDULE',
                    style: GoogleFonts.inter(
                      fontSize: 9 * scale,
                      letterSpacing: 1.6,
                      color: kWarmGrey600,
                    ),
                  ),
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
                  _buildRecentAppointment(
                    image:
                        'https://images.unsplash.com/photo-1632345031435-8727f6897d53?auto=format&fit=crop&w=400&q=80',
                    title: 'Signature Silk Manicure',
                    time: 'Thursday, 12 Oct • 14:30',
                    stylist: 'STYLIST: ELENA ROSSI',
                    scale: scale,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildRecentAppointment(
                    image:
                        'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?auto=format&fit=crop&w=400&q=80',
                    title: 'Botanical Facial',
                    time: 'Monday, 16 Oct • 10:00',
                    stylist: 'STYLIST: MARCUS THORNE',
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  _buildSectionLabel('EARLIER', scale),
                  SizedBox(height: 6 * scale),
                  Divider(color: kWarmGrey200, height: 1),
                  SizedBox(height: 10 * scale),
                  _buildEarlierAppointment(
                    image: 'https://randomuser.me/api/portraits/women/58.jpg',
                    title: 'Scalp Therapy',
                    subtitle: 'Sep 24 • Sophie Chen',
                    scale: scale,
                  ),
                  _buildEarlierAppointment(
                    image:
                        'https://i.pinimg.com/736x/51/3a/3f/513a3f7e18e59884df9070a6c09a91b2.jpg',
                    title: 'Deep Lash Tint',
                    subtitle: 'Aug 30 • Elena Rossi',
                    scale: scale,
                  ),
                  _buildEarlierAppointment(
                    image:
                        'https://i.pinimg.com/736x/52/20/c1/5220c1ff75f0308e6b6c2064d77f69aa.jpg',
                    title: 'Precision Brows',
                    subtitle: 'Aug 02 • Marcus Thorne',
                    scale: scale,
                  ),
                ],
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
