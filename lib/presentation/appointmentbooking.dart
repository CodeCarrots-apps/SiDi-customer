import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatelessWidget {
  ConfirmationScreen({super.key});

  final String service = "Signature Lavender Facial";
  final DateTime date = DateTime(2024, 10, 24, 14, 30);
  final String artist = "Elena Rodriguez";
  final String location = "Elite Spa, Beverly Hills";
  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM dd, yyyy').format(date);
    final timeFormatted = DateFormat('h:mm a').format(date);

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
              icon: Icon(Icons.close, color: Colors.black87),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 40,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    SizedBox(height: 16),

                    // Check Icon Circle
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFC5A059).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 36,
                        color: Color(0xFFC5A059),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Heading
                    Text(
                      "Confirmed",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Your time of indulgence is secured. We\n look forward to your arrival.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Service Section
                    Column(
                      children: [
                        Text(
                          "SERVICE",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Color(0xFFC5A059),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          service,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Date & Time Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "DATE",
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Color(0xFF6B6B6B),
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              dateFormatted,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xFFC5A059).withValues(alpha: 0.2),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Column(
                          children: [
                            Text(
                              "TIME",
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Color(0xFF6B6B6B),
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              timeFormatted,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Artist Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/women/69.jpg',
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          artist,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF6B6B6B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          location,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Map/Image Placeholder
                    Container(
                      height: 120,
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://maps.googleapis.com/maps/api/staticmap?center=Beverly+Hills&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7CBeverly+Hills',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Spacer(),

                    // Buttons
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.calendar_today_outlined, size: 18),
                            label: Text(
                              "ADD TO CALENDAR",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.5,
                              ),
                              foregroundColor: Color(0xFF1A1A1A),
                              side: BorderSide(color: Color(0xFF1A1A1A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              side: BorderSide(
                                color: Color(0xFFC5A059).withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              "VIEW DETAILS",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Color(0xFFC5A059),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "RETURN TO HOME",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Color(0xFF6B6B6B),
                                letterSpacing: 1,
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
}
