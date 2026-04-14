import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidi/presentation/appointments_screen.dart';
import 'package:sidi/presentation/bookingscreen.dart';
import 'package:sidi/presentation/homescreen.dart';
import 'package:sidi/presentation/profilescreen.dart';
import 'package:sidi/presentation/stylistlistscreen.dart';

final List<Widget> _tabs = <Widget>[
  const HomeScreen(),
  const BookingScreen(),
  const StylistListScreen(),
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
      body: _tabs[_selectedTab],
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          compactNav ? 6 : 12,
          0,
          compactNav ? 6 : 12,
          10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GNav(
            selectedIndex: _selectedTab,
            onTabChange: _handleIndexChanged,
            gap: compactNav ? 4 : 8,
            padding: EdgeInsets.symmetric(
              horizontal: compactNav ? 12 : 20,
              vertical: compactNav ? 14 : 16,
            ),
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            color: Colors.white70,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black.withValues(alpha: 0.2),
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.calendar_today, text: 'Book'),
              GButton(icon: Icons.cut_outlined, text: 'Stylists'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
