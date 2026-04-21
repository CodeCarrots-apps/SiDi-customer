import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'timeslotscreen.dart';
import '../services/favorite_service.dart';

class DetailedArtistScreen extends StatefulWidget {
  const DetailedArtistScreen({
    super.key,
    this.artistId = "",
    this.artistName = 'Elena Rossi',
    this.role = 'Master Stylist',
    this.imageUrl =
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&q=80',
  });

  final String artistId;
  final String artistName;
  final String role;
  final String imageUrl;

  @override
  State<DetailedArtistScreen> createState() => _DetailedArtistScreenState();
}

class _DetailedArtistScreenState extends State<DetailedArtistScreen> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final favorites = await FavoriteService.getFavorites();
    setState(() {
      isFavorited = favorites.any((fav) => fav['id'] == widget.artistId);
    });
  }

  Future<void> _toggleFavorite() async {
    final response = isFavorited
        ? await FavoriteService.removeFromFavorites(widget.artistId)
        : await FavoriteService.addToFavorites(widget.artistId);
    if (response['success'] == true) {
      setState(() {
        isFavorited = !isFavorited;
      });
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Unknown error'),
          backgroundColor: response['success'] == true
              ? Colors.green
              : Colors.red,
        ),
      );
    }
  }

  static const _services = [
    {
      'id': '6652',
      'title': 'Signature Color',
      'price': '240+',
      'description':
          'A bespoke, multi-dimensional color service that enhances natural movement and luminous depth.',
    },
    {
      'id': '6653',
      'title': 'Precision Cut',
      'price': '140+',
      'description':
          'A sculpted haircut tailored to your facial structure and personal style, with clean lines and soft texture.',
    },
    {
      'id': '6654',
      'title': 'Editorial Styling',
      'price': '110+',
      'description':
          'Polished styling for special occasions that balances modern ease with timeless elegance.',
    },
    {
      'id': '6655',
      'title': 'Scalp Treatment',
      'price': '90+',
      'description':
          'A nourishing ritual that calms, revitalizes, and restores balance to the scalp.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: kEspressoColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: kEspressoColor,
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.share, color: kEspressoColor),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
            centerTitle: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.44,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          kBackgroundLight.withOpacity(0.94),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 32),
                Text(
                  widget.role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: kWarmGrey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.artistName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 44,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: kEspressoColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'With more than fifteen years of experience between Milan and London, ${widget.artistName} creates refined looks rooted in subtlety and precision. Her approach emphasizes the quiet power of detail and contemporary editorial balance.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.8,
                    color: opacity(kEspressoColor, 0.75),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Specializing in techniques that celebrate natural texture, ${widget.artistName} crafts tailored services that feel modern yet enduring, with an emphasis on effortless sophistication.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.8,
                    color: opacity(kEspressoColor, 0.75),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'The Services',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                    Text(
                      'CURATED CARE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: kWarmGrey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ..._services
                    .map((service) => _buildServiceRow(context, service))
                    .toList(),
                const SizedBox(height: 24),
                Text(
                  '“Simplicity is the ultimate sophistication.”',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: opacity(kEspressoColor, 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, Map<String, String> service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service['title']!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kEspressoColor,
                ),
              ),
              Text(
                service['price']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kEspressoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service['description']!,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.7,
              color: opacity(kEspressoColor, 0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 110,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectTimeSlotScreen(
                      serviceId: service['id']!,
                      title: service['title']!,
                      price: service['price']!,
                      duration: 'N/A',
                      imageUrl: widget.imageUrl,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: kEspressoColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'BOOK',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: kWarmGrey200, thickness: 1),
        ],
      ),
    );
  }
}
