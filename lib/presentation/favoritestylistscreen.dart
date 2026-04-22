import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/user_profile.dart' hide FavoriteService;
import 'package:sidi/presentation/detailedartistscreen.dart';
import 'package:sidi/presentation/servicedetailscreen.dart';
import 'package:sidi/services/favorite_service.dart' as favorite_service;
import 'package:sidi/services/favorite_service_api.dart';
import 'package:sidi/models/user_profile.dart'
    as user_profile
    show FavoriteService;

class FavoriteStylistScreen extends StatefulWidget {
  final List<FavoriteStylist>? favoriteStylists;

  const FavoriteStylistScreen({super.key, this.favoriteStylists});

  @override
  State<FavoriteStylistScreen> createState() => _FavoriteStylistScreenState();
}

class _FavoriteStylistScreenState extends State<FavoriteStylistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<FavoriteStylist> favoriteStylists = [];
  List<user_profile.FavoriteService> favoriteServices = [];
  bool isLoadingStylists = true;
  bool isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavoriteStylists();
    _loadFavoriteServices();
  }

  Future<void> _loadFavoriteStylists() async {
    try {
      final favorites = await favorite_service.FavoriteService.getFavorites();
      setState(() {
        favoriteStylists = favorites
            .map((fav) => FavoriteStylist.fromJson(fav))
            .toList();
        isLoadingStylists = false;
      });
    } catch (e) {
      debugPrint('Error loading favorite stylists: $e');
      setState(() {
        isLoadingStylists = false;
      });
    }
  }

  Future<void> _loadFavoriteServices() async {
    try {
      final services = await FavoriteServiceApi.getFavoriteServices();
      setState(() {
        favoriteServices = services
            .map((service) => user_profile.FavoriteService.fromJson(service))
            .toList();
        isLoadingServices = false;
      });
    } catch (e) {
      debugPrint('Error loading favorite services: $e');
      setState(() {
        isLoadingServices = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryColor,
      appBar: AppBar(
        backgroundColor: kIvoryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new),
          color: kCharcoalColor,
        ),
        title: Text(
          'FAVORITES',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: kCharcoalColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kCharcoalColor,
          unselectedLabelColor: kWarmGrey600,
          indicatorColor: kAccentGold,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'STYLISTS'),
            Tab(text: 'SERVICES'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Stylists Tab
            _buildStylistsList(),
            // Services Tab
            _buildServicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStylistsList() {
    if (isLoadingStylists) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteStylists.isEmpty) {
      return Center(
        child: Text(
          'No favorite stylists yet',
          style: GoogleFonts.inter(fontSize: 14, color: kWarmGrey600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView.separated(
        itemCount: favoriteStylists.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final stylist = favoriteStylists[index];
          return _FavoriteStylistCard(
            stylist: stylist,
            onReturn: _loadFavoriteStylists,
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    if (isLoadingServices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteServices.isEmpty) {
      return Center(
        child: Text(
          'No favorite services yet',
          style: GoogleFonts.inter(fontSize: 14, color: kWarmGrey600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView.separated(
        itemCount: favoriteServices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final service = favoriteServices[index];
          return _FavoriteServiceCard(
            service: service,
            onReturn: _loadFavoriteServices,
          );
        },
      ),
    );
  }
}

class _FavoriteStylistCard extends StatelessWidget {
  final FavoriteStylist stylist;
  final VoidCallback onReturn;

  const _FavoriteStylistCard({required this.stylist, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailedArtistScreen(
              artistId: stylist.id,
              artistName: stylist.fullName,
              role: stylist.tier,
              imageUrl: stylist.profileImage,
            ),
          ),
        );
        onReturn();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kCharcoalColor.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildProfileImage(stylist.profileImage, stylist.fullName),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stylist.fullName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kCharcoalColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stylist.tier.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.4,
                      color: kWarmGrey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.favorite, color: kAccentGold, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, String fullName) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsAvatar(fullName),
      );
    }
    return _buildInitialsAvatar(fullName);
  }

  Widget _buildInitialsAvatar(String fullName) {
    final initials = _nameInitials(fullName);
    return Container(
      width: 70,
      height: 70,
      color: kWarmGrey100,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: kCharcoalColor,
        ),
      ),
    );
  }

  String _nameInitials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _FavoriteServiceCard extends StatelessWidget {
  final user_profile.FavoriteService service;
  final VoidCallback onReturn;

  const _FavoriteServiceCard({required this.service, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              serviceId: service.id,
              title: service.name,
              price: service.price.toString(),
              duration: service.duration.toString(),
              imageUrl: "https://sidi.mobilegear.co.in${service.image2}",
            ),
          ),
        );

        // 🔥 THIS WAS MISSING
        onReturn();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kCharcoalColor.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildServiceImage(
                    "https://sidi.mobilegear.co.in${service.image1}",
                    service.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kCharcoalColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${service.duration} mins',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kWarmGrey600,
                        ),
                      ),
                      if (service.category != null &&
                          service.category!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${service.category}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: kWarmGrey600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.favorite, color: kAccentGold, size: 24),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kAccentGold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Service added to cart'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: kAccentGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'BOOK',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kIvoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceImage(String imageUrl, String serviceName) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsAvatar(serviceName),
      );
    }
    return _buildInitialsAvatar(serviceName);
  }

  Widget _buildInitialsAvatar(String serviceName) {
    final initial = serviceName.isNotEmpty ? serviceName[0].toUpperCase() : '?';
    return Container(
      width: 70,
      height: 70,
      color: kWarmGrey100,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: kCharcoalColor,
        ),
      ),
    );
  }
}
