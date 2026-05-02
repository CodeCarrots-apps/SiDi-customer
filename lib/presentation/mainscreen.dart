import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidi/presentation/bookingscreen.dart';
import 'package:sidi/presentation/homescreen.dart';
import 'package:sidi/presentation/profilescreen.dart';
import 'package:sidi/presentation/stylistlistscreen.dart';

final List<Widget> _tabs = <Widget>[
  const HomeScreen(),
  const BookingScreen(),
  StylistListScreen(),
  const ProfileScreen(),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;

  void _handleIndexChanged(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTab = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compactNav = screenWidth < 400;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedTab, children: _tabs),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          compactNav ? 6 : 12,
          0,
          compactNav ? 6 : 12,
          10,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFFF7F2EA), Color(0xFFEEE3D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2217110B),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: GNav(
              selectedIndex: _selectedTab,
              onTabChange: _handleIndexChanged,
              gap: compactNav ? 4 : 8,
              padding: EdgeInsets.symmetric(
                horizontal: compactNav ? 12 : 18,
                vertical: compactNav ? 13 : 15,
              ),
              backgroundColor: Colors.transparent,
              color: const Color(0xFF6B645C),
              activeColor: const Color(0xFF2A2622),
              tabBackgroundColor: const Color(0xFFFDF8F2),
              rippleColor: const Color(0xFFE7DDCF),
              hoverColor: const Color(0xFFF3EADD),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.calendar_today_rounded, text: 'Book'),
                GButton(icon: Icons.content_cut_rounded, text: 'Stylists'),
                GButton(icon: Icons.person_rounded, text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
