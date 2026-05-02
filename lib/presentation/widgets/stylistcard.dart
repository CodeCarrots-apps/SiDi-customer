import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/models/stylist.dart';
import 'package:sidi/presentation/detailedartistscreen.dart';
// If you want to use Beautician model, import it as well:
// import 'package:sidi/models/beautician_model.dart';

class StylistsCard extends StatelessWidget {
  final Stylist stylist;
  // If you want to use Beautician, you can add:
  // final Beautician? beautician;

  const StylistsCard({super.key, required this.stylist});

  void _openDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailedArtistScreen(
          artistId: stylist.id,
          artistName: stylist.fullName,
          description: stylist.bio,
          rating: stylist.rating,
          services: const [],
          role: stylist.skills.isNotEmpty
              ? stylist.skills.join(', ')
              : 'Beautician',
          imageUrl: stylist.profileImage.isNotEmpty
              ? stylist.profileImage
              : 'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topSkills = stylist.skills.take(2).toList();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: const Color(0x22191816),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        stylist.profileImage.isNotEmpty
                            ? stylist.profileImage
                            : 'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 78,
                          height: 78,
                          color: const Color(0xFFF1EEEA),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF8C857E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stylist.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 25,
                              height: 1,
                              color: const Color(0xFF1E1B17),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            stylist.skills.isNotEmpty
                                ? stylist.skills.join(', ')
                                : 'Professional Beautician',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              letterSpacing: 0.2,
                              color: const Color(0xFF6F675E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stylist.rating >= 4.5
                                  ? const Color(0xFFEFF9F2)
                                  : const Color(0xFFF5F1EB),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              stylist.rating >= 4.5
                                  ? 'Top rated choice'
                                  : 'Loved by customers',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: stylist.rating >= 4.5
                                    ? const Color(0xFF1A7F37)
                                    : const Color(0xFF8A7156),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFD4A53A),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            stylist.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFA37412),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (topSkills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topSkills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4EF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFE8DED0),
                              ),
                            ),
                            child: Text(
                              skill,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF6F675E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openDetails(context),
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                        ),
                        label: const Text('Book now'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: const Color(0xFF1F1B16),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => _openDetails(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(96, 44),
                        side: const BorderSide(color: Color(0xFFDBD2C5)),
                        foregroundColor: const Color(0xFF4B443B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
