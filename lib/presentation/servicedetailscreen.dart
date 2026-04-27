import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  // Colors are provided by lib/constant/constants.dart
  late bool isFavorite = false;
  late bool isLoadingFavorite = false;

  int? selectedStylistIndex;
  int selectedRating = 0;
  bool isSubmittingRating = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
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
                  const SizedBox(height: 24),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildInfoRow(),
                  const SizedBox(height: 28),
                  _buildDescription(),
                  const SizedBox(height: 40),
                  _buildFeatures(),
                  const SizedBox(height: 40),
                  if (widget.stylists.isNotEmpty) ...[
                    _buildSection(title: "Stylists", scale: 1.4),
                    ListView.builder(
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
                              setState(() {
                                selectedStylistIndex = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? kChampagneColor
                                      : Colors.transparent,
                                  width: isSelected ? 2 : 0,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: StylistsCard(stylist: stylist),
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.stylists.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          selectedStylistIndex == null
                              ? 'Please select a stylist.'
                              : 'Selected: \\${widget.stylists[selectedStylistIndex!].fullName}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: kEspressoColor,
                          ),
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
      child: Icon(icon, color: Colors.black, size: 20),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 40,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  height: 1.1,
                  color: kEspressoColor,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => _submitRating(starIndex),
                  child: Icon(
                    Icons.star,
                    color: selectedRating >= starIndex
                        ? Colors.amber
                        : Colors.grey[300],
                    size: 22,
                  ),
                );
              }),
            ),
            if (isSubmittingRating)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
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
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 2,
            color: opacity(kEspressoColor, 0.4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
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
      style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
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
    return Padding(
      padding: EdgeInsets.only(top: 24 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28 * scale),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 9 * scale,
                letterSpacing: 4,
                color: kAccentGold,
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          // ...items.map((item) => _buildSectionRow(item, scale)),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final hasMultipleStylists = widget.stylists.length > 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: opacity(kBackgroundLight, 0.95),
        border: Border(top: BorderSide(color: opacity(kEspressoColor, 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {
              if (hasMultipleStylists && selectedStylistIndex == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a stylist before booking.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectTimeSlotScreen(
                    serviceId: widget.serviceId,
                    title: widget.title,
                    price: widget.price,
                    duration: widget.duration,
                    imageUrl: widget.imageUrl,
                    stylist:
                        (widget.stylists.isNotEmpty &&
                            selectedStylistIndex != null)
                        ? widget.stylists[selectedStylistIndex!]
                        : (widget.stylists.isNotEmpty
                              ? widget.stylists.first
                              : null),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month, size: 20),
            label: Text(
              "BOOK NOW",
              style: GoogleFonts.inter(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
