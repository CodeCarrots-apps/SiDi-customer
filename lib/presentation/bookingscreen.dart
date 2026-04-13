import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

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
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              10 * scale,
              16 * scale,
              92 * scale,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBox(scale),
                  SizedBox(height: 14 * scale),
                  _buildRecentSearches(scale),
                  SizedBox(height: 20 * scale),
                  _buildSectionTitle('Curated Categories', scale),
                  SizedBox(height: 10 * scale),
                  _buildCuratedGrid(scale),
                  SizedBox(height: 20 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Top Stylists', scale),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.inter(
                          fontSize: 9 * scale,
                          letterSpacing: 1.8,
                          color: kWarmGrey600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  _buildStylistsRow(scale),
                  SizedBox(height: 20 * scale),
                  _buildRecommendationCard(scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(double scale) {
    return Container(
      height: 46 * scale,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
      decoration: BoxDecoration(border: Border.all(color: kWarmGrey200)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Search services or stylists',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22 * scale,
                fontStyle: FontStyle.italic,
                color: kWarmGrey600,
              ),
            ),
          ),
          Icon(Icons.search, color: kWarmGrey600, size: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT SEARCHES',
          style: GoogleFonts.inter(
            fontSize: 9 * scale,
            letterSpacing: 2,
            color: kWarmGrey600,
          ),
        ),
        SizedBox(height: 8 * scale),
        Wrap(
          spacing: 14 * scale,
          children: [
            _recentSearchText('Silk Press', scale),
            _recentSearchText('Elena Rodriguez', scale),
            _recentSearchText('Glow Facial', scale),
          ],
        ),
      ],
    );
  }

  Widget _recentSearchText(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 20 * scale,
        fontStyle: FontStyle.italic,
        color: kCharcoalColor,
      ),
    );
  }

  Widget _buildSectionTitle(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 32 * scale,
        fontStyle: FontStyle.italic,
        color: kCharcoalColor,
      ),
    );
  }

  Widget _buildCuratedGrid(double scale) {
    return SizedBox(
      height: 300 * scale,
      child: Row(
        children: [
          Expanded(
            child: _categoryTile(
              image:
                  'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=800&q=80',
              title: 'Editorial Hair',
              subtitle: 'THE COLLECTION',
              height: double.infinity,
              scale: scale,
            ),
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Column(
              children: [
                _categoryTile(
                  image:
                      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
                  title: 'Signature Facials',
                  height: 147 * scale,
                  scale: scale,
                ),
                SizedBox(height: 6 * scale),
                _categoryTile(
                  image:
                      'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=800&q=80',
                  title: 'Bridal Atelier',
                  height: 147 * scale,
                  scale: scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile({
    required String image,
    required String title,
    String? subtitle,
    required double height,
    required double scale,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: Image.network(image, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8 * scale,
            right: 8 * scale,
            bottom: 8 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 8 * scale,
                      letterSpacing: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                Text(
                  title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22 * scale,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylistsRow(double scale) {
    final stylists = [
      (
        'https://randomuser.me/api/portraits/men/33.jpg',
        'Julian V.',
        'COLORIST',
      ),
      ('https://randomuser.me/api/portraits/women/44.jpg', 'Sasha L.', 'CUTS'),
      (
        'https://randomuser.me/api/portraits/men/22.jpg',
        'Marcus R.',
        'ARTISTIC',
      ),
    ];

    return SizedBox(
      height: 136 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stylists.length,
        separatorBuilder: (_, index) => SizedBox(width: 10 * scale),
        itemBuilder: (context, index) {
          final stylist = stylists[index];
          return SizedBox(
            width: 78 * scale,
            child: Column(
              children: [
                Container(
                  width: 76 * scale,
                  height: 76 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kWarmGrey200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(stylist.$1, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  stylist.$2,
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    color: kCharcoalColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * scale),
                Text(
                  stylist.$3,
                  style: GoogleFonts.inter(
                    fontSize: 8 * scale,
                    letterSpacing: 1.3,
                    color: kWarmGrey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        18 * scale,
        16 * scale,
        18 * scale,
      ),
      color: const Color(0xFFF2EFEA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOMMENDED FOR YOU',
            style: GoogleFonts.inter(
              fontSize: 8 * scale,
              letterSpacing: 1.6,
              color: kWarmGrey600,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'The Moonlight Ritual Facial',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 30 * scale,
              fontStyle: FontStyle.italic,
              color: kCharcoalColor,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'A 90-minute immersion into cellular regeneration. Utilizes cool-tone light therapy and organic botanical extracts.',
            style: GoogleFonts.inter(
              fontSize: 13 * scale,
              height: 1.5,
              color: kCharcoalColor,
            ),
          ),
          SizedBox(height: 14 * scale),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 18 * scale,
                vertical: 10 * scale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'RESERVE SPACE',
              style: GoogleFonts.inter(
                fontSize: 9 * scale,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
