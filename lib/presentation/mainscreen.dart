import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidi/presentation/homescreen.dart';

final List<Widget> _tabs = <Widget>[
  const HomeScreen(),
  const _TabPlaceholder(title: 'Favorites'),
  const _TabPlaceholder(title: 'Add'),
  const _TabPlaceholder(title: 'Search'),
  const _TabPlaceholder(title: 'Profile'),
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
    return Scaffold(
      extendBody: true,
      body: _tabs[_selectedTab],
      bottomNavigationBar: GNav(
        selectedIndex: _selectedTab,
        onTabChange: _handleIndexChanged,
        gap: 8,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.black.withOpacity(0.5),
        color: Colors.white70,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.black.withOpacity(0.2),
        tabs: const [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.favorite, text: 'Favorites'),
          GButton(icon: Icons.add, text: 'Add'),
          GButton(icon: Icons.search, text: 'Search'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
