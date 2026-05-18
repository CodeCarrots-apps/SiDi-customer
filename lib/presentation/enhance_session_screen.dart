import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/constant/app_fonts.dart';
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
    return '\u20B9$normalized';
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
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 360;
    final isTablet = size.width >= 700;

    final horizontalPadding = isTablet ? 32.0 : (isSmall ? 16.0 : 20.0);
    final subtitleFontSize = isSmall ? 14.0 : 16.0;
    final imageTileSize = isTablet ? 112.0 : (isSmall ? 84.0 : 96.0);
    final cardPadding = isSmall ? 14.0 : 16.0;
    final buttonHeight = isSmall ? 54.0 : 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    210,
                  ),
                  children: [
                    _buildTopBar(context, isSmall: isSmall),
                    SizedBox(height: isSmall ? 24 : 34),
                    Text(
                      'Elevate Your Experience',
                      style: AppFonts.playfairDisplay(
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        height: 1.03,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF17120E),
                      ),
                    ),
                    SizedBox(height: isSmall ? 10 : 14),
                    Text(
                      'Personalize your service with our curated selection of premium enhancements.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.inter(
                        fontSize: subtitleFontSize,
                        height: 1.45,
                        color: const Color(0xFF9D9A96),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: isSmall ? 24 : 32),
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
                                style: AppFonts.inter(
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
                            style: AppFonts.inter(
                              fontSize: 14,
                              color: kWarmGrey600,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_services.length, (index) {
                        final service = _services[index];
                        final isSelected = _selectedServiceIds.contains(
                          service.id,
                        );

                        return Padding(
                          padding: EdgeInsets.only(bottom: isSmall ? 14 : 18),
                          child: GestureDetector(
                            onTap: () => _toggleSelection(service.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFCDB28A)
                                      : const Color(0xFFF1ECE4),
                                  width: isSelected ? 1.4 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: opacity(Colors.black, 0.03),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ServiceImageTile(
                                    service: service,
                                    size: imageTileSize,
                                  ),
                                  SizedBox(width: isSmall ? 12 : 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                service.title,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppFonts.inter(
                                                  fontSize: isSmall ? 15 : 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF121212,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _formatMoney(service.priceValue),
                                              style: AppFonts.inter(
                                                fontSize: isSmall ? 16 : 18,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFC3A76D),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isSmall ? 6 : 8),
                                        Text(
                                          service.description.isNotEmpty
                                              ? service.description
                                              : 'Premium service enhancement.',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFonts.inter(
                                            fontSize: isSmall ? 13 : 14,
                                            height: 1.5,
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
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 820),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isSmall ? 14 : 16,
                    horizontalPadding,
                    isSmall ? 16 : 20,
                  ),
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
                                style: AppFonts.inter(
                                  fontSize: 10,
                                  letterSpacing: 2.3,
                                  color: const Color(0xFFB3B0AB),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatMoney(_totalInvestment),
                                style: AppFonts.playfairDisplay(
                                  fontSize: isSmall ? 22 : 24,
                                  fontStyle: FontStyle.normal,
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
                                style: AppFonts.inter(
                                  fontSize: 10,
                                  letterSpacing: 2.3,
                                  color: const Color(0xFFB3B0AB),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedLabel,
                                style: AppFonts.inter(
                                  fontSize: isSmall ? 15 : 17,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC3A76D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 14 : 18),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
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
                            style: AppFonts.inter(
                              fontSize: isSmall ? 12.5 : 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: isSmall ? 1.2 : 1.8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool isSmall}) {
    final iconButtonSize = isSmall ? 48.0 : 54.0;
    final iconSize = isSmall ? 20.0 : 22.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleIconButton(
          size: iconButtonSize,
          iconSize: iconSize,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
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
  const _ServiceImageTile({required this.service, required this.size});

  final _EnhancementOption service;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xFF17120E), size: iconSize),
    );
  }
}
