import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/drive_model.dart';
import '../../../core/models/student_profile.dart';
import '../../drive_detail/screens/drive_detail_screen.dart';

class StitchCalendarView extends StatefulWidget {
  final List<PlacementDrive> drives;
  final StudentProfile profile;
  final VoidCallback onDrivesUpdated;

  const StitchCalendarView({
    super.key,
    required this.drives,
    required this.profile,
    required this.onDrivesUpdated,
  });

  @override
  State<StitchCalendarView> createState() => _StitchCalendarViewState();
}

class _StitchCalendarViewState extends State<StitchCalendarView> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  // Get all dates in current month grid (including padding for weekday alignment)
  List<DateTime?> _generateCalendarGrid() {
    final firstDayOfWeek = _selectedMonth.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final prevMonthDays = DateTime(_selectedMonth.year, _selectedMonth.month, 0).day;

    final grid = <DateTime?>[];

    // Previous month padding
    for (int i = firstDayOfWeek - 1; i >= 0; i--) {
      grid.add(DateTime(_selectedMonth.year, _selectedMonth.month - 1, prevMonthDays - i));
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      grid.add(DateTime(_selectedMonth.year, _selectedMonth.month, day));
    }

    // Next month padding to complete 35 or 42 cells
    final totalCells = (grid.length <= 35) ? 35 : 42;
    final remaining = totalCells - grid.length;
    for (int day = 1; day <= remaining; day++) {
      grid.add(DateTime(_selectedMonth.year, _selectedMonth.month + 1, day));
    }

    return grid;
  }

  bool _doesDateStrMatch(String dateStr, DateTime date) {
    if (dateStr == 'TBD' || dateStr.trim().isEmpty) return false;
    
    final dayMatch = RegExp(r'\d+').firstMatch(dateStr);
    if (dayMatch == null) return false;
    final int day = int.parse(dayMatch.group(0)!);
    if (day != date.day) return false;
    
    final strLower = dateStr.toLowerCase();
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final targetMonthStr = months[date.month - 1];
    if (!strLower.contains(targetMonthStr)) return false;
    
    return true;
  }

  bool _hasEvents(DateTime date) {
    // Check if any drive deadline is on this date
    final hasDeadline = widget.drives.any((d) =>
        d.formDeadline.year == date.year &&
        d.formDeadline.month == date.month &&
        d.formDeadline.day == date.day);
    if (hasDeadline) return true;

    // Check if any active round matches
    for (var drive in widget.drives) {
      if (drive.rounds.any((r) => !r.isCompleted && _doesDateStrMatch(r.dateStr, date))) {
        return true;
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final events = <Map<String, dynamic>>[];

    for (var drive in widget.drives) {
      if (drive.formDeadline.year == date.year &&
          drive.formDeadline.month == date.month &&
          drive.formDeadline.day == date.day) {
        events.add({
          'title': '${drive.companyName} Application Form',
          'time': '${drive.formDeadline.hour.toString().padLeft(2, '0')}:${drive.formDeadline.minute.toString().padLeft(2, '0')}',
          'platform': 'Form Submission Deadline',
          'icon': Icons.assignment_outlined,
          'drive': drive,
        });
      }

      for (var round in drive.rounds) {
        if (!round.isCompleted && _doesDateStrMatch(round.dateStr, date)) {
          events.add({
            'title': '${drive.companyName} - ${round.title}',
            'time': round.timeStr != 'TBD' ? round.timeStr : '10:00 AM',
            'platform': round.title.contains('Interview') ? 'Google Meet / Video' : 'Online Platform',
            'icon': round.title.contains('Interview') ? Icons.videocam : Icons.code,
            'drive': drive,
          });
        }
      }
    }

    return events;
  }

  List<PlacementDrive> get _upcomingDeadlines {
    final list = widget.drives.where((d) => d.formDeadline.isAfter(DateTime.now())).toList();
    list.sort((a, b) => a.formDeadline.compareTo(b.formDeadline));
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final grid = _generateCalendarGrid();
    final eventsForSelectedDay = _getEventsForDate(_selectedDate);
    final isSelectedMonth = _selectedMonth.month == _selectedDate.month && _selectedMonth.year == _selectedDate.year;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            // Title
            const Text(
              'Drive Calendar',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Calendar Module Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.onSurfaceVariant),
                        onPressed: _prevMonth,
                      ),
                      Text(
                        '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Weekday Headers (S M T W T F S)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _WeekdayLabel('S'),
                      _WeekdayLabel('M'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('W'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('F'),
                      _WeekdayLabel('S'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Month Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: grid.length,
                    itemBuilder: (context, index) {
                      final date = grid[index];
                      if (date == null) return const SizedBox();

                      final isCurrentMonth = date.month == _selectedMonth.month;
                      final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      final hasEvent = _hasEvents(date);

                      return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        if (!isCurrentMonth) {
                          _selectedMonth = DateTime(date.year, date.month, 1);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : isCurrentMonth
                                      ? AppColors.onSurface
                                      : AppColors.onSurfaceVariant.withOpacity(0.35),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          if (hasEvent && !isSelected)
                            Positioned(
                              bottom: 3,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.cyanAccent,
                                  shape: BoxShape.circle,
                                ),
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
        ),
        const SizedBox(height: 24),

        // 2. Today's / Selected Day Agenda Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSelectedMonth && _selectedDate.day == DateTime.now().day
                  ? "Today's Agenda"
                  : 'Agenda for ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.day}',
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),
        const SizedBox(height: 16),

        // Agenda Items
        if (eventsForSelectedDay.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Center(
              child: Text(
                'No events scheduled for this day.',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          )
        else
          ...eventsForSelectedDay.map((event) {
            final drive = event['drive'] as PlacementDrive;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glowing node indicator
                  Container(
                    margin: const EdgeInsets.only(top: 14, right: 14),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Agenda Event Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriveDetailScreen(
                              drive: drive,
                              profile: widget.profile,
                              onDriveUpdated: (_) => widget.onDrivesUpdated(),
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event['title'],
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  event['time'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(event['icon'] as IconData, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    event['platform'],
                                    style: const TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 20),

        // 3. Upcoming Deadlines Section
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),
        const SizedBox(height: 14),

        if (_upcomingDeadlines.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No upcoming deadlines found.',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          )
        else
          ..._upcomingDeadlines.map((drive) {
            final dueStr = 'Due: ${_monthNames[drive.formDeadline.month - 1].substring(0, 3)} ${drive.formDeadline.day}, ${drive.formDeadline.hour}:${drive.formDeadline.minute.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriveDetailScreen(
                          drive: drive,
                          profile: widget.profile,
                          onDriveUpdated: (_) => widget.onDrivesUpdated(),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${drive.companyName} ${drive.postTitle}',
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dueStr,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_forward_ios, size: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
