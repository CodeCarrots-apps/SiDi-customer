import 'package:flutter/material.dart';
import 'package:sidi/models/stylist.dart';
import 'package:sidi/presentation/detailedartistscreen.dart';
// If you want to use Beautician model, import it as well:
// import 'package:sidi/models/beautician_model.dart';

class StylistsCard extends StatelessWidget {
  final Stylist stylist;
  // If you want to use Beautician, you can add:
  // final Beautician? beautician;

  const StylistsCard({super.key, required this.stylist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            stylist.profileImage.isNotEmpty
                ? stylist.profileImage
                // : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(stylist.fullName)}',
                : 'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
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
                stylist.skills.isNotEmpty
                    ? stylist.skills.join(', ')
                    : 'Beautician',
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
                            services: [],
                            role: stylist.skills.isNotEmpty
                                ? stylist.skills.join(', ')
                                : 'Beautician',
                            imageUrl: stylist.profileImage.isNotEmpty
                                ? stylist.profileImage
                                : 'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
                            // Optionally pass description, services, etc.
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
                            rating: stylist.rating,
                            services: [],
                            role: stylist.skills.isNotEmpty
                                ? stylist.skills.join(', ')
                                : 'Beautician',
                            imageUrl: stylist.profileImage.isNotEmpty
                                ? stylist.profileImage
                                : 'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
                            // Optionally pass description, services, etc.
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
            // If you want to show distance, add a distance property to Stylist and use it here.
            // Text(
            //   '• [stylist.distance.toStringAsFixed(1)] MI',
            //   style: const TextStyle(fontSize: 11, color: Colors.grey),
            // ),
          ],
        ),
      ],
    );
  }
}
