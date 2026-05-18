import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/widgets/stylistcard.dart';

import 'package:sidi/services/favorite_service_api.dart';
import 'package:sidi/controller/ratingcontroller.dart';

import 'timeslotscreen.dart';

import 'package:sidi/models/stylist.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    required this.title,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.stylists = const [],
    this.showFavButton = true,
    this.description = '',
    this.curatedServiceId,
    this.beauticianId,
  });

  final String serviceId;
  final String title;
  final String price;
  final String description;
  final String duration;
  final String imageUrl;
  final List<Stylist> stylists;
  final bool showFavButton;
  final String? curatedServiceId;
  final String? beauticianId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<Offset> _slideTitle,
      _slideMeta,
      _slideDesc,
      _slideFeatures,
      _slideStylists;

  // Colors are provided by lib/constant/constants.dart
  late bool isFavorite = false;
  late bool isLoadingFavorite = false;

  int? selectedStylistIndex;
  int selectedRating = 0;
  bool isSubmittingRating = false;

  @override
  void initState() {
    super.initState();
    if (widget.stylists.isNotEmpty) {
      selectedStylistIndex = 0;
    }
    _loadFavoriteStatus();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Animation<Offset> slide(double b, double e) =>
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: Interval(b, e, curve: Curves.easeOutCubic),
          ),
        );
    _slideTitle = slide(0.0, 0.4);
    _slideMeta = slide(0.1, 0.5);
    _slideDesc = slide(0.2, 0.6);
    _slideFeatures = slide(0.35, 0.75);
    _slideStylists = slide(0.5, 0.9);
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteStatus() async {
    setState(() {
      isLoadingFavorite = true;
    });

    try {
      final result = await FavoriteServiceApi.isFavoriteService(
        widget.serviceId,
      );

      if (mounted) {
        setState(() {
          isFavorite = result;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (isLoadingFavorite) return;

    setState(() {
      isLoadingFavorite = true;
    });

    try {
      if (isFavorite) {
        final result = await FavoriteServiceApi.removeFavoriteService(
          widget.serviceId,
        );
        if (result['success'] == true) {
          setState(() {
            isFavorite = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Removed from favorites'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (result['message'] as String?) ??
                      'Failed to remove from favorites',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        final result = await FavoriteServiceApi.addFavoriteService(
          widget.serviceId,
        );
        if (result['success'] == true) {
          setState(() {
            isFavorite = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to favorites'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (result['message'] as String?) ??
                      'Failed to add to favorites',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildHeroSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // const _BookingStepBar(currentStep: 1),
                  const SizedBox(height: 24),
                  SlideTransition(position: _slideTitle, child: _buildTitle()),
                  const SizedBox(height: 20),
                  SlideTransition(position: _slideMeta, child: _buildInfoRow()),
                  const SizedBox(height: 28),
                  SlideTransition(
                    position: _slideDesc,
                    child: _buildDescription(),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _slideFeatures,
                    child: _buildFeatures(),
                  ),
                  const SizedBox(height: 40),
                  if (widget.stylists.isNotEmpty) ...[
                    SlideTransition(
                      position: _slideStylists,
                      child: _buildSection(title: "Stylists", scale: 1.4),
                    ),
                    SlideTransition(
                      position: _slideStylists,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.stylists.length,
                        itemBuilder: (context, index) {
                          final stylist = widget.stylists[index];
                          final isSelected = selectedStylistIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  selectedStylistIndex = index;
                                });
                              },
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? kChampagneColor
                                            : Colors.transparent,
                                        width: isSelected ? 2 : 0,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: kChampagneColor
                                                    .withOpacity(0.28),
                                                blurRadius: 14,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: StylistsCard(stylist: stylist),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 10,
                                      right: 14,
                                      child: AnimatedScale(
                                        scale: 1.0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: kChampagneColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 220),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildHeroSliverAppBar() {
    final heroHeight = MediaQuery.of(context).size.height * 0.65;

    return SliverAppBar(
      expandedHeight: heroHeight,
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: kBackgroundLight,
      surfaceTintColor: kBackgroundLight,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _circleButton(
          Icons.arrow_back_ios_new,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      actions: [
        if (widget.showFavButton)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isLoadingFavorite
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? kChampagneColor : Colors.black,
                      size: 20,
                    ),
                  ),
          ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, kBackgroundLight],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.black87, size: 18),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppFonts.cormorantGaramond(
            fontSize: 40,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w300,
            height: 1.1,
            color: kEspressoColor,
          ),
        ),
        const SizedBox(height: 14),
        // Row(
        //   children: [
        //     ...List.generate(5, (index) {
        //       final starIndex = index + 1;
        //       return GestureDetector(
        //         onTap: () => _submitRating(starIndex),
        //         child: Padding(
        //           padding: const EdgeInsets.only(right: 4),
        //           child: Icon(
        //             selectedRating >= starIndex
        //                 ? Icons.star_rounded
        //                 : Icons.star_outline_rounded,
        //             color: selectedRating >= starIndex
        //                 ? Colors.amber
        //                 : Colors.grey[300],
        //             size: 28,
        //           ),
        //         ),
        //       );
        //     }),
        //     if (isSubmittingRating)
        //       const Padding(
        //         padding: EdgeInsets.only(left: 8),
        //         child: SizedBox(
        //           width: 16,
        //           height: 16,
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         ),
        //       )
        //     else if (selectedRating > 0)
        //       Padding(
        //         padding: const EdgeInsets.only(left: 8),
        //         child: Text(
        //           'Thanks for rating!',
        //           style: AppFonts.inter(
        //             fontSize: 11,
        //             color: Colors.amber[700],
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
      ],
    );
  }

  Future<void> _submitRating(int rating) async {
    if (isSubmittingRating) return;
    setState(() {
      isSubmittingRating = true;
      selectedRating = rating;
    });
    try {
      final response = widget.curatedServiceId != null
          ? await RatingController.submitCuratedServiceRating(
              curatedServiceId: widget.curatedServiceId!,
              rating: rating,
            )
          : await RatingController.submitServiceRating(
              serviceId: widget.serviceId,
              rating: rating,
            );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response != null && response.statusCode == 200
                  ? 'Thank you for rating!'
                  : 'Failed to submit rating',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingRating = false;
        });
      }
    }
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
          _infoColumn("Duration", widget.duration),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: opacity(kEspressoColor, 0.05),
          ),
          _infoColumn("Investment", widget.price),
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
          style: AppFonts.inter(
            fontSize: 10,
            letterSpacing: 2,
            color: opacity(kEspressoColor, 0.4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppFonts.inter(
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
      // "Experience a bespoke nail care ritual designed for the modern minimalist. "
      // "Our signature treatment includes detailed cuticle care, a soothing hand massage "
      // "with organic botanical oils, and a flawless finish with our curated palette of premium editorial shades.",
      widget.description,
      style: AppFonts.inter(
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
                  style: AppFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.inter(
                    fontSize: 13,
                    color: opacity(kEspressoColor, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    // required List<_ProfileItemData> items,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.inter(
            fontSize: 9 * scale,
            letterSpacing: 4,
            color: kAccentGold,
          ),
        ),
        const SizedBox(height: 12),
        // ...items.map((item) => _buildSectionRow(item, scale)),
      ],
    );
  }

  Widget _buildBottomSection() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(
              top: BorderSide(color: opacity(kEspressoColor, 0.08)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kEspressoColor, Color(0xFF5C3D2E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: kEspressoColor.withOpacity(0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectTimeSlotScreen(
                            serviceId: widget.serviceId,
                            title: widget.title,
                            price: widget.price,
                            duration: widget.duration,
                            imageUrl: widget.imageUrl,
                            stylist: widget.stylists.isNotEmpty
                                ? widget.stylists[selectedStylistIndex ?? 0]
                                : null,
                            beauticianId: widget.beauticianId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'BOOK NOW',
                          style: AppFonts.inter(
                            fontSize: 16,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
