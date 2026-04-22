import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'detailedartistscreen.dart';
import '../models/stylist.dart';
import 'package:get/get.dart';
import 'locationsearchscreen.dart';
import 'stylistlist_controller.dart';

class StylistListScreen extends StatelessWidget {
  StylistListScreen({super.key});

  final StylistListController controller = Get.put(StylistListController());

  Future<void> _openLocationSearch(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );

    if (result == null || result is! Map) {
      return;
    }

    final rawLabel =
        (result['name'] as String?) ?? (result['displayName'] as String?) ?? '';
    final trimmed = rawLabel.trim();
    final label = trimmed.isEmpty
        ? controller.selectedLocation.value
        : trimmed.split(',').first.toUpperCase();

    controller.updateLocation(label);
    // Optionally, update coordinates and refetch stylists here
    // controller.fetchNearbyBeauticians();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Nearby Artisians',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 36 * scale,
                  fontStyle: FontStyle.italic,
                  color: kCharcoalColor,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _openLocationSearch(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Obx(
                      () => Text(
                        controller.selectedLocation.value,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.error.value != null) {
                    return Center(
                      child: Text(
                        controller.error.value!,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (controller.stylists.isEmpty) {
                    return Center(
                      child: Text(
                        'No stylists found.',
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    );
                  } else {
                    return ListView.separated(
                      itemCount: controller.stylists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        return StylistCard(stylist: controller.stylists[index]);
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StylistCard extends StatelessWidget {
  final Stylist stylist;

  const StylistCard({super.key, required this.stylist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            stylist.profileImage,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stylist.fullName,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stylist.tier,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailedArtistScreen(
                            artistId: stylist.id,
                            artistName: stylist.fullName,
                            description: stylist.bio,
                            role: stylist.tier,
                            imageUrl: stylist.profileImage,
                            services: [],
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'BOOK NOW',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailedArtistScreen(
                            artistId: stylist.id,
                            artistName: stylist.fullName,
                            description: stylist.bio,
                            role: stylist.tier,
                            imageUrl: stylist.profileImage,
                            services: [],
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'VIEW',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 2),
                Text(
                  stylist.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Text(
            //   '• ${stylist.distance.toStringAsFixed(1)} MI',
            //   style: const TextStyle(fontSize: 11, color: Colors.grey),
            // ),
          ],
        ),
      ],
    );
  }
}
