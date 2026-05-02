import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:get/get.dart';
import 'widgets/stylistcard.dart';
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
      backgroundColor: const Color(0xFFF9F7F3),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFCF8), Color(0xFFF6F1E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 14),
                      child: child,
                    ),
                  ),
                  child: Text(
                    'Find Your Nearby Artisans',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 34 * scale,
                      fontStyle: FontStyle.italic,
                      color: kCharcoalColor,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Handpicked professionals close to you',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF766C61),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openLocationSearch(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F2E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Color(0xFF8B775E),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                child: Text(
                                  controller.selectedLocation.value,
                                  key: ValueKey(
                                    controller.selectedLocation.value,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    letterSpacing: 1.1,
                                    color: const Color(0xFF5A534A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Change',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF8D7A63),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Color(0xFF9F8C74),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    Widget child;
                    if (controller.loading.value) {
                      child = const _LoadingState();
                    } else if (controller.error.value != null) {
                      child = _ErrorState(
                        message: controller.error.value!,
                        onRetry: controller.fetchNearbyBeauticians,
                      );
                    } else if (controller.stylists.isEmpty) {
                      child = _EmptyState(
                        onRefresh: controller.fetchNearbyBeauticians,
                      );
                    } else {
                      child = RefreshIndicator(
                        color: const Color(0xFF8B775E),
                        onRefresh: controller.fetchNearbyBeauticians,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 18),
                          itemCount: controller.stylists.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return StylistsCard(
                              stylist: controller.stylists[index],
                            );
                          },
                        ),
                      );
                    }

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(
                          '${controller.loading.value}-${controller.error.value}-${controller.stylists.length}',
                        ),
                        child: child,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, index) {
        return Container(
          height: 148,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_tethering_error_rounded,
              color: Color(0xFF9D4C3D),
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              'We could not load nearby stylists',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3A332A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF857B70),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF2D2822),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF2ECE3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.content_cut_outlined,
                color: Color(0xFF8A7760),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No stylists nearby right now',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF3E372E),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another location or refresh to check again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF82786D),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5E544A),
                side: const BorderSide(color: Color(0xFFCFC3B3)),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
