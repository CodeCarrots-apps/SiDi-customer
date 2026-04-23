// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:dio/dio.dart';
import 'package:sidi/models/stylist.dart';
import 'dart:async';

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
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<List<Map<String, dynamic>>> _subcategoriesFuture;
  late Stream<List<Map<String, dynamic>>> _servicesStream;
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _allSubcategories = [];
  List<Map<String, dynamic>> _allServices = [];
  final _servicesStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Timer? _pollingTimer;

  bool get _hasSearchQuery =>
      _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty;

  String get _searchQuery => _currentSearchQuery?.toLowerCase() ?? '';

  List<String> get filters {
    return [
      'All Services',
      ..._allCategories.map((cat) => cat['name'] as String).toList(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.initialSearchQuery?.trim();
    _searchController = TextEditingController(text: _currentSearchQuery ?? '');
    _isSearchActive = _currentSearchQuery?.isNotEmpty ?? false;
    _categoriesFuture = _fetchCategories();
    _subcategoriesFuture = _fetchSubcategories();
    _servicesStream = _servicesStreamController.stream;
    _startPollingServices();
  }

  void _startPollingServices() {
    // Fetch immediately, then every 5 seconds
    _fetchServicesToStream();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      debugPrint('[DetailedServiceScreen] Polling for latest services...');
      _fetchServicesToStream();
    });
  }

  Future<void> _fetchServicesToStream() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/services',
      );
      if (response.statusCode == 200 && response.data is List) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _allServices = data;
        });
        _servicesStreamController.add(data);
      } else {
        _servicesStreamController.addError('Failed to load services');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      _servicesStreamController.addError(e);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/categories',
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _allCategories = data;
          // Set initial category if provided
          if (widget.initialCategory != null) {
            final initialIndex = filters.indexOf(widget.initialCategory!);
            if (initialIndex != -1) {
              _selectedFilterIndex = initialIndex;
            }
          }
        });
        return data;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSubcategories() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://sidi.mobilegear.co.in/api/subcategories',
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _allSubcategories = data;
        });
        return data;
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pollingTimer?.cancel();
    _servicesStreamController.close();
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

  List<Map<String, dynamic>> get _searchFilteredServices {
    if (!_hasSearchQuery) return [];
    return _allServices.where((service) {
      final title = (service['name'] ?? '').toString().toLowerCase();
      final price = (service['price'] ?? '').toString().toLowerCase();
      final duration = (service['duration'] ?? '').toString().toLowerCase();
      final categoryName = service['category'] is Map
          ? (service['category']['name'] ?? '').toString().toLowerCase()
          : (service['category'] ?? '').toString().toLowerCase();
      final query = _searchQuery;
      return title.contains(query) ||
          price.contains(query) ||
          duration.contains(query) ||
          categoryName.contains(query);
    }).toList();
  }

  // Colors are provided by lib/constant/constants.dart

  List<Map<String, dynamic>> get _categoryServices {
    if (_selectedFilterIndex == 0) {
      return _allServices;
    }

    final selectedCategory = filters[_selectedFilterIndex];
    return _allServices.where((service) {
      final categoryName = service['category'] is Map
          ? service['category']['name']
          : service['category'];
      return categoryName == selectedCategory;
    }).toList();
  }

  List<String> get _subFilters {
    if (_allSubcategories.isEmpty) {
      return ['All'];
    }

    final selectedCategory = _selectedFilterIndex == 0
        ? null
        : filters[_selectedFilterIndex];

    // Filter subcategories by the selected category
    final filteredSubcategories = _allSubcategories.where((sub) {
      if (selectedCategory == null) return true;
      final categoryName = sub['category'] is Map
          ? sub['category']['name']
          : sub['category'];
      return categoryName == selectedCategory;
    }).toList();

    final subCategoryNames = filteredSubcategories
        .map((sub) => sub['name'] as String? ?? 'Other')
        .toSet()
        .toList();
    subCategoryNames.sort();
    return ['All', ...subCategoryNames];
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

  void _openServiceDetails(Map<String, dynamic> service) {
    // Support multiple beauticians (stylists) if available
    List<Stylist> stylists = [];
    if (service['beauticians'] is List) {
      stylists = (service['beauticians'] as List)
          .whereType<Map<String, dynamic>>()
          .map(
            (beauticianMap) => Stylist(
              id: beauticianMap['_id'] ?? '',
              fullName: beauticianMap['fullName'] ?? '',
              phoneNumber: beauticianMap['phoneNumber'] ?? '',
              bio: beauticianMap['bio'] ?? '',
              skills: beauticianMap['skills'] != null
                  ? List<String>.from(beauticianMap['skills'])
                  : <String>[],
              experience: beauticianMap['experience'] ?? 0,
              tier: beauticianMap['tier'] ?? '',
              isVerified: beauticianMap['isVerified'] ?? false,
              status: beauticianMap['status'] ?? '',
              rating: (beauticianMap['rating'] ?? 0).toDouble(),
              profileImage:
                  (beauticianMap['profileImage'] != null &&
                      beauticianMap['profileImage'].toString().isNotEmpty)
                  ? 'https://sidi.mobilegear.co.in${beauticianMap['profileImage']}'
                  : '',
              city: beauticianMap['city'] ?? '',
            ),
          )
          .toList();
    } else if (service['beautician'] is Map<String, dynamic>) {
      final beauticianMap = service['beautician'] as Map<String, dynamic>;
      stylists.add(
        Stylist(
          id: beauticianMap['_id'] ?? '',
          fullName: beauticianMap['fullName'] ?? '',
          phoneNumber: beauticianMap['phoneNumber'] ?? '',
          bio: beauticianMap['bio'] ?? '',
          skills: beauticianMap['skills'] != null
              ? List<String>.from(beauticianMap['skills'])
              : <String>[],
          experience: beauticianMap['experience'] ?? 0,
          tier: beauticianMap['tier'] ?? '',
          isVerified: beauticianMap['isVerified'] ?? false,
          status: beauticianMap['status'] ?? '',
          rating: (beauticianMap['rating'] ?? 0).toDouble(),
          profileImage:
              (beauticianMap['profileImage'] != null &&
                  beauticianMap['profileImage'].toString().isNotEmpty)
              ? 'https://sidi.mobilegear.co.in${beauticianMap['profileImage']}'
              : '',
          city: beauticianMap['city'] ?? '',
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
          description: service['description'] ?? '',
          serviceId: service['_id'] ?? '6600',
          title: service['name'] ?? 'Service',
          price: '₹${service['price'] ?? '0'}',
          duration: '${service['duration'] ?? 'N/A'} mins',
          imageUrl: service['image2'] ?? '',
          stylists: stylists,
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
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('Error loading categories: ${snapshot.error}');
              }
              return SliverToBoxAdapter(child: _buildFilterChips());
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _subcategoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 46,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('Error loading subcategories: ${snapshot.error}');
              }
              return SliverToBoxAdapter(child: _buildSubFilterChips());
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _servicesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('Error loading services: ${snapshot.error}');
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Text(
                      'Error loading services.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: kWarmGrey600,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              }
              final services = snapshot.data ?? [];
              final filtered = _hasSearchQuery
                  ? services.where((service) {
                      final title = (service['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final price = (service['price'] ?? '')
                          .toString()
                          .toLowerCase();
                      final duration = (service['duration'] ?? '')
                          .toString()
                          .toLowerCase();
                      final categoryName = service['category'] is Map
                          ? (service['category']['name'] ?? '')
                                .toString()
                                .toLowerCase()
                          : (service['category'] ?? '')
                                .toString()
                                .toLowerCase();
                      final query = _searchQuery;
                      return title.contains(query) ||
                          price.contains(query) ||
                          duration.contains(query) ||
                          categoryName.contains(query);
                    }).toList()
                  : _selectedFilterIndex == 0
                  ? services
                  : services.where((service) {
                      final categoryName = service['category'] is Map
                          ? service['category']['name']
                          : service['category'];
                      return categoryName == filters[_selectedFilterIndex];
                    }).toList();
              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
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
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildServiceCard(filtered[index]);
                  }, childCount: filtered.length),
                ),
              );
            },
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

  Widget _buildServiceCard(Map<String, dynamic> service) {
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
                  child: Image.network(
                    (service["image1"] ?? service["image"] ?? '') as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      (service["name"] ?? service["title"] ?? 'Service')
                          as String,
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
                    '₹${service["price"] ?? 0}',
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
                    '${service["duration"] ?? 'N/A'} MINS',
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
