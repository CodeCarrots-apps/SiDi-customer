import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';

class EnhanceSessionScreen extends StatefulWidget {
  const EnhanceSessionScreen({super.key});

  @override
  State<EnhanceSessionScreen> createState() => _EnhanceSessionScreenState();
}

class _EnhanceSessionScreenState extends State<EnhanceSessionScreen> {
  final Dio _dio = Dio();
  final Set<String> _selectedServiceIds = {};

  bool _isLoading = true;
  String? _errorMessage;
  List<_EnhancementOption> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchAllServices();
  }

  Future<void> _fetchAllServices() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get(
        'https://sidi.mobilegear.co.in/api/services',
      );

      if (response.statusCode == 200 && response.data is List) {
        final services = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(_EnhancementOption.fromJson)
            .toList();

        if (!mounted) return;
        setState(() {
          _services = services;
          if (_selectedServiceIds.isEmpty && services.isNotEmpty) {
            _selectedServiceIds.add(services.first.id);
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load services. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<_EnhancementOption> get _selectedServices {
    return _services
        .where((service) => _selectedServiceIds.contains(service.id))
        .toList();
  }

  double get _totalInvestment {
    return _selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.priceValue,
    );
  }

  String _formatMoney(double value) {
    final normalized = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    return '\$$normalized';
  }

  String get _selectedLabel {
    final count = _selectedServices.length;
    return count == 1 ? '1 Add-on' : '$count Add-ons';
  }

  void _toggleSelection(String serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 220),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 40),
                Text(
                  'Elevate Your\nExperience',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontStyle: FontStyle.italic,
                    height: 1.03,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF17120E),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Personalize your service with our curated\nselection of premium enhancements.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.45,
                    color: const Color(0xFF9D9A96),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 120),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          kEspressoColor,
                        ),
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 56),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: kWarmGrey600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _fetchAllServices,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kEspressoColor,
                              side: const BorderSide(color: kEspressoColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_services.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 56),
                    child: Center(
                      child: Text(
                        'No services available right now.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: kWarmGrey600,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_services.length, (index) {
                    final service = _services[index];
                    final isSelected = _selectedServiceIds.contains(service.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: GestureDetector(
                        onTap: () => _toggleSelection(service.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFCDB28A)
                                  : const Color(0xFFF1ECE4),
                              width: isSelected ? 1.4 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: opacity(Colors.black, 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ServiceImageTile(service: service),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF121212),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatMoney(service.priceValue),
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFC3A76D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      service.description.isNotEmpty
                                          ? service.description
                                          : 'Premium service enhancement.',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        height: 1.55,
                                        color: const Color(0xFF9A9895),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.05)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL INVESTMENT',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                letterSpacing: 3,
                                color: const Color(0xFFB3B0AB),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatMoney(_totalInvestment),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF17120E),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'SELECTED',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                letterSpacing: 3,
                                color: const Color(0xFFB3B0AB),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedLabel,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC3A76D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17120E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: _selectedServices.isEmpty
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  _selectedServices
                                      .map(
                                        (service) => ServiceCartItem(
                                          serviceId: service.id,
                                          title: service.title,
                                          price: _formatMoney(
                                            service.priceValue,
                                          ),
                                          duration: service.duration,
                                          imageUrl: service.imageUrl,
                                          description: service.description,
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                        child: Text(
                          'CONFIRM & CONTINUE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        Row(
          children: [
            _CircleIconButton(icon: Icons.favorite_rounded, onTap: () {}),
            const SizedBox(width: 14),
            _CircleIconButton(icon: Icons.share_rounded, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _EnhancementOption {
  _EnhancementOption({
    required this.id,
    required this.title,
    required this.description,
    required this.priceValue,
    required this.duration,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String id;
  final String title;
  final String description;
  final double priceValue;
  final String duration;
  final String imageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;

  factory _EnhancementOption.fromJson(Map<String, dynamic> json) {
    final imagePath = (json['image2'] ?? json['image1'] ?? json['image'] ?? '')
        .toString();
    final rawPrice = (json['price'] ?? '').toString();

    return _EnhancementOption(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? 'Service').toString(),
      description: (json['description'] ?? '').toString(),
      priceValue: _parsePrice(rawPrice),
      duration: (json['duration'] ?? '').toString(),
      imageUrl: imagePath.isNotEmpty
          ? imagePath.startsWith('http')
                ? imagePath
                : 'https://sidi.mobilegear.co.in/uploads/$imagePath'
          : '',
      fallbackIcon: Icons.spa_outlined,
      fallbackColor: const Color(0xFFF6EFE5),
    );
  }

  static double _parsePrice(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

class _ServiceImageTile extends StatelessWidget {
  const _ServiceImageTile({required this.service});

  final _EnhancementOption service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: service.fallbackColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            service.fallbackColor,
            opacity(const Color(0xFFC3A76D), 0.16),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: service.imageUrl.isNotEmpty
            ? Image.network(
                service.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _FallbackServiceIcon(service: service),
              )
            : _FallbackServiceIcon(service: service),
      ),
    );
  }
}

class _FallbackServiceIcon extends StatelessWidget {
  const _FallbackServiceIcon({required this.service});

  final _EnhancementOption service;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          service.fallbackIcon,
          color: const Color(0xFFC3A76D),
          size: 30,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4DED6)),
          boxShadow: [
            BoxShadow(
              color: opacity(Colors.black, 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF17120E), size: 24),
      ),
    );
  }
}
