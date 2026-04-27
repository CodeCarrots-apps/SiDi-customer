// AppointmentCard Widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class AppointmentCard extends StatelessWidget {
  final String imageUrl;
  final String status;
  final String title;
  final String artist;
  final String time;
  final String price;
  final Color accentColor;

  const AppointmentCard({
    super.key,
    required this.imageUrl,
    required this.status,
    required this.title,
    required this.artist,
    required this.time,
    required this.price,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Colors are provided by lib/constant/constants.dart
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kWarmGrey100),
        boxShadow: [
          BoxShadow(
            color: opacity(Colors.black, 0.05),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: kSlate950,
                        ),
                      ),
                      Text(
                        artist,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: kWarmGrey600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: kWarmGrey600),
                          SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kSlate950,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.payments, size: 16, color: kWarmGrey600),
                          SizedBox(width: 4),
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kSlate950,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: kWarmGrey50),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment declined.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    "Decline",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: kWarmGrey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment confirmed!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    "Confirm",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: kSlate950,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
