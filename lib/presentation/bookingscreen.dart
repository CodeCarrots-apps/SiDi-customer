// ignore_for_file: prefer_interpolation_to_compose_strings, unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sidi/models/stylist.dart';
import 'package:sidi/services/nearby_beauticians_service.dart';
import 'dart:async';

import 'detailedartistscreen.dart';
import 'servicedetailscreen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _searchController = TextEditingController();
  // String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _curatedServicesFuture;
  late Future<List<Stylist>> _topStylistsFuture;

  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _curatedServices = [];
  List<Stylist> _topStylists = [];
  List<Map<String, dynamic>> _allServices = [];

  @override
  void initState() {
    super.initState();
    _curatedServicesFuture = _fetchCuratedServices();
    _topStylistsFuture = _fetchTopStylists();
    _fetchAllServices();
  }

  Future<List<Stylist>> _fetchTopStylists() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final response = await NearbyBeauticiansService.getNearbyBeauticians(
        latitude: 9.9312, // Default to Kochi, or use user location
        longitude: 76.2673,
      );
      final stylists = response.beauticians
          .map((e) => Stylist.fromJson(e))
          .toList();
      setState(() {
        _topStylists = stylists;
      });
      return stylists;
    } catch (e) {
      print('Error fetching stylists: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllServices() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/services',
      );
      if (response.statusCode == 200 && response.data is List) {
        final services = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _allServices = services;
        });
        return services;
      } else {
        throw Exception('Failed to load all services');
      }
    } catch (e) {
      print('Error fetching all services: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCuratedServices() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/curated-services',
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['curatedServices'] is List) {
        final services = List<Map<String, dynamic>>.from(
          response.data['curatedServices'],
        );
        setState(() {
          _curatedServices = services;
        });
        return services;
      } else {
        throw Exception('Failed to load curated services');
      }
    } catch (e) {
      print('Error fetching curated services: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debounceSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String keyword) async {
    if (keyword.isEmpty || keyword.length < 3) {
      setState(() {
        _searchResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate async delay for consistency
    await Future.delayed(const Duration(milliseconds: 100));

    final lowerKeyword = keyword.toLowerCase();

    List<dynamic> tempResults = [];

    // Filter curated services by name
    tempResults.addAll(
      _curatedServices
          .where(
            (service) =>
                service['curatedServiceTitle']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowerKeyword) ??
                false,
          )
          .map(
            (service) => {
              'type': 'service',
              'name': service['curatedServiceTitle'],
              ...service,
            },
          ),
    );

    // Filter all services by name
    tempResults.addAll(
      _allServices
          .where(
            (service) =>
                service['name']?.toString().toLowerCase().contains(
                  lowerKeyword,
                ) ??
                false,
          )
          .map((service) => {'type': 'service', ...service}),
    );

    // Filter top stylists by name
    tempResults.addAll(
      _topStylists
          .where(
            (stylist) => stylist.fullName.toLowerCase().contains(lowerKeyword),
          )
          .map(
            (stylist) => {
              'type': 'stylist',
              '_id': stylist.id,
              'name': stylist.fullName,
              'role': stylist.tier,
              'image': stylist.displayImage,
              'rating': stylist.rating,
              'bio': stylist.bio,
            },
          ),
    );

    setState(() {
      _searchResults = tempResults;
      _isLoading = false;
    });
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
                  if (_searchQuery.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20 * scale),
                        _buildSectionTitle('Curated Categories', scale),
                        SizedBox(height: 10 * scale),
                        _buildCuratedGrid(scale),
                        SizedBox(height: 20 * scale),
                        _buildTopStylistsRow(scale),
                        SizedBox(height: 20 * scale),
                        _buildRecommendationCard(scale),
                      ],
                    )
                  else
                    _buildSearchResults(scale),
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
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _debounceSearch(value);
              },
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
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
                _searchResults.clear();
                _debounceTimer?.cancel();
              },
            )
          else
            Icon(Icons.search, color: kWarmGrey600, size: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildSearchResults(double scale) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.length < 3) {
      return Padding(
        padding: EdgeInsets.all(16 * scale),
        child: const Text('Type at least 3 characters'),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16 * scale),
        child: const Text('No results found'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        final isService = item['price'] != null && item['name'] != null;
        final image = isService
            ? (item['image1'] != null && item['image1'].toString().isNotEmpty
                  ? (item['image1'].toString().startsWith('http')
                        ? item['image1']
                        : 'https://sidi.mobilegear.co.in/uploads/' +
                              item['image1'])
                  : '')
            : (item['image'] ?? '');
        final image2 = isService
            ? (item['image2'] != null && item['image2'].toString().isNotEmpty
                  ? (item['image2'].toString().startsWith('http')
                        ? item['image2']
                        : 'https://sidi.mobilegear.co.in/uploads/' +
                              item['image2'])
                  : '')
            : (item['image'] ?? '');
        debugPrint('Search result item: $image');
        final name = isService ? (item['name'] ?? '') : (item['name'] ?? '');
        final type = isService ? 'service' : (item['type'] ?? '');
        final description = isService
            ? (item['description'] ?? '')
            : (item['bio'] ?? '');

        return ListTile(
          leading: image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.grey[300]),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                )
              : const Icon(Icons.image_not_supported),
          title: Text(name),
          subtitle: Text(type),
          onTap: () {
            if (type == 'service') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailScreen(
                    serviceId: item['_id'] ?? '',
                    title: name,
                    price: item['price']?.toString() ?? '',
                    duration: item['duration']?.toString() ?? '',
                    imageUrl: image2,
                    description: item['description'] ?? '',
                  ),
                ),
              );
            } else if (type == 'stylist') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailedArtistScreen(
                    artistId: item['_id'] ?? '',
                    artistName: name,
                    role: item['role'] ?? '',
                    imageUrl: image,
                    rating: item['rating'] ?? 0,
                    description: item['bio'] ?? '',
                    services: const [],
                  ),
                ),
              );
            }
          },
        );
      },
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _curatedServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCuratedGridShimmer(scale);
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
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.grey[300]),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
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
          return _buildTopStylistsShimmer(scale);
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

  Widget _buildCuratedGridShimmer(double scale) {
    return SizedBox(
      height: 300 * scale,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStylistsShimmer(double scale) {
    return SizedBox(
      height: 136 * scale,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
          itemBuilder: (context, index) {
            return Container(
              width: 100 * scale,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }
}
