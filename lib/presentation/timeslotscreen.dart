import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import 'selectaddress.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  const SelectTimeSlotScreen({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.description = '',
  });

  final String title;
  final String price;
  final String duration;
  final String imageUrl;
  final String description;

  @override
  State<SelectTimeSlotScreen> createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  final Color espresso = kEspressoColor;
  final Color champagne = kChampagneColor;
  final Color mutedGold = kMutedGoldColor;
  final Color backgroundLight = kBackgroundLight;

  int selectedDay = 5;
  String selectedTime = "10:30 AM";
  int bottomIndex = 1;

  final List<int> days = List.generate(14, (index) => index + 1);

  final List<String> timeSlots = [
    "09:00 AM",
    "10:30 AM",
    "12:00 PM",
    "01:30 PM",
    "03:00 PM",
    "04:30 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: backgroundLight,
            surfaceTintColor: backgroundLight,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, size: 22),
            ),
            centerTitle: true,
            title: Text(
              "Select Time Slot",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
            actions: const [SizedBox(width: 48)],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServicePreview(),
                _buildEnhanceButton(),
                _buildCalendar(),
                _buildTimeSlots(),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildServicePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.playfairDisplay(fontSize: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "DURATION: ${widget.duration.toUpperCase()}",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.price,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhanceButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Enhancement options will be available soon.',
                style: GoogleFonts.inter(),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          "Enhance your session",
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: espresso,
          side: BorderSide(color: opacity(espresso, 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OCTOBER 2023",
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = selectedDay == day;

              return GestureDetector(
                onTap: () => setState(() => selectedDay = day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: isSelected
                      ? BoxDecoration(color: champagne, shape: BoxShape.circle)
                      : null,
                  child: Text(
                    "$day",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w300,
                      color: espresso,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AVAILABLE AFTERNOON SLOTS",
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) {
              final time = timeSlots[index];
              final isSelected = selectedTime == time;

              return GestureDetector(
                onTap: () => setState(() => selectedTime = time),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? champagne : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? mutedGold : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: opacity(Colors.black, 0.02),
                          blurRadius: 12,
                        ),
                    ],
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: espresso,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 30),
      decoration: BoxDecoration(
        color: opacity(backgroundLight, 0.95),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: espresso,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: selectedTime.isEmpty
                ? null
                : () {
                    final selectedDate = 'October $selectedDay, 2023';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectAddressScreen(
                          selectedDate: selectedDate,
                          selectedTime: selectedTime,
                        ),
                      ),
                    );
                  },
            child: Text(
              "CONTINUE TO PAYMENT",
              style: GoogleFonts.inter(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
