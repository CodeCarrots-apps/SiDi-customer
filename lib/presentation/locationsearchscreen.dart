import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:sidi/constant/constants.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  final Location _location = Location();

  final List<_PlaceResult> _results = [];
  Timer? _debounce;

  bool _isSearching = false;
  bool _isFetchingCurrent = false;
  String? _errorText;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results.clear();
        _errorText = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorText = null;
    });

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': trimmed,
          'format': 'jsonv2',
          'limit': 10,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'SiDiCustomerApp/1.0 (location-search)',
            'Accept-Language': 'en',
          },
        ),
      );

      final data = response.data as List<dynamic>;
      final mapped = data
          .map((item) => _PlaceResult.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _results
          ..clear()
          ..addAll(mapped);
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSearching = false;
        _errorText = 'Could not search locations. Please try again.';
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPlaces(value);
    });
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingCurrent = true;
      _errorText = null;
    });

    try {
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location service disabled');
        }
      }

      var permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
      }
      if (permissionStatus != PermissionStatus.granted &&
          permissionStatus != PermissionStatus.grantedLimited) {
        throw Exception('Location permission denied');
      }

      final current = await _location.getLocation();
      final lat = current.latitude;
      final lon = current.longitude;

      if (lat == null || lon == null) {
        throw Exception('Unable to fetch current coordinates');
      }

      final response = await _dio.get(
        'https://sidi.mobilegear.co.in/api/mobileapp/services/location',
        queryParameters: {'lat': lat, 'lng': lon},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to fetch location details');
      }

      final location = data['location'] as Map<String, dynamic>;
      final result = _PlaceResult(
        name: (location['city'] as String?) ?? 'Unknown',
        displayName: (location['address'] as String?) ?? 'Unknown address',
        latitude: lat,
        longitude: lon,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isFetchingCurrent = false;
        _searchController.text = result.displayName;
        _results
          ..clear()
          ..add(result);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isFetchingCurrent = false;
        _errorText =
            'Could not fetch current location. Please check permission/service.';
      });
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
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            title: Text(
              'Search Location',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: kCharcoalColor,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search area, city, or address',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: kWarmGrey600,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : (_searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _results.clear();
                                        _errorText = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                : null),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: kWarmGrey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: kWarmGrey200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isFetchingCurrent
                          ? null
                          : _fetchCurrentLocation,
                      icon: _isFetchingCurrent
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isFetchingCurrent
                            ? 'Fetching Current Location...'
                            : 'Use Current Location',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kEspressoColor,
                        side: BorderSide(color: kWarmGrey200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _errorText!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Search for a place to see results',
                  style: GoogleFonts.inter(fontSize: 13, color: kWarmGrey600),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _results[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: const Icon(Icons.place_outlined),
                  title: Text(
                    item.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: kCharcoalColor,
                    ),
                  ),
                  subtitle: Text(
                    'Lat ${item.latitude.toStringAsFixed(5)}, '
                    'Lng ${item.longitude.toStringAsFixed(5)}',
                    style: GoogleFonts.inter(fontSize: 11, color: kWarmGrey600),
                  ),
                  trailing: const Icon(Icons.north_east, size: 18),
                  onTap: () {
                    Navigator.pop(context, {
                      'name': item.name,
                      'displayName': item.displayName,
                      'latitude': item.latitude,
                      'longitude': item.longitude,
                    });
                  },
                );
              }, childCount: _results.length),
            ),
        ],
      ),
    );
  }
}

class _PlaceResult {
  const _PlaceResult({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String displayName;
  final double latitude;
  final double longitude;

  factory _PlaceResult.fromJson(Map<String, dynamic> json) {
    return _PlaceResult(
      name: (json['name'] as String?) ?? 'Unknown',
      displayName: (json['display_name'] as String?) ?? 'Unknown location',
      latitude: double.tryParse((json['lat'] ?? '0').toString()) ?? 0,
      longitude: double.tryParse((json['lon'] ?? '0').toString()) ?? 0,
    );
  }
}
