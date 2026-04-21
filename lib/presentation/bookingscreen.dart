import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'detailedartistscreen.dart';
import 'servicedetailscreen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _searchData = [
    {
      'type': 'service',
      'id': '6605',
      'title': 'Glow Facial',
      'subtitle': 'Signature facial treatment',
      'price': '₹240',
      'duration': '75 mins',
      'imageUrl':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
    },
    {
      'type': 'service',
      'id': '6602',
      'title': 'Silk Press',
      'subtitle': 'Smooth hair styling',
      'price': '₹95',
      'duration': '70 mins',
      'imageUrl':
          'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
    },
    {
      'type': 'service',
      'id': '6606',
      'title': 'Moonlight Ritual',
      'subtitle': 'Botanical skin therapy',
      'price': '₹110',
      'duration': '90 mins',
      'imageUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
    },
    {
      'type': 'artist',
      'id': '6651',
      'title': 'Julianne Vough',
      'subtitle': 'MASTER COLORIST',
      'role': 'MASTER COLORIST',
      'imageUrl':
          'https://i.pinimg.com/736x/36/2d/70/362d7087b1b8367db1c98d3f73f3be3a.jpg',
    },
    {
      'type': 'artist',
      'id': '6652',
      'title': 'Marcus Chen',
      'subtitle': 'SKIN SCULPTOR',
      'role': 'SKIN SCULPTOR',
      'imageUrl':
          'https://i.pinimg.com/736x/e3/52/30/e3523011d5dd97b97709e1d83ca75e5b.jpg',
    },
    {
      'type': 'artist',
      'id': '6653',
      'title': 'Elena Rodriguez',
      'subtitle': 'ARTISTIC DIRECTOR',
      'role': 'ARTISTIC DIRECTOR',
      'imageUrl':
          'https://i.pinimg.com/1200x/b5/af/0f/b5af0f1fdc01adb5cd55609e7b302de1.jpg',
    },
  ];

  List<Map<String, String>> get _filteredSearchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _searchData.where((item) {
      return item['title']!.toLowerCase().contains(query) ||
          item['subtitle']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  if (_searchQuery.isNotEmpty)
                    _buildSearchResults(scale)
                  else
                    // _buildRecentSearches(scale),
                    SizedBox(height: 20 * scale),
                  _buildSectionTitle('Curated Categories', scale),
                  SizedBox(height: 10 * scale),
                  _buildCuratedGrid(scale),
                  SizedBox(height: 20 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Top Stylists', scale),
                      // Text(
                      //   'VIEW ALL',
                      //   style: GoogleFonts.inter(
                      //     fontSize: 9 * scale,
                      //     letterSpacing: 1.8,
                      //     color: kWarmGrey600,
                      //   ),
                      // ),
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18 * scale,
                fontStyle: FontStyle.italic,
                color: kCharcoalColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search services or stylists',
                hintStyle: GoogleFonts.cormorantGaramond(
                  fontSize: 18 * scale,
                  fontStyle: FontStyle.italic,
                  color: kWarmGrey600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: kWarmGrey600, size: 20 * scale),
              onPressed: () => setState(() {
                _searchController.clear();
                _searchQuery = '';
              }),
            )
          else
            Icon(Icons.search, color: kWarmGrey600, size: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildSearchResults(double scale) {
    final results = _filteredSearchResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH RESULTS',
          style: GoogleFonts.inter(
            fontSize: 9 * scale,
            letterSpacing: 2,
            color: kWarmGrey600,
          ),
        ),
        SizedBox(height: 8 * scale),
        if (results.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * scale),
            child: Text(
              'No matching services or stylists found.',
              style: GoogleFonts.inter(
                fontSize: 12 * scale,
                color: kWarmGrey600,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (_, __) => SizedBox(height: 6 * scale),
            itemBuilder: (context, index) {
              final item = results[index];
              final isArtist = item['type'] == 'artist';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        if (isArtist) {
                          return DetailedArtistScreen(
                            artistId: item['id'] ?? '',
                            artistName: item['title']!,
                            role: item['role'] ?? item['subtitle']!,
                            imageUrl:
                                item['imageUrl'] ??
                                'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&q=80',
                          );
                        }
                        return ServiceDetailScreen(
                          serviceId: item['id'] ?? '6600',
                          title: item['title']!,
                          price: item['price'] ?? '₹0',
                          duration: item['duration'] ?? 'N/A',
                          imageUrl:
                              item['imageUrl'] ??
                              'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8 * scale,
                    horizontal: 12 * scale,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: kWarmGrey200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34 * scale,
                        height: 34 * scale,
                        decoration: BoxDecoration(
                          color: isArtist ? kEspressoColor : kWarmGrey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isArtist ? Icons.person : Icons.brush,
                          color: Colors.white,
                          size: 20 * scale,
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                color: kCharcoalColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              item['subtitle']!,
                              style: GoogleFonts.inter(
                                fontSize: 11 * scale,
                                color: kWarmGrey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isArtist ? 'Artist' : 'Service',
                        style: GoogleFonts.inter(
                          fontSize: 9 * scale,
                          color: kWarmGrey600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
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
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ServiceDetailScreen(
                      serviceId: '6610',
                      title: 'Editorial Hair',
                      price: '₹220',
                      duration: '60 mins',
                      imageUrl:
                          'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=800&q=80',
                    ),
                  ),
                );
              },
              child: _categoryTile(
                image:
                    'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=800&q=80',
                title: 'Editorial Hair',
                subtitle: 'THE COLLECTION',
                height: double.infinity,
                scale: scale,
              ),
            ),
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceDetailScreen(
                          serviceId: '6611',
                          title: 'Signature Facials',
                          price: '₹250',
                          duration: '75 mins',
                          imageUrl:
                              'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
                        ),
                      ),
                    );
                  },
                  child: _categoryTile(
                    image:
                        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
                    title: 'Signature Facials',
                    height: 147 * scale,
                    scale: scale,
                  ),
                ),
                SizedBox(height: 6 * scale),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceDetailScreen(
                          serviceId: '6612',
                          title: 'Bridal Atelier',
                          price: '₹380',
                          duration: '90 mins',
                          imageUrl:
                              'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=800&q=80',
                        ),
                      ),
                    );
                  },
                  child: _categoryTile(
                    image:
                        'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=800&q=80',
                    title: 'Bridal Atelier',
                    height: 147 * scale,
                    scale: scale,
                  ),
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
      {
        'id': '6652',
        'imageUrl':
            'https://i.pinimg.com/736x/36/2d/70/362d7087b1b8367db1c98d3f73f3be3a.jpg',
        'name': 'Julianne Vough',
        'role': 'MASTER COLORIST',
      },
      {
        'id': '6652',
        'imageUrl':
            'https://i.pinimg.com/736x/e3/52/30/e3523011d5dd97b97709e1d83ca75e5b.jpg',
        'name': 'Marcus Chen',
        'role': 'SKIN SCULPTOR',
      },
      {
        'id': '6652',
        'imageUrl':
            'https://i.pinimg.com/1200x/b5/af/0f/b5af0f1fdc01adb5cd55609e7b302de1.jpg',
        'name': 'Elena Rodriguez',
        'role': 'ARTISTIC DIRECTOR',
      },
    ];

    return SizedBox(
      height: 136 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stylists.length,
        separatorBuilder: (_, index) => SizedBox(width: 10 * scale),
        itemBuilder: (context, index) {
          final stylist = stylists[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailedArtistScreen(
                    artistName: stylist['name']!,
                    role: stylist['role']!,
                    imageUrl: stylist['imageUrl']!,
                    artistId: stylist['id'] ?? '',
                  ),
                ),
              );
            },
            child: SizedBox(
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
                      child: Image.network(
                        stylist['imageUrl']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    stylist['name']!,
                    style: GoogleFonts.inter(
                      fontSize: 11 * scale,
                      color: kCharcoalColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    stylist['role']!,
                    style: GoogleFonts.inter(
                      fontSize: 8 * scale,
                      letterSpacing: 1.3,
                      color: kWarmGrey600,
                    ),
                  ),
                ],
              ),
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
