import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'servicedetailscreen.dart';

class DetailedServiceScreen extends StatefulWidget {
  const DetailedServiceScreen({super.key});

  @override
  State<DetailedServiceScreen> createState() => _DetailedServiceScreenState();
}

class _DetailedServiceScreenState extends State<DetailedServiceScreen> {
  int _selectedFilterIndex = 0;

  // Colors are provided by lib/constant/constants.dart

  final List<String> filters = [
    "All Nails",
    "Manicure",
    "Pedicure",
    "Nail Art",
  ];

  final List<Map<String, String>> services = [
    {
      "title": "Signature Silk Manicure",
      "price": "\$85",
      "duration": "60 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBBYEO4G9e9SXUHhmUpFTOV3PWtGQs3jD24uVhrTk9zjIG1f1ubaugSCBH32kItXCAlNa9K1asoJoRe5TWj714hzf7UDOt-Bnnx8l5j4MFVz515ceZGByzqOjjhClsxjTZ9J9_uV33TJ8VYDDRot4IOQ4Azx9W_oOJT3XickZxxNfJG69MnRQfMDYYHnSAgRgqfNqPPWvt1v4Hi1fNfOIzF1VsumU8wvA_vrl0Atna8qrWl-CFGzCdndtBqy-7fYCwa_LNs-xT8Z78"
    },
    {
      "title": "Luxury Spa Pedicure",
      "price": "\$110",
      "duration": "75 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDOnlzfJ5hytmdW4ELdw6Ok_SOYRYxWdVOdaPEBl2PZIl8csFiA9YcMkfFd6F_-4QYpyIIq1vJZra5ZX9AsrbPX6CfJdS7nHLizeUa6oY3Roh3FgwfnKeurxbc3kl9hV-Mif5hRf9qsLgSXKhtvZpWQfQzKUo2Rk5lxo-V2-tSZcnqNgoCOLm24oZdjHaXhpNaLvRo9qMzOoCLIwbicwmcX-YlSmQ3FbSv4iD8ZzAvPZSgl0arTWqYC7o5SwnwKEfQJEhy0lDN0JEM"
    },
    {
      "title": "Editorial Nail Art",
      "price": "\$130",
      "duration": "90 mins",
      "image":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCtJWLbhrrHtqz2qPSquBG_yi6xBKYNNV4Q21-bQ0EWvtOvKQHxfqb1oH9z483HzXLIrbB-QW723AXgVOQHeaNpCLiTlw9HgMOFR2Be1W0uxOCBrUUZt00SOAAMUFhYh3IQjuBGdQHHTkIEcOHZ4aNaiusM1aavDSfafktZ-KripjaeGSG4Uy4V0PIpXIXzBM-4cIXIS9jO_m4twy3Gc3RQcsNKQ6WdoRUf6wR4c0rP_K54o5hCE7hYPM7fyjWR5S1bpGiexO8nSBA"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: services
                      .map((service) => _buildServiceCard(service))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              )),
          Text(
            "NAIL CARE",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(
              width: 40, height: 40, child: Icon(Icons.search, size: 24)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final selected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kEspressoColor : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                filters[index].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
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
      padding: const EdgeInsets.only(bottom: 40),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceDetailScreen()));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  service["image"]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service["title"]!,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                    ),
                  ),
                ),
                Text(
                  service["price"]!,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service["duration"]!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: kPrimaryBeige,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    "VIEW DETAILS",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
