import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/presentation/selectaddress.dart';

import '../models/stylist.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  const SelectTimeSlotScreen({
    super.key,
    required this.serviceId,
    required this.title,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.description = '',
    this.stylist,
    this.beauticianId,
    this.services = const [],
  });

  final String serviceId;
  final String title;
  final String price;
  final String duration;
  final String imageUrl;
  final String description;
  final Stylist? stylist;
  final String? beauticianId;
  final List<ServiceCartItem> services;

  @override
  State<SelectTimeSlotScreen> createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  final Color espresso = kEspressoColor;
  final Color champagne = kChampagneColor;
  final Color mutedGold = kMutedGoldColor;
  final Color backgroundLight = kBackgroundLight;

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  DateTime initialDate = DateTime.now().add(const Duration(days: 1));
  late DateTime selectedDate = initialDate;
  String selectedTime = "10:30 AM";
  int bottomIndex = 1;

  late List<DateTime> days = _generateDays(initialDate.year, initialDate.month);

  static List<DateTime> _generateDays(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (index) => DateTime(year, month, index + 1),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      initialDate = DateTime(initialDate.year, initialDate.month + delta, 1);
      days = _generateDays(initialDate.year, initialDate.month);
      // If selectedDate is not in the new month, reset to first day
      if (selectedDate.month != initialDate.month ||
          selectedDate.year != initialDate.year) {
        selectedDate = DateTime(initialDate.year, initialDate.month, 1);
        selectedTime = _firstAvailableTimeForDate(selectedDate) ?? '';
      }
    });
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    selectedTime = _firstAvailableTimeForDate(selectedDate) ?? '';
    _logAction(
      'initState selectedDate=$selectedDate selectedTime="$selectedTime"',
    );
  }

  bool _isSlotAvailable(DateTime date, String time) {
    final selectedDay = DateTime(date.year, date.month, date.day);
    // API rule: same-day bookings are not allowed — must be tomorrow or later
    if (!selectedDay.isAfter(_today)) {
      return false;
    }
    return true;
  }

  void _logAction(String message) {
    debugPrint('SelectTimeSlotScreen: $message');
  }

  String? _firstAvailableTimeForDate(DateTime date) {
    for (final time in timeSlots) {
      if (_isSlotAvailable(date, time)) {
        return time;
      }
    }
    return null;
  }

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
              onPressed: () {
                _logAction('Back button pressed');
                Navigator.pop(context);
              },
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                  child: const _BookingStepBar(currentStep: 2),
                ),
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
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF0EBE3),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFFB0A090),
                    ),
                  ),
                ),
              ),
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

  Widget _buildCalendar() {
    final headerMonth = monthNames[days.first.month - 1].toUpperCase();
    final headerYear = days.first.year;
    // Offset so day 1 falls on the correct weekday column (Mon=0 … Sun=6)
    final firstWeekdayOffset = days.first.weekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => _changeMonth(-1),
                tooltip: 'Previous month',
              ),
              Text(
                "$headerMonth $headerYear",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => _changeMonth(1),
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekday header row
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length + firstWeekdayOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) return const SizedBox();
              final day = days[index - firstWeekdayOffset];
              final isPast = !day.isAfter(_today); // blocks today AND past days
              final isSelected =
                  !isPast &&
                  selectedDate.day == day.day &&
                  selectedDate.month == day.month &&
                  selectedDate.year == day.year;

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        _logAction('Date selected: ${day.toIso8601String()}');
                        setState(() {
                          selectedDate = day;
                          selectedTime = _firstAvailableTimeForDate(day) ?? '';
                        });
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: isSelected
                      ? BoxDecoration(color: champagne, shape: BoxShape.circle)
                      : null,
                  child: Text(
                    "${day.day}",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w300,
                      color: isPast ? Colors.grey.shade400 : espresso,
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
    final hasAvailableSlots = timeSlots.any(
      (t) => _isSlotAvailable(selectedDate, t),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AVAILABLE TIME SLOTS",
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasAvailableSlots)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No available slots for this day.\nPlease select another date.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.65,
                  ),
                ),
              ),
            )
          else
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
                final isAvailable = _isSlotAvailable(selectedDate, time);
                final isSelected = selectedTime == time && isAvailable;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          HapticFeedback.selectionClick();
                          _logAction('Time slot selected: $time');
                          setState(() => selectedTime = time);
                        }
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? champagne : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? mutedGold
                            : isAvailable
                            ? Colors.grey.shade200
                            : Colors.grey.shade300,
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
                        color: isAvailable ? espresso : Colors.grey.shade400,
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
                : () async {
                    final selectedDateIso =
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                    _logAction(
                      'Continue pressed with selectedDate=$selectedDateIso selectedTime=$selectedTime',
                    );

                    final selectedDateDisplay =
                        '${monthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectAddressScreen(
                          serviceImage: widget.imageUrl,
                          serviceTitle: widget.title,
                          servicePrice: widget.price,
                          selectedDateDisplay: selectedDateDisplay,
                          selectedDateIso: selectedDateIso,
                          selectedTime: selectedTime,
                          serviceId: widget.serviceId,
                          stylist: widget.stylist,
                          beauticianId: widget.beauticianId,
                          services: widget.services,
                        ),
                      ),
                    );
                  },
            child: Text(
              widget.services.isNotEmpty
                  ? 'CONTINUE WITH ${widget.services.length} SERVICES'
                  : "CONTINUE TO ADDRESS",
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

class _BookingStepBar extends StatelessWidget {
  const _BookingStepBar({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Service', 'Schedule', 'Confirm'];
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 1.5,
              color: i ~/ 2 < currentStep - 1
                  ? const Color(0xFFC5B38A)
                  : const Color(0xFFE8E5DF),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < currentStep - 1;
        final active = idx == currentStep - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? const Color(0xFFC5B38A)
                    : active
                    ? const Color(0xFF2C1A0E)
                    : const Color(0xFFF3F2F0),
              ),
              child: Center(
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : const Color(0xFF78716C),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              labels[idx],
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? const Color(0xFF2C1A0E)
                    : const Color(0xFF78716C),
                letterSpacing: 0.3,
              ),
            ),
          ],
        );
      }),
    );
  }
}
