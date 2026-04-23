import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dio/dio.dart';
import '../utils/token_storage.dart';
import 'package:sidi/constant/constants.dart';

import 'timeslotscreen.dart';
import '../services/favorite_service.dart';

class DetailedArtistScreen extends StatefulWidget {
  const DetailedArtistScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    required this.role,
    required this.imageUrl,
    this.description = '',
    this.services = const [],
    this.rating = 0.0,
  });

  final String artistId;
  final String artistName;
  final String role;
  final String imageUrl;
  final String description;
  final List<Map<String, dynamic>> services;
  final double rating;
  @override
  State<DetailedArtistScreen> createState() => _DetailedArtistScreenState();
}

class _DetailedArtistScreenState extends State<DetailedArtistScreen> {
  /// Submits a rating and review for a beautician.
  ///
  /// [beauticianId] - The ID of the beautician to rate.
  /// [rating] - The rating value (e.g., 1-5).
  /// [reviewText] - The review comment.
  /// Returns true if successful, false otherwise.

  Future<bool> submitBeauticianRating({
    required String beauticianId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      final dio = Dio();
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('No auth token found.');
        return false;
      }
      final response = await dio.post(
        'https://sidi.mobilegear.co.in/api/mobileapp/reviews/beautician',
        data: {
          'beauticianId': beauticianId,
          'rating': rating,
          'reviewText': reviewText,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit rating: \nStatus: \${response.statusCode}, Body: \${response.data}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting rating: \n$e');
      return false;
    }
  }

  int? _userRating;
  bool _isSubmittingRating = false;

  Future<void> _showRatingDialog(int rating) async {
    setState(() {
      _isSubmittingRating = true;
    });
    final success = await submitBeauticianRating(
      beauticianId: widget.artistId,
      rating: rating,
      reviewText: 'Great service!', // Dummy review text
    );
    setState(() {
      _isSubmittingRating = false;
      _userRating = rating;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Thank you for your feedback!'
                : 'Failed to submit rating.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  bool isFavorited = false;
  bool isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    setState(() => isLoadingFavorite = true);

    try {
      final result = await FavoriteService.isFavorite(widget.artistId);
      if (mounted) {
        setState(() => isFavorited = result);
      }
    } catch (e) {
      debugPrint('Favorite check error: $e');
    } finally {
      if (mounted) setState(() => isLoadingFavorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (isLoadingFavorite) return;

    setState(() => isLoadingFavorite = true);

    try {
      final response = isFavorited
          ? await FavoriteService.removeFromFavorites(widget.artistId)
          : await FavoriteService.addToFavorites(widget.artistId);

      if (response['success'] == true) {
        setState(() => isFavorited = !isFavorited);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? ''),
            backgroundColor: response['success'] == true
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Toggle error: $e');
    } finally {
      if (mounted) setState(() => isLoadingFavorite = false);
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
            backgroundColor: kBackgroundLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: kEspressoColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              isLoadingFavorite
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : kEspressoColor,
                      ),
                      onPressed: _toggleFavorite,
                    ),
            ],
            expandedHeight: MediaQuery.of(context).size.height * 0.44,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 60),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          kBackgroundLight.withOpacity(0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 32),

                /// ROLE
                const SizedBox(height: 8),

                /// NAME
                Row(
                  children: [
                    Text(
                      widget.artistName,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                    Spacer(),
                    // Interactive Rating
                    _isSubmittingRating
                        ? const SizedBox(
                            width: 80,
                            height: 22,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Row(
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              final isFilled =
                                  (_userRating ?? widget.rating) >= starIndex;
                              return GestureDetector(
                                onTap: () => _showRatingDialog(starIndex),
                                child: Icon(
                                  isFilled ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              );
                            }),
                          ),
                  ],
                ),
                Text(
                  widget.role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: kWarmGrey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                /// DESCRIPTION
                Text(
                  widget.description.isNotEmpty
                      ? widget.description
                      : 'No description available.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.8,
                    color: opacity(kEspressoColor, 0.75),
                  ),
                ),

                const SizedBox(height: 40),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Services',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SERVICES LIST
                if (widget.services.isEmpty)
                  const Text(
                    'No services available',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...widget.services.map((service) {
                    return _buildServiceRow(context, service);
                  }).toList(),

                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, Map<String, dynamic> service) {
    final id = service['id']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service['title'] ?? '',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              Text(service['price']?.toString() ?? ''),
            ],
          ),
          const SizedBox(height: 6),
          Text(service['description'] ?? ''),
          const SizedBox(height: 10),

          /// BOOK BUTTON
          FilledButton(
            onPressed: id.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectTimeSlotScreen(
                          serviceId: id,
                          title: service['title'] ?? '',
                          price: service['price']?.toString() ?? '',
                          duration: 'N/A',
                          imageUrl: widget.imageUrl,
                        ),
                      ),
                    );
                  },
            child: const Text('BOOK'),
          ),

          const Divider(),
        ],
      ),
    );
  }
}
