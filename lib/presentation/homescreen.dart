// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import 'detailedservicescreen.dart';
import 'servicedetailscreen.dart';
import 'locationsearchscreen.dart';
import 'notificationsscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Colors are provided by lib/constant/constants.dart
  String _selectedLocation = 'KOCHI';
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<List<Map<String, dynamic>>> _bannersFuture;
  late Future<List<Map<String, dynamic>>> _curatedServicesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
    _bannersFuture = _fetchBanners();
    _curatedServicesFuture = _fetchCuratedServices();
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/categories',
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> _openLocationSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );

    if (!mounted || result == null || result is! Map) {
      return;
    }

    final rawLabel =
        (result['name'] as String?) ?? (result['displayName'] as String?) ?? '';
    final trimmed = rawLabel.trim();
    final label = trimmed.isEmpty
        ? _selectedLocation
        : trimmed.split(',').first.toUpperCase();

    setState(() {
      _selectedLocation = label;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBanners() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/banners',
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(
          response.data,
        ).where((banner) => banner['isActive'] == true).toList();
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      print('Banner error: $e');
      rethrow;
    }
  }

  Future<void> _openDetailedServices({String? query, String? category}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailedServiceScreen(
          initialSearchQuery: query,
          initialCategory: category,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCuratedServices() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
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

  @override
  Widget build(BuildContext context) {
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
            toolbarHeight: 76,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            title: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: opacity(kCharcoalColor, 0.7),
                  ),
                  onPressed: _openLocationSearch,
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: _openLocationSearch,

                  child: Text(
                    _selectedLocation,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                      color: kCharcoalColor,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(child: _buildHeroSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(child: _buildServicesSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(child: _buildCuratedSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerBanner();
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Error loading banners'),
          );
        }

        final banners = snapshot.data ?? [];

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 420,
            child: PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(
                                  description: banner['description'] ?? '',
                                  serviceId:
                                      banner['serviceId']?.toString() ?? '',
                                  title: banner['title'] ?? '',
                                  price: banner['price']?.toString() ?? '',
                                  duration:
                                      banner['duration']?.toString() ?? '',
                                  imageUrl: banner['image'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            banner["image"] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),

                      /// Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),

                      /// Content
                      Positioned(
                        bottom: 32,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (banner["title"] ?? "").toUpperCase(),
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 10,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              banner["description"] ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white,
                                fontSize: 32,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kEspressoColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailScreen(
                                      description: banner['description'] ?? '',
                                      serviceId:
                                          banner['serviceId']?.toString() ?? '',
                                      title: banner['title'] ?? '',
                                      price: banner['price']?.toString() ?? '',
                                      duration:
                                          banner['duration']?.toString() ?? '',
                                      imageUrl: banner['image'] ?? '',
                                      showFavButton: false,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "EXPLORE",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildServicesShimmer();
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Services",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Error loading services: ${snapshot.error}'),
              ],
            ),
          );
        }

        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Our Services",
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: _openDetailedServices,
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () =>
                        _openDetailedServices(category: service['name']),
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 160,
                              width: 160,
                              child: Image.network(
                                service["image"] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service["name"] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCuratedSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _curatedServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCuratedShimmer();
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Error loading curated services'),
          );
        }
        final curated = snapshot.data ?? [];
        if (curated.isEmpty) {
          return SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Curated for You",
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth * 0.72).clamp(
                    230.0,
                    320.0,
                  );
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: curated.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 24),
                    itemBuilder: (context, index) {
                      final item = curated[index];
                      final imageUrl =
                          item["image1"] != null &&
                              item["image1"].toString().isNotEmpty
                          ? "https://sidi.mobilegear.co.in/uploads/" +
                                item["image1"]
                          : null;
                      final imageUrl2 =
                          item["image2"] != null &&
                              item["image2"].toString().isNotEmpty
                          ? "https://sidi.mobilegear.co.in/uploads/" +
                                item["image2"]
                          : null;
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(
                                description: item['description'] ?? '',
                                serviceId: item['_id']?.toString() ?? '',
                                title: item['curatedServiceTitle'] ?? '',
                                price: item['price']?.toString() ?? '',
                                duration: item['duration']?.toString() ?? '',
                                imageUrl: imageUrl2 ?? '',
                                showFavButton: false,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AspectRatio(
                                  aspectRatio: 16 / 10,
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.error,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item["curatedServiceName"] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  letterSpacing: 3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item["curatedServiceTitle"] ?? '',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item["description"] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 44,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuratedShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (_, __) => Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 20,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
