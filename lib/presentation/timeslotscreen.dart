import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/presentation/enhance_session_screen.dart';
import 'package:sidi/presentation/selectaddress.dart';

import '../constant/app_fonts.dart';
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
  });

  final String serviceId;
  final String title;
  final String price;
  final String duration;
  final String imageUrl;
  final String description;
  final Stylist? stylist;
  final String? beauticianId;

  @override
  State<SelectTimeSlotScreen> createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  final Color espresso = kEspressoColor;
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

  // DateTime initialDate = DateTime.now().add(const Duration(days: 1));
  DateTime initialDate = DateTime.now();

  late DateTime selectedDate = initialDate;
  String selectedTime = "10:30 AM";
  List<ServiceCartItem> selectedAddonServices = [];

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

  bool get _canGoToPreviousMonth {
    final currentMonth = DateTime(_today.year, _today.month, 1);
    final visibleMonth = DateTime(initialDate.year, initialDate.month, 1);
    return visibleMonth.isAfter(currentMonth);
  }

  @override
  void initState() {
    super.initState();
    selectedTime = _firstAvailableTimeForDate(selectedDate) ?? '';
    _logAction(
      'initState selectedDate=$selectedDate selectedTime="$selectedTime"',
    );
  }

  // bool _isSlotAvailable(DateTime date, String time) {
  //   final selectedDay = DateTime(date.year, date.month, date.day);
  //   // API rule: same-day bookings are not allowed — must be tomorrow or later
  //   if (!selectedDay.isAfter(_today)) {
  //     return false;
  //   }
  //   return true;
  // }

  bool _isSlotAvailable(DateTime date, String time) {
    final selectedDay = DateTime(date.year, date.month, date.day);

    // Block strictly past days
    if (selectedDay.isBefore(_today)) return false;

    // For today, only show time slots that haven't passed yet
    if (selectedDay.year == _today.year &&
        selectedDay.month == _today.month &&
        selectedDay.day == _today.day) {
      final now = TimeOfDay.now();
      final parts = time.split(RegExp(r'[: ]'));
      var hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final isPm = parts[2] == 'PM';
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return hour > now.hour || (hour == now.hour && minute > now.minute);
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
              style: AppFonts.playfairDisplay(
                fontSize: 24,
                fontStyle: FontStyle.normal,
              ),
            ),
            actions: const [SizedBox(width: 48)],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _buildServicePreview(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 30, 32, 0),
                  child: const _BookingStepBar(currentStep: 2),
                ),
                _buildEnhancementPill(),
                _buildCalendar(),
                _buildTimeSlots(),
                const SizedBox(height: 180),
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
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppFonts.playfairDisplay(
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'DURATION: ${widget.duration.toUpperCase()}',
                      style: AppFonts.inter(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: const Color(0xFFADB4C0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.price,
                style: AppFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: espresso,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancementPill() {
    final hasAddons = selectedAddonServices.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Material(
              color: hasAddons ? const Color(0xFFF3E7D0) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () async {
                  final result = await Navigator.push<List<ServiceCartItem>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EnhanceSessionScreen(),
                    ),
                  );
                  if (!mounted || result == null) return;
                  setState(() {
                    selectedAddonServices = result;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: hasAddons
                          ? const Color(0xFFCDB28A)
                          : const Color(0xFFE5E0D8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: hasAddons
                            ? const Color(0xFFC3A76D)
                            : const Color(0xFF17120E),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hasAddons
                            ? '${selectedAddonServices.length} Add-on${selectedAddonServices.length == 1 ? '' : 's'} Selected'
                            : 'Enhance your session',
                        style: AppFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasAddons
                              ? const Color(0xFFC3A76D)
                              : const Color(0xFF17120E),
                        ),
                      ),
                      if (hasAddons) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Color(0xFFC3A76D),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasAddons) ...[
            const SizedBox(height: 16),
            ...selectedAddonServices.map(
              (addon) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFF6EFE5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: addon.imageUrl.isNotEmpty
                            ? Image.network(
                                addon.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.spa_outlined,
                                  size: 18,
                                  color: Color(0xFFC3A76D),
                                ),
                              )
                            : const Icon(
                                Icons.spa_outlined,
                                size: 18,
                                color: Color(0xFFC3A76D),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        addon.title,
                        style: AppFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF17120E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      addon.price,
                      style: AppFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC3A76D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAddonServices = selectedAddonServices
                              .where((s) => s.serviceId != addon.serviceId)
                              .toList();
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFB0A898),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final headerMonth = monthNames[days.first.month - 1].toUpperCase();
    final headerYear = days.first.year;
    final firstWeekdayOffset = days.first.weekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$headerMonth $headerYear',
                  style: AppFonts.inter(
                    fontSize: 11,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                    color: espresso,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left, size: 22),
                onPressed: _canGoToPreviousMonth
                    ? () => _changeMonth(-1)
                    : null,
                tooltip: 'Previous month',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right, size: 22),
                onPressed: () => _changeMonth(1),
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: AppFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFB6BCC7),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length + firstWeekdayOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              mainAxisExtent: 38,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) {
                return const SizedBox();
              }

              final day = days[index - firstWeekdayOffset];
              // final isPast = !day.isAfter(_today);
              final isPast = day.isBefore(_today);
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF1E5D2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: AppFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isPast ? const Color(0xFFD0D3DA) : espresso,
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
      padding: const EdgeInsets.fromLTRB(32, 54, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE AFTERNOON SLOTS',
            style: AppFonts.inter(
              fontSize: 11,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 22,
              crossAxisSpacing: 20,
              childAspectRatio: 2.15,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF3E7D0)
                        : isAvailable
                        ? Colors.white
                        : const Color(0xFFF2F0ED),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE6D1AA)
                          : isAvailable
                          ? const Color(0xFFEAE6DE)
                          : const Color(0xFFE1DED9),
                    ),
                    boxShadow: isAvailable
                        ? [
                            BoxShadow(
                              color: opacity(
                                espresso,
                                isSelected ? 0.04 : 0.03,
                              ),
                              blurRadius: isSelected ? 18 : 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: isAvailable
                      ? Text(
                          time,
                          style: AppFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: espresso,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: AppFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Unavailable',
                              style: AppFonts.inter(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
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
    final primaryService = ServiceCartItem(
      serviceId: widget.serviceId,
      title: widget.title,
      price: widget.price,
      duration: widget.duration,
      imageUrl: widget.imageUrl,
      description: widget.description,
      beauticianId: widget.beauticianId,
    );

    final bookingServices = selectedAddonServices.isEmpty
        ? const <ServiceCartItem>[]
        : [primaryService, ...selectedAddonServices];

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 22, 32, 34),
      decoration: BoxDecoration(
        color: opacity(backgroundLight, 0.95),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: opacity(Colors.black, 0.04),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: espresso,
              elevation: 0,
              minimumSize: const Size.fromHeight(62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
                          services: bookingServices,
                          selectedDateDisplay: selectedDateDisplay,
                          selectedDateIso: selectedDateIso,
                          selectedTime: selectedTime,
                          serviceId: widget.serviceId,
                          stylist: widget.stylist,
                          beauticianId: widget.beauticianId,
                        ),
                      ),
                    );
                  },
            child: Text(
              "CONTINUE TO ADDRESS",
              style: AppFonts.inter(
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
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
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 18),
              color: index ~/ 2 < currentStep - 1
                  ? const Color(0xFFCDB28A)
                  : const Color(0xFFE8E3DA),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isDone = stepIndex < currentStep - 1;
        final isActive = stepIndex == currentStep - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFFCDB28A)
                    : isActive
                    ? const Color(0xFF1B180D)
                    : const Color(0xFFF5F1EA),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF1B180D)
                      : const Color(0xFFE6DED2),
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        '${stepIndex + 1}',
                        style: AppFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF8F877D),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labels[stepIndex],
              style: AppFonts.inter(
                fontSize: 10,
                letterSpacing: 0.4,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF1B180D)
                    : const Color(0xFF8F877D),
              ),
            ),
          ],
        );
      }),
    );
  }
}
