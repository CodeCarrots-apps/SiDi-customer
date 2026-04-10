import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  const SelectTimeSlotScreen({super.key});

  @override
  State<SelectTimeSlotScreen> createState() =>
      _SelectTimeSlotScreenState();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServicePreview(),
                    _buildEnhanceButton(),
                    _buildCalendar(),
                    _buildTimeSlots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 22),
          ),
          const Spacer(),
          Text(
            "Select Time Slot",
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
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
              child: Image.network(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuDT5hRQS0itEISJLmTfM1WkwPcjeyBjkYDvLRWzucDP5TLvttMOWBYqju6G4977etvz90vvYXYOtFw6GWLKWYAQ6cn4zUROlQPTZczPsRmEE9VYnfWJBeS8ZNY6Son6t9nV3WTxeslTk1qvdyGP5Ik_zMjTzU5EJ7jR4N28cxLM5FLNs6MjQAoJ8YeVmpEGWgo9EqZ4edtufuQv3Oa_1JHdUe9WHGC0-lu3KToVf7ur27OfiavyRkX4NilPCU5sBO3N6yHvnElRp_U",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Signature Blowout",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "DURATION: 60 MINUTES",
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
                "\$85.00",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEnhanceButton() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          "Enhance your session",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: espresso,
          side: BorderSide(color: opacity(espresso, 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = selectedDay == day;

              return GestureDetector(
                onTap: () =>
                    setState(() => selectedDay = day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: champagne,
                          shape: BoxShape.circle,
                        )
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
      padding:
          const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) {
              final time = timeSlots[index];
              final isSelected = selectedTime == time;

              return GestureDetector(
                onTap: () =>
                    setState(() => selectedTime = time),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? champagne
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? mutedGold
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: opacity(Colors.black, 0.02),
                          blurRadius: 12,
                        )
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
      padding:
          const EdgeInsets.fromLTRB(32, 20, 32, 30),
      decoration: BoxDecoration(
        color: opacity(backgroundLight, 0.95),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
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
                : () {},
            child: Text(
              "CONTINUE TO PAYMENT",
              style: GoogleFonts.inter(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
