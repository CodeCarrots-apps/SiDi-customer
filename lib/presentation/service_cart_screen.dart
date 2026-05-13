import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/presentation/timeslotscreen.dart';
import 'package:sidi/services/service_cart_service.dart';

class ServiceCartScreen extends StatefulWidget {
  const ServiceCartScreen({super.key});

  @override
  State<ServiceCartScreen> createState() => _ServiceCartScreenState();
}

class _ServiceCartScreenState extends State<ServiceCartScreen> {
  List<ServiceCartItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await ServiceCartService.loadCart();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _removeItem(ServiceCartItem item) async {
    final items = await ServiceCartService.removeItem(item.uniqueKey);
    if (!mounted) {
      return;
    }

    setState(() {
      _items = items;
    });
  }

  Future<void> _clearCart() async {
    await ServiceCartService.clearCart();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = [];
    });
  }

  String get _totalPriceLabel {
    var total = 0.0;
    var parsedCount = 0;
    for (final item in _items) {
      final numeric = double.tryParse(
        item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (numeric != null) {
        total += numeric;
        parsedCount++;
      }
    }

    if (parsedCount == _items.length && parsedCount > 0) {
      return 'AED ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)}';
    }
    return '${_items.length} services';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        surfaceTintColor: kBackgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SERVICE CART',
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
            color: kCharcoalColor,
          ),
        ),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: Text(
                'CLEAR',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: kAccentGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 44,
                      color: kMutedColor,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Your service cart is empty.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        color: kEspressoColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add multiple services from any service detail page and schedule them together.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: kWarmGrey600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: opacity(kEspressoColor, 0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item.imageUrl.isNotEmpty
                                    ? item.imageUrl
                                    : 'https://via.placeholder.com/120',
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontStyle: FontStyle.italic,
                                      color: kEspressoColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${item.duration}  ·  ${item.price}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: kWarmGrey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(item),
                              icon: const Icon(Icons.close_rounded),
                              color: kWarmGrey600,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemCount: _items.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: opacity(kEspressoColor, 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cart Total',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: kWarmGrey600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _totalPriceLabel,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kEspressoColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SelectTimeSlotScreen(
                                  serviceId: _items.first.serviceId,
                                  title: _items.first.title,
                                  price: _items.first.price,
                                  duration: _items.first.duration,
                                  imageUrl: _items.first.imageUrl,
                                  description: _items.first.description,
                                  beauticianId: _items.first.beauticianId,
                                  services: _items,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kEspressoColor,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'SCHEDULE ${_items.length} SERVICES',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
