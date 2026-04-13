import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'detailedservicescreen.dart';
import 'locationsearchscreen.dart';
import 'notificationsscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Colors are provided by lib/constant/constants.dart
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

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  Future<void> _openDetailedServices() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DetailedServiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 76,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            title: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: opacity(kCharcoalColor, 0.7),
                  ),
                  onPressed: _openLocationSearch,
                ),
                const SizedBox(width: 4),
                Text(
                  _selectedLocation,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                    color: kCharcoalColor,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(child: _buildHeroSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(child: _buildServicesSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(child: _buildCuratedSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.network(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuAhaWq1M13518DNZyCPQ9g4KOQRTAht8dZj5D874IbfzvkqszpLXlucjRhYezVs-_lJLiWAVHI9qI03t19Y8J7k2BgdDzQWlEngeqMMV1VLwhE0APclHMHm1VZCRX1lb-FVx6KM61B6XsFJZN8ft8CwzFZVTZo2xGzdp0GlXvaPbhZFTDVh_MfrckXWfO8Ahzcqi-KhgaMct57N4TmBn7L22sCcgVACr_9Mgi9SS8GgHQGRIjPFSj_MzAUg7B25s1FLULVBmrCCIcg",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SUMMER EDITORIAL",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Effortless luxury,\ndelivered to you.",
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kEspressoColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailedServiceScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "BOOK NOW",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = [
      {
        "title": "Hair",
        "image":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDhwtGGswF8f6oTbJt2kPjLH2OE_akDqZF5tTdlemziRZa77tptBWoFGbY7Ye2mQJ4LvbpdRvmqt4ICTx9hvIpfO1L2MiY_TAM3lRf1oDavv95dUHldy4Sm88cSbvjYys7JOzthV1BW8Mn1fMQBMdnK3c8rg-mZIC2JuWW_UNm-pa_-S_r-7ryJ1bE8m_15thFYV_PmFtWGR5EINnVMm59lJj9zAj1LLTjuwX6MEV-hngrVkotbtwMAZkjEzsbqaJdPCPsNyi4vs6M",
      },
      {
        "title": "Nails",
        "image":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCM7VqNL24-1BJCkoR5omEK6Nbi4AX2r25Tw_eb1lWxzgzj7sh6DG9FQSvdCLlSnLVCD8XgsoToon2f4b-WN9oqXp3y8LVQb4pMvMgd2jOYF-JE0nAsT_VX08W4sQGvRll_Tcft7ccwS-Geb_-ci3ICA3cqxuqf8WjQLrn-xoaFuh9J-NNeETjMhG3RqQ4pLIKCHljGVFQ57P1BLnM9GCfKGF6nz8F6mQythsAbYDX09UbkbOmepidomwEE43_-NUrztXGyoopmdlE",
      },
      {
        "title": "Facials",
        "image":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuBb5fgSRgildruAaNPWMWA4TWVdJfvnAW1CoGxol8Z2Uqc0VvCHny5kuhkJ8Lh2AS9f020uzn4ROd0xpbhBogHLNjJXRIDoPu--RjlORLTFK7P2x8QWXaIgwtDMDlReGJLPSGfnKksfUtmtDyVwcGBKEOoo2EsgvFn0wnelZj3MlWhsHrDRsDt_heDwwAzv6IBgn9mTBWjvT-bC1EnrXVCKeuWVyU-3qoYbXxmkre4AP0gH6xz7Q4yX1qUW4k69r-xRR8fLN41Jhy4",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Our Services",
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: List.generate(services.length, (index) {
              final service = services[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == services.length - 1 ? 0 : 12,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _openDetailedServices,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 160,
                            child: Image.network(
                              service["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          service["title"]!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCuratedSection() {
    final items = [
      {
        "tag": "Morning Glow",
        "title": "The 60-Minute Refresh",
        "subtitle": "Facial & Lymphatic Massage",
        "image":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCjD3Idcb9NwaKXy001FZBgWYb-DgyMVlYrDj7uZOEaJj6AVbNvATlq8Ivohs072AF9MuIquo9xyLLPMepeVLRbrZvshrVePIJ9vLLfQH7eghBjNqedHkwCNgascLhoJ0i5xGz2gmkT1wpCSGgp1J9U12Dk_DldmNTzrPfoHXqNHWurJJr0v2ARZF3ujQDcunGu3OJI9ib9MUKXg_uCntevkfCLnkbeZxRagDq1yx2F8Lt1qJlk8hZT9Q1NhTYeqrHG6JcDm0JpAUE",
      },
      {
        "tag": "Night Routine",
        "title": "Deep Sleep Therapy",
        "subtitle": "Full Body Relaxation",
        "image":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuAak35w8RQZUxL5yYqAE1NHnvj8xEqXP3aTEY38GDI0k3rdA8Kj6zayxBazwKLFmv-Q-HTZ-9_AhtjV0lYkbE6kR5A8N3FLacPhanDY9AFaAdeDYrtwMG9MGoEtX-32zmFpIKa0ShusjITSMVFVd19-L2h6xvTXijda9zXEoPyVOoXlJOjhc8BzBb67kfjY0YE4lqnaGxjxzsnCBfOmtua4cOyXv7ScN_hUh4CwhJ-1J6F2kalpWt1bDKpeu9yJzwHiWweufPhij1A",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Curated for You",
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 320,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth * 0.72).clamp(
                230.0,
                320.0,
              );
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, index) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _openDetailedServices,
                    child: SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Image.network(
                                item["image"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item["tag"]!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item["title"]!,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item["subtitle"]!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
