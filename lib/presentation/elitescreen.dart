import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/widgets/appointmentcard.dart';

class EliteArtistScreen extends StatelessWidget {
  const EliteArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors are provided by lib/constant/constants.dart
    return Scaffold(
      backgroundColor: kWarmGrey50,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: kWarmGrey50,
                  surfaceTintColor: kWarmGrey50,
                  titleSpacing: 16,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuBHaDIAAD6m-EMinJRwSG4QPlY-ZmrbdKJD9_HFoZhudnBXatqdY1qOclt84uVEsLW8bDc1mf_lfAUVKEcQQqgdW2Aswvs3x7aHh3DXeX564jpktBP3L_dv6F3I5JHY5pObcoz6Q4i2lrGR932NxCY2v8jtS_3XZPm97YI0-D_Mn4VW4yYeEiMa3JAL8B8wcOHZ5W7Yxt8c5x9Hwea2ZwiWn1EKdwWFi89EHbXtn7tfM4IUtB4_b_dPQ-1tvWkaWSTmFv7VultwGrU",
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Senior Artist",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: kWarmGrey600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            "Elena Rossi",
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: kSlate950,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search, size: 24),
                      color: kSlate950,
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications, size: 24),
                          color: kSlate950,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: kAccentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        // Cards Grid
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Daily Performance
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Color(0xFFFCFBF9)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: kWarmGrey200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: opacity(Colors.black, 0.05),
                                      blurRadius: 30,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Daily Performance",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: kWarmGrey600,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          "+14.2%",
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: kAccentGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\$1,840.00",
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w500,
                                            color: kSlate950,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 24,
                                              color: kWarmGrey200,
                                            ),
                                            Container(
                                              width: 4,
                                              height: 36,
                                              color: kWarmGrey200,
                                            ),
                                            Container(
                                              width: 4,
                                              height: 30,
                                              color: kWarmGrey200,
                                            ),
                                            Container(
                                              width: 4,
                                              height: 54,
                                              color: kAccentGold,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              // Bookings
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bookings",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                        color: kWarmGrey600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "12",
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 24,
                                            color: kSlate950,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "/ 14 slots",
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: kWarmGrey600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              // Waitlist
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: kWarmGrey100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 30,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Waitlist",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                        color: kWarmGrey600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "4",
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 24,
                                            color: kSlate950,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "VIP requests",
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: kWarmGrey600,
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
                        SizedBox(height: 16),

                        // Today's Appointments
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Today's Appointments",
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 22,
                                      fontStyle: FontStyle.italic,
                                      color: kSlate950,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Thursday, October 24",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: kWarmGrey600,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Edit Schedule",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: kAccentGold,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        // Example Appointment Card
                        AppointmentCard(
                          imageUrl:
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuCrubJ9XTCITjRwL8IbYUkphPd7eFm-eX1cIZk-98QH7BFmfQNJPrntJ1CwYFvrjBJ6ysCMFGyjhgy0BpoSZUkxd__xT5zSBFkBAi3I6emZ0ePByFjpWuqVyw6rO8_Xdf68I9rqfNio-RHwSSZhYhZ9b1BJvswebZoDvVQQpjdC2chikzEMubbRjM3YQEdAjW_ixtG0uGoXM5rKa7ShbyKj499MRzLlyHru7jI2PnzhYUm9f-R2-fWtpgPIYHoJ0mtS8WtHqnhfUno",
                          status: "New Request",
                          title: "Luxury Facial",
                          artist: "with Sarah Jenkins",
                          time: "10:00 - 11:30",
                          price: "\$210",
                          accentColor: kAccentGold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Navigation
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: kSlate950.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.grid_view, color: kAccentGold),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: kAccentGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: kWarmGrey50, width: 4),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.group,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.account_circle,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
