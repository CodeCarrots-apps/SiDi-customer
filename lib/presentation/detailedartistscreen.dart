import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'timeslotscreen.dart';

class DetailedArtistScreen extends StatelessWidget {
  const DetailedArtistScreen({
    super.key,
    this.artistName = 'Elena Rossi',
    this.role = 'Master Stylist',
    this.imageUrl =
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&q=80',
  });

  final String artistName;
  final String role;
  final String imageUrl;

  static const _services = [
    {
      'title': 'Signature Color',
      'price': '240+',
      'description':
          'Bespoke dimensional coloring designed to enhance natural movement and depth.',
    },
    {
      'title': 'Precision Cut',
      'price': '140+',
      'description':
          'Architectural cutting techniques tailored to the unique geometry of the face.',
    },
    {
      'title': 'Editorial Styling',
      'price': '110+',
      'description':
          'Refined finishes for distinguished events, focusing on effortless sophistication.',
    },
    {
      'title': 'Scalp Treatment',
      'price': '90+',
      'description':
          'Botanical infusion therapy to restore the natural equilibrium of the scalp ecosystem.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: kEspressoColor),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.44,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          kBackgroundLight.withOpacity(0.94),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 32),
                Text(
                  role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: kWarmGrey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  artistName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 44,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: kEspressoColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'With over fifteen years of dedicated practice in Milan and London, $artistName has defined a signature approach to minimalist beauty. Her philosophy centers on the transformative power of meticulous detail and a quiet, editorial aesthetic.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.8,
                    color: opacity(kEspressoColor, 0.75),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Specializing in precision techniques that honor natural textures, $artistName curates bespoke looks that transcend trends, favoring timeless elegance over the temporary.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.8,
                    color: opacity(kEspressoColor, 0.75),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'The Services',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                    Text(
                      'CURATED CARE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: kWarmGrey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ..._services
                    .map((service) => _buildServiceRow(context, service))
                    .toList(),
                const SizedBox(height: 24),
                Text(
                  '“Simplicity is the ultimate sophistication.”',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: opacity(kEspressoColor, 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, Map<String, String> service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service['title']!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kEspressoColor,
                ),
              ),
              Text(
                service['price']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kEspressoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service['description']!,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.7,
              color: opacity(kEspressoColor, 0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 110,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectTimeSlotScreen(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: kEspressoColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'BOOK',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: kWarmGrey200, thickness: 1),
        ],
      ),
    );
  }
}
