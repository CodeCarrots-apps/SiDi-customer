import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/user_profile.dart';
import 'package:sidi/presentation/detailedartistscreen.dart';

class FavoriteStylistScreen extends StatelessWidget {
  final List<FavoriteStylist> favoriteStylists;

  FavoriteStylistScreen({super.key, List<FavoriteStylist>? favoriteStylists})
    : favoriteStylists = favoriteStylists ?? _fallbackFavoriteStylists;

  static final List<FavoriteStylist> _fallbackFavoriteStylists = [
    FavoriteStylist(
      id: '1',
      fullName: 'Eleanor Vance',
      profileImage:
          'https://i.pinimg.com/1200x/2f/3c/e1/2f3ce168140f0d05426428b4fa5b47e2.jpg',
      rating: 4.9,
      tier: 'Master Colorist',
    ),
    FavoriteStylist(
      id: '2',
      fullName: 'Julian Thorne',
      profileImage:
          'https://i.pinimg.com/736x/f5/bd/64/f5bd64313473df52285458b7f9d11de9.jpg',
      rating: 4.8,
      tier: 'Precision Cutting',
    ),
    FavoriteStylist(
      id: '3',
      fullName: 'Sophie Laurent',
      profileImage:
          'https://i.pinimg.com/736x/48/b5/e4/48b5e4fe73f26cace03677976462e27e.jpg',
      rating: 4.7,
      tier: 'Extensions Specialist',
    ),
    FavoriteStylist(
      id: '4',
      fullName: 'Marcus Sterling',
      profileImage:
          'https://i.pinimg.com/736x/9f/58/9e/9f589ebb0fb8bf43b0c63336b3887f84.jpg',
      rating: 4.9,
      tier: 'Balayage Expert',
    ),
  ];

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ListView.separated(
            itemCount: favoriteStylists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final stylist = favoriteStylists[index];
              return _FavoriteStylistCard(stylist: stylist);
            },
          ),
        ),
      ),
    );
  }
}

class _FavoriteStylistCard extends StatelessWidget {
  final FavoriteStylist stylist;

  const _FavoriteStylistCard({required this.stylist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailedArtistScreen(
              artistName: stylist.fullName,
              role: stylist.tier,
              imageUrl: stylist.profileImage,
            ),
          ),
        );
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
