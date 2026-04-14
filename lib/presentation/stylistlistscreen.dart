import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/locationsearchscreen.dart'
    show LocationSearchScreen;
import 'detailedartistscreen.dart';
import '../models/stylist.dart';

class StylistListScreen extends StatefulWidget {
  const StylistListScreen({super.key});

  @override
  State<StylistListScreen> createState() => _StylistListScreenState();
}

class _StylistListScreenState extends State<StylistListScreen> {
  String _selectedLocation = 'KOCHI';

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

  final List<Stylist> stylists = const [
    Stylist(
      image:
          'https://i.pinimg.com/736x/36/2d/70/362d7087b1b8367db1c98d3f73f3be3a.jpg',
      name: 'Julianne Vough',
      role: 'MASTER COLORIST',
      rating: 4.9,
      distance: 0.8,
    ),
    Stylist(
      image:
          'https://i.pinimg.com/736x/e3/52/30/e3523011d5dd97b97709e1d83ca75e5b.jpg',
      name: 'Marcus Chen',
      role: 'SKIN SCULPTOR',
      rating: 5.0,
      distance: 1.2,
    ),
    Stylist(
      image:
          'https://i.pinimg.com/1200x/b5/af/0f/b5af0f1fdc01adb5cd55609e7b302de1.jpg',
      name: 'Elena Rodriguez',
      role: 'ARTISTIC DIRECTOR',
      rating: 4.8,
      distance: 2.4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      // appBar: _buildAppBar(),
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
                onTap: _openLocationSearch,

                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _selectedLocation,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: stylists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    return StylistCard(stylist: stylists[index]);
                  },
                ),
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
            stylist.image,
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
                stylist.name,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stylist.role,
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
                            artistName: stylist.name,
                            role: stylist.role,
                            imageUrl: stylist.image,
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
                            artistName: stylist.name,
                            role: stylist.role,
                            imageUrl: stylist.image,
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
            Text(
              '• ${stylist.distance.toStringAsFixed(1)} MI',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
