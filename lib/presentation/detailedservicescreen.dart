import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'servicedetailscreen.dart';

class DetailedServiceScreen extends StatefulWidget {
  const DetailedServiceScreen({
    super.key,
    this.initialSearchQuery,
    this.initialCategory,
  });

  final String? initialSearchQuery;
  final String? initialCategory;

  @override
  State<DetailedServiceScreen> createState() => _DetailedServiceScreenState();
}

class _DetailedServiceScreenState extends State<DetailedServiceScreen> {
  int _selectedFilterIndex = 0;
  int _selectedSubFilterIndex = 0;
  bool _isSearchActive = false;
  String? _currentSearchQuery;
  late final TextEditingController _searchController;

  bool get _hasSearchQuery =>
      _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty;

  String get _searchQuery => _currentSearchQuery?.toLowerCase() ?? '';

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.initialSearchQuery?.trim();
    _searchController = TextEditingController(text: _currentSearchQuery ?? '');
    _isSearchActive = _currentSearchQuery?.isNotEmpty ?? false;

    if (widget.initialCategory != null) {
      final initialIndex = filters.indexOf(widget.initialCategory!);
      if (initialIndex != -1) {
        _selectedFilterIndex = initialIndex;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _currentSearchQuery = value.trim();
    });
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _currentSearchQuery = null;
        _searchController.clear();
      }
    });
  }

  List<Map<String, String>> get _searchFilteredServices {
    if (!_hasSearchQuery) return [];
    return services.where((service) {
      final title = service['title']!.toLowerCase();
      final price = service['price']!.toLowerCase();
      final duration = service['duration']!.toLowerCase();
      final category = service['category']!.toLowerCase();
      final subCategory = service['subCategory']!.toLowerCase();
      final query = _searchQuery;
      return title.contains(query) ||
          price.contains(query) ||
          duration.contains(query) ||
          category.contains(query) ||
          subCategory.contains(query);
    }).toList();
  }

  // Colors are provided by lib/constant/constants.dart

  final List<String> filters = ["All Services", "Hair", "Nails", "Facials"];

  final List<Map<String, String>> services = [
    {
      "id": "6601",
      "category": "Hair",
      "subCategory": "Styling",
      "title": "Signature Blowout",
      "price": "\$85",
      "duration": "60 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDhwtGGswF8f6oTbJt2kPjLH2OE_akDqZF5tTdlemziRZa77tptBWoFGbY7Ye2mQJ4LvbpdRvmqt4ICTx9hvIpfO1L2MiY_TAM3lRf1oDavv95dUHldy4Sm88cSbvjYys7JOzthV1BW8Mn1fMQBMdnK3c8rg-mZIC2JuWW_UNm-pa_-S_r-7ryJ1bE8m_15thFYV_PmFtWGR5EINnVMm59lJj9zAj1LLTjuwX6MEV-hngrVkotbtwMAZkjEzsbqaJdPCPsNyi4vs6M",
    },
    {
      "id": "6602",
      "category": "Hair",
      "subCategory": "Treatment",
      "title": "Silk Press & Finish",
      "price": "\$95",
      "duration": "70 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAhaWq1M13518DNZyCPQ9g4KOQRTAht8dZj5D874IbfzvkqszpLXlucjRhYezVs-_lJLiWAVHI9qI03t19Y8J7k2BgdDzQWlEngeqMMV1VLwhE0APclHMHm1VZCRX1lb-FVx6KM61B6XsFJZN8ft8CwzFZVTZo2xGzdp0GlXvaPbhZFTDVh_MfrckXWfO8Ahzcqi-KhgaMct57N4TmBn7L22sCcgVACr_9Mgi9SS8GgHQGRIjPFSj_MzAUg7B25s1FLULVBmrCCIcg",
    },
    {
      "id": "6603",
      "category": "Nails",
      "subCategory": "Manicure",
      "title": "Signature Silk Manicure",
      "price": "\$85",
      "duration": "60 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBBYEO4G9e9SXUHhmUpFTOV3PWtGQs3jD24uVhrTk9zjIG1f1ubaugSCBH32kItXCAlNa9K1asoJoRe5TWj714hzf7UDOt-Bnnx8l5j4MFVz515ceZGByzqOjjhClsxjTZ9J9_uV33TJ8VYDDRot4IOQ4Azx9W_oOJT3XickZxxNfJG69MnRQfMDYYHnSAgRgqfNqPPWvt1v4Hi1fNfOIzF1VsumU8wvA_vrl0Atna8qrWl-CFGzCdndtBqy-7fYCwa_LNs-xT8Z78",
    },
    {
      "id": "6604",
      "category": "Nails",
      "subCategory": "Pedicure",
      "title": "Luxury Spa Pedicure",
      "price": "\$110",
      "duration": "75 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDOnlzfJ5hytmdW4ELdw6Ok_SOYRYxWdVOdaPEBl2PZIl8csFiA9YcMkfFd6F_-4QYpyIIq1vJZra5ZX9AsrbPX6CfJdS7nHLizeUa6oY3Roh3FgwfnKeurxbc3kl9hV-Mif5hRf9qsLgSXKhtvZpWQfQzKUo2Rk5lxo-V2-tSZcnqNgoCOLm24oZdjHaXhpNaLvRo9qMzOoCLIwbicwmcX-YlSmQ3FbSv4iD8ZzAvPZSgl0arTWqYC7o5SwnwKEfQJEhy0lDN0JEM",
    },
    {
      "category": "Nails",
      "subCategory": "Nail Art",
      "title": "Editorial Nail Art",
      "price": "\$130",
      "duration": "90 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCtJWLbhrrHtqz2qPSquBG_yi6xBKYNNV4Q21-bQ0EWvtOvKQHxfqb1oH9z483HzXLIrbB-QW723AXgVOQHeaNpCLiTlw9HgMOFR2Be1W0uxOCBrUUZt00SOAAMUFhYh3IQjuBGdQHHTkIEcOHZ4aNaiusM1aavDSfafktZ-KripjaeGSG4Uy4V0PIpXIXzBM-4cIXIS9jO_m4twy3Gc3RQcsNKQ6WdoRUf6wR4c0rP_K54o5hCE7hYPM7fyjWR5S1bpGiexO8nSBA",
    },
    {
      "id": "6605",
      "category": "Facials",
      "subCategory": "Glow",
      "title": "Morning Glow Facial",
      "price": "\$120",
      "duration": "75 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCjD3Idcb9NwaKXy001FZBgWYb-DgyMVlYrDj7uZOEaJj6AVbNvATlq8Ivohs072AF9MuIquo9xyLLPMepeVLRbrZvshrVePIJ9vLLfQH7eghBjNqedHkwCNgascLhoJ0i5xGz2gmkT1wpCSGgp1J9U12Dk_DldmNTzrPfoHXqNHWurJJr0v2ARZF3ujQDcunGu3OJI9ib9MUKXg_uCntevkfCLnkbeZxRagDq1yx2F8Lt1qJlk8hZT9Q1NhTYeqrHG6JcDm0JpAUE",
    },
    {
      "id": "6606",
      "category": "Facials",
      "subCategory": "Therapy",
      "title": "Deep Sleep Therapy",
      "price": "\$140",
      "duration": "90 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAak35w8RQZUxL5yYqAE1NHnvj8xEqXP3aTEY38GDI0k3rdA8Kj6zayxBazwKLFmv-Q-HTZ-9_AhtjV0lYkbE6kR5A8N3FLacPhanDY9AFaAdeDYrtwMG9MGoEtX-32zmFpIKa0ShusjITSMVFVd19-L2h6xvTXijda9zXEoPyVOoXlJOjhc8BzBb67kfjY0YE4lqnaGxjxzsnCBfOmtua4cOyXv7ScN_hUh4CwhJ-1J6F2kalpWt1bDKpeu9yJzwHiWweufPhij1A",
    },
  ];

  List<Map<String, String>> get _categoryServices {
    if (_selectedFilterIndex == 0) {
      return services;
    }

    final selectedCategory = filters[_selectedFilterIndex];
    return services
        .where((service) => service['category'] == selectedCategory)
        .toList();
  }

  List<String> get _subFilters {
    final uniqueSubCategories = _categoryServices
        .map((service) => service['subCategory'] ?? 'Other')
        .toSet()
        .toList();
    uniqueSubCategories.sort();
    return ['All', ...uniqueSubCategories];
  }

  List<Map<String, String>> get _filteredServices {
    if (_hasSearchQuery) {
      return _searchFilteredServices;
    }

    final categoryFiltered = _categoryServices;
    if (_selectedSubFilterIndex == 0) {
      return categoryFiltered;
    }

    final selectedSubCategory = _subFilters[_selectedSubFilterIndex];
    return categoryFiltered
        .where((service) => service['subCategory'] == selectedSubCategory)
        .toList();
  }

  String get _screenTitle {
    if (_hasSearchQuery) {
      return 'SEARCH RESULTS';
    }
    if (_selectedFilterIndex == 0) {
      return 'OUR SERVICES';
    }
    return filters[_selectedFilterIndex].toUpperCase();
  }

  void _openServiceDetails(Map<String, String> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
          serviceId: service['id'] ?? '6600',
          title: service['title'] ?? 'Service',
          price: service['price'] ?? '\$0',
          duration: service['duration'] ?? 'N/A',
          imageUrl: service['image'] ?? '',
        ),
      ),
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
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              _screenTitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleSearchMode,
                icon: Icon(
                  _isSearchActive ? Icons.close : Icons.search,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (_isSearchActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search services',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _currentSearchQuery?.isNotEmpty == true
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _updateSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
            ),
          if (_hasSearchQuery)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: Text(
                  'Search results for "${_currentSearchQuery}"',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: kWarmGrey600,
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverToBoxAdapter(child: _buildSubFilterChips()),
          if (_filteredServices.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Text(
                  _hasSearchQuery
                      ? 'No services match your search. Try a different keyword.'
                      : 'No services available for the selected filters.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: kWarmGrey600,
                    height: 1.5,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildServiceCard(_filteredServices[index]);
                }, childCount: _filteredServices.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFilterIndex = index;
              _selectedSubFilterIndex = 0;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kEspressoColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                filters[index].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubFilterChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _subFilters.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedSubFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kNeutralGoldColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _subFilters[index].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: selected ? kEspressoColor : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openServiceDetails(service),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kWarmGrey100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 11,
                  child: Image.network(service["image"]!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      service["title"]!,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    service["price"]!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service["duration"]!.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: kPrimaryBeige,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openServiceDetails(service),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "VIEW DETAILS",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
