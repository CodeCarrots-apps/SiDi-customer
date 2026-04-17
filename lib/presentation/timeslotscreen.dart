import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

import '../models/booking.dart';
import '../models/booking_models.dart';
import '../services/local_storage_service.dart';
import 'appointmentbooking.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  const SelectTimeSlotScreen({
    super.key,
    required this.serviceId,
    required this.title,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.description = '',
  });

  final String serviceId;
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

  final DateTime initialDate = DateTime.now();
  late DateTime selectedDate = initialDate;
  String selectedTime = "10:30 AM";
  int bottomIndex = 1;

  late final List<DateTime> days = List.generate(
    DateTime(initialDate.year, initialDate.month + 1, 0).day,
    (index) => DateTime(initialDate.year, initialDate.month, index + 1),
  );

  DateTime get _today =>
      DateTime(initialDate.year, initialDate.month, initialDate.day);

  @override
  void initState() {
    super.initState();
    selectedTime = _firstAvailableTimeForDate(selectedDate) ?? '';
    _logAction(
      'initState selectedDate=$selectedDate selectedTime="$selectedTime"',
    );
  }

  DateTime _slotDateTime(DateTime date, String time) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([APMapm]{2})$',
    ).firstMatch(time);
    if (match == null) {
      return DateTime(date.year, date.month, date.day);
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour < 12) {
      hour += 12;
    }
    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _isSlotAvailable(DateTime date, String time) {
    final slotDateTime = _slotDateTime(date, time);
    final now = DateTime.now();
    final selectedDay = DateTime(date.year, date.month, date.day);
    if (selectedDay.isBefore(_today)) {
      return false;
    }
    if (selectedDay.isAtSameMomentAs(_today)) {
      return slotDateTime.isAtSameMomentAs(now) || slotDateTime.isAfter(now);
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
          _logAction('Enhance button pressed');
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
    final headerMonth = monthNames[days.first.month - 1].toUpperCase();
    final headerYear = days.first.year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$headerMonth $headerYear",
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
              final today = DateTime(
                initialDate.year,
                initialDate.month,
                initialDate.day,
              );
              final isPast = day.isBefore(today);
              final isSelected =
                  !isPast &&
                  selectedDate.day == day.day &&
                  selectedDate.month == day.month &&
                  selectedDate.year == day.year;

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
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
              final isAvailable = _isSlotAvailable(selectedDate, time);
              final isSelected = selectedTime == time && isAvailable;

              return GestureDetector(
                onTap: isAvailable
                    ? () {
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

                    final booking = Booking(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: widget.title,
                      time: selectedTime,
                      stylist: 'Assigned stylist',
                      image: widget.imageUrl,
                      status: 'Confirmed',
                      jobId: DateTime.now().millisecondsSinceEpoch.toString(),
                    );

                    await LocalStorageService.addCachedBooking(booking);

                    final response = BookingCreateResponse(
                      success: true,
                      message: 'Your appointment is confirmed.',
                      booking: booking,
                      estimatedPrice: 0,
                      addonsAmount: 0,
                      travelFee: 0,
                      broadcastedCount: 0,
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmationScreen(
                          service: widget.title,
                          response: response,
                        ),
                      ),
                    );
                  },
            child: Text(
              "CONFIRM APPOINTMENT",
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
