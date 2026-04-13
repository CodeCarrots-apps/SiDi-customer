import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarmGrey50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kWarmGrey50,
            surfaceTintColor: kWarmGrey50,
            centerTitle: true,
            title: Text(
              'ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
                color: kCharcoalColor,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildStatStrip()),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'MANAGEMENT',
              items: const [
                _ProfileItemData(Icons.calendar_month_outlined, 'My Bookings'),
                _ProfileItemData(
                  Icons.credit_card_outlined,
                  'Payments & Billing',
                ),
                _ProfileItemData(
                  Icons.auto_awesome_outlined,
                  'Favorite Stylists',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'APPLICATION',
              items: const [
                _ProfileItemData(Icons.tune, 'Settings'),
                _ProfileItemData(Icons.help_outline, 'Support Center'),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 120),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  side: BorderSide(color: kWarmGrey200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                    color: kAccentGold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFC9BDAF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                'https://randomuser.me/api/portraits/women/44.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Isabella Sterling',
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontStyle: FontStyle.italic,
              color: kCharcoalColor,
              height: 0.9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Gold Member',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              color: kAccentGold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'MEMBER SINCE 2022',
            style: GoogleFonts.inter(
              fontSize: 10,
              letterSpacing: 3,
              color: kWarmGrey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kWarmGrey200),
          bottom: BorderSide(color: kWarmGrey200),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _statCell('12', 'BOOKINGS')),
          Expanded(child: _statCell('4', 'REVIEWS')),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            color: kCharcoalColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 3,
            color: kAccentGold,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<_ProfileItemData> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 4,
                color: kAccentGold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(_buildSectionRow),
        ],
      ),
    );
  }

  Widget _buildSectionRow(_ProfileItemData item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kWarmGrey200)),
      ),
      child: ListTile(
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(item.icon, size: 18, color: kWarmGrey600),
        title: Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: kCharcoalColor,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: kWarmGrey200, size: 18),
        onTap: () {},
      ),
    );
  }
}

class _ProfileItemData {
  const _ProfileItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}
