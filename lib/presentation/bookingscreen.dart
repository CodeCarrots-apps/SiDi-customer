import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:dio/dio.dart';
import 'package:sidi/models/stylist.dart';
import 'package:sidi/services/nearby_beauticians_service.dart';

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
  late Future<List<Map<String, dynamic>>> _curatedServicesFuture;
  late Future<List<Stylist>> _topStylistsFuture;

  @override
  void initState() {
    super.initState();
    _curatedServicesFuture = _fetchCuratedServices();
    _topStylistsFuture = _fetchTopStylists();
  }

  Future<List<Stylist>> _fetchTopStylists() async {
    try {
      final response = await NearbyBeauticiansService.getNearbyBeauticians(
        latitude: 9.9312, // Default to Kochi, or use user location
        longitude: 76.2673,
      );
      return response.beauticians.map((e) => Stylist.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching stylists: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCuratedServices() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/curated-services',
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['curatedServices'] is List) {
        return List<Map<String, dynamic>>.from(
          response.data['curatedServices'],
        );
      } else {
        throw Exception('Failed to load curated services');
      }
    } catch (e) {
      print('Error fetching curated services: $e');
      rethrow;
    }
  }

  // Removed _searchData and _filteredSearchResults since curated services are now fetched from API.

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
                  _buildTopStylistsRow(scale),
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
    // Search results UI removed since curated services are now fetched from API.
    return SizedBox.shrink();
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _curatedServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 300 * scale,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 300 * scale,
            child: Center(child: Text('Error loading curated services')),
          );
        }
        final curated = snapshot.data ?? [];
        if (curated.isEmpty) {
          return SizedBox(
            height: 300 * scale,
            child: Center(child: Text('No curated services available')),
          );
        }
        final showCurated = curated.take(3).toList();
        return SizedBox(
          height: 300 * scale,
          child: Row(
            children: [
              // Left tall card
              if (showCurated.length > 0)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(
                            description: showCurated[0]['description'] ?? '',
                            serviceId: showCurated[0]['_id']?.toString() ?? '',
                            title: showCurated[0]['curatedServiceTitle'] ?? '',
                            price: showCurated[0]['price']?.toString() ?? '',
                            duration:
                                showCurated[0]['duration']?.toString() ?? '',
                            imageUrl:
                                showCurated[0]['image2'] != null &&
                                    showCurated[0]['image2']
                                        .toString()
                                        .isNotEmpty
                                ? "https://sidi.mobilegear.co.in/uploads/" +
                                      showCurated[0]['image2']
                                : '',
                            curatedServiceId: showCurated[0]['_id']?.toString(),
                          ),
                        ),
                      );
                    },
                    child: _categoryTile(
                      image:
                          showCurated[0]['image1'] != null &&
                              showCurated[0]['image1'].toString().isNotEmpty
                          ? "https://sidi.mobilegear.co.in/uploads/" +
                                showCurated[0]['image1']
                          : '',
                      title: showCurated[0]['curatedServiceTitle'] ?? '',
                      subtitle: showCurated[0]['subtitle'] ?? '',
                      height: double.infinity,
                      scale: scale,
                    ),
                  ),
                ),
              SizedBox(width: 8 * scale),
              // Right column with two stacked cards
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    if (showCurated.length > 1)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(
                                  serviceId:
                                      showCurated[1]['_id']?.toString() ?? '',
                                  title:
                                      showCurated[1]['curatedServiceTitle'] ??
                                      '',
                                  price:
                                      showCurated[1]['price']?.toString() ?? '',
                                  duration:
                                      showCurated[1]['duration']?.toString() ??
                                      '',
                                  imageUrl:
                                      showCurated[1]['image2'] != null &&
                                          showCurated[1]['image2']
                                              .toString()
                                              .isNotEmpty
                                      ? "https://sidi.mobilegear.co.in/uploads/" +
                                            showCurated[1]['image2']
                                      : '',
                                  curatedServiceId: showCurated[1]['_id']
                                      ?.toString(),
                                ),
                              ),
                            );
                          },
                          child: _categoryTile(
                            image:
                                showCurated[1]['image1'] != null &&
                                    showCurated[1]['image1']
                                        .toString()
                                        .isNotEmpty
                                ? "https://sidi.mobilegear.co.in/uploads/" +
                                      showCurated[1]['image1']
                                : '',
                            title: showCurated[1]['curatedServiceTitle'] ?? '',
                            subtitle: showCurated[1]['subtitle'] ?? '',
                            height: double.infinity,
                            scale: scale,
                          ),
                        ),
                      ),
                    SizedBox(height: 8 * scale),
                    if (showCurated.length > 2)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(
                                  serviceId:
                                      showCurated[2]['_id']?.toString() ?? '',
                                  title:
                                      showCurated[2]['curatedServiceTitle'] ??
                                      '',
                                  price:
                                      showCurated[2]['price']?.toString() ?? '',
                                  duration:
                                      showCurated[2]['duration']?.toString() ??
                                      '',
                                  imageUrl:
                                      showCurated[2]['image2'] != null &&
                                          showCurated[2]['image2']
                                              .toString()
                                              .isNotEmpty
                                      ? "https://sidi.mobilegear.co.in/uploads/" +
                                            showCurated[2]['image2']
                                      : '',
                                  curatedServiceId: showCurated[2]['_id']
                                      ?.toString(),
                                ),
                              ),
                            );
                          },
                          child: _categoryTile(
                            image:
                                showCurated[2]['image1'] != null &&
                                    showCurated[2]['image1']
                                        .toString()
                                        .isNotEmpty
                                ? "https://sidi.mobilegear.co.in/uploads/" +
                                      showCurated[2]['image1']
                                : '',
                            title: showCurated[2]['curatedServiceTitle'] ?? '',
                            subtitle: showCurated[2]['subtitle'] ?? '',
                            height: double.infinity,
                            scale: scale,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildTopStylistsRow(double scale) {
    return FutureBuilder<List<Stylist>>(
      future: _topStylistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 136 * scale,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 136 * scale,
            child: Center(child: Text('Error loading stylists')),
          );
        }
        final stylists = snapshot.data ?? [];
        if (stylists.isEmpty) {
          return SizedBox(
            height: 136 * scale,
            child: Center(child: Text('No stylists found.')),
          );
        }
        final showStylists = stylists.take(3).toList();
        return SizedBox(
          height: 136 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: showStylists.length,
            separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
            itemBuilder: (context, index) {
              final stylist = showStylists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailedArtistScreen(
                        artistId: stylist.id,
                        artistName: stylist.fullName,
                        role: stylist.tier.isNotEmpty
                            ? stylist.tier
                            : 'Beautician',
                        imageUrl: stylist.displayImage,
                        rating: stylist.rating,
                        description: stylist.bio,
                        services:
                            const [], // Optionally pass services if available
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
                            stylist.displayImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        stylist.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          color: kCharcoalColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        stylist.tier.isNotEmpty ? stylist.tier : 'Beautician',
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
      },
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
            'Coming Soon: Personalized recommendations based on your style and past bookings.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 30 * scale,
              fontStyle: FontStyle.italic,
              color: kCharcoalColor,
            ),
          ),
          SizedBox(height: 10 * scale),
        ],
      ),
    );
  }
}
