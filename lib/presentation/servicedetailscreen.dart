import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'timeslotscreen.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  // Colors are provided by lib/constant/constants.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: Stack(
        children: [
          _buildContent(),
          _buildTopNav(),
        ],
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 20),
                _buildInfoRow(),
                const SizedBox(height: 28),
                _buildDescription(),
                const SizedBox(height: 40),
                _buildFeatures(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuDIu4A1o2LUr46ICpukplEa7w6uclRMUDPF0h70Qeh_qGvFDuOVamzD88STF6pIQB0Uq-PogBfNdiZvM5GSLPExGRqHWHvhXi8h0JagLbatalPm_QSkmWKNvTP0wxf6fYYKrZsDuZEcjhZjJHUG5NYgFNXzxQPxcqH58QXnAtciz5tHZkIpAI1hwnbVd6lcJYg44EXaGnH5jKEVQ1d-z7o8XYDzyz7sLUmD3Ykz9t9oTSbHfDrWjxeyd4Y1u1hcnW_M0_GAFgEtKk8",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kBackgroundLight,
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(Icons.arrow_back_ios_new, onTap: () {
              Navigator.pop(context);
            }),
            Row(
              children: [
                _circleButton(Icons.favorite_border),
                const SizedBox(width: 12),
                _circleButton(Icons.share),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: opacity(Colors.black, 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Signature Manicure",
      style: GoogleFonts.cormorantGaramond(
        fontSize: 56,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        height: 1.1,
        color: kEspressoColor,
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: opacity(kEspressoColor, 0.05)),
        ),
      ),
      child: Row(
        children: [
          _infoColumn("Duration", "90 minutes"),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: opacity(kEspressoColor, 0.05),
          ),
          _infoColumn("Investment", "\$85.00"),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 2,
            color: opacity(kEspressoColor, 0.4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: kChampagneColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      "Experience a bespoke nail care ritual designed for the modern minimalist. "
      "Our signature treatment includes detailed cuticle care, a soothing hand massage "
      "with organic botanical oils, and a flawless finish with our curated palette of premium editorial shades.",
      style: GoogleFonts.inter(
        fontSize: 17,
        height: 1.8,
        fontWeight: FontWeight.w300,
        color: opacity(kEspressoColor, 0.7),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _featureTile(
          Icons.workspace_premium,
          "Professional Artist",
          "Top-tier mobile technician at your door",
        ),
        const SizedBox(height: 16),
        _featureTile(
          Icons.auto_awesome,
          "Premium Products",
          "Non-toxic, high-shine editorial polishes",
        ),
      ],
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: opacity(kNeutralGoldColor, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: opacity(kNeutralGoldColor, 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kChampagneColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: opacity(kEspressoColor, 0.5),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: opacity(kBackgroundLight, 0.95),
        border: Border(
          top: BorderSide(color: opacity(kEspressoColor, 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectTimeSlotScreen()));
            },
            icon: const Icon(Icons.calendar_month, size: 20),
            label: Text(
              "BOOK NOW",
              style: GoogleFonts.inter(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
