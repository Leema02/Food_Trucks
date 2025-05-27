import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_tile.dart';

class TruckCalendar extends StatefulWidget {
  final List<DateTime> unavailableDates;
  final void Function(DateTime start, DateTime end, bool hasUnavailable)
      onRangeSelected;

  const TruckCalendar({
    super.key,
    required this.unavailableDates,
    required this.onRangeSelected,
  });

  @override
  State<TruckCalendar> createState() => _TruckCalendarState();
}

class _TruckCalendarState extends State<TruckCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool _isUnavailable(DateTime day) {
    final today = DateTime.now();
    return widget.unavailableDates.any((d) => DateUtils.isSameDay(d, day)) ||
        DateUtils.isSameDay(day, today);
  }

  bool _isToday(DateTime day) {
    return DateUtils.isSameDay(day, DateTime.now());
  }

  bool _isWithinRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return day.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
        day.isBefore(_rangeEnd!.add(const Duration(days: 1)));
  }

  void _handleTap(DateTime selectedDay) {
    if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
      setState(() {
        _rangeStart = selectedDay;
        _rangeEnd = null;
        _focusedDay = selectedDay;
      });
    } else {
      DateTime start = _rangeStart!;
      DateTime end = selectedDay;

      if (end.isBefore(start)) {
        final temp = start;
        start = end;
        end = temp;
      }
      // ⛔ Check max allowed range (7 days)
      final int days = end.difference(start).inDays + 1;
      if (days > 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Maximum booking range is 7 days."),
          ),
        );
        return;
      }

      // Trim the range if needed
      DateTime trimmedEnd = end;
      DateTime tempDate = start;
      bool wasTrimmed = false;

      while (!tempDate.isAfter(end)) {
        if (_isUnavailable(tempDate)) {
          trimmedEnd = tempDate.subtract(const Duration(days: 1));
          wasTrimmed = true;
          break;
        }
        tempDate = tempDate.add(const Duration(days: 1));
      }

      // Special case: single-day selection
      if (trimmedEnd.isBefore(start)) {
        if (start == end && !_isUnavailable(start)) {
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = selectedDay;
          });

          widget.onRangeSelected(start, end, false);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ All dates in the selected range are unavailable."),
          ),
        );
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
        });
        return;
      }

      if (wasTrimmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Range trimmed to avoid unavailable dates."),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        _rangeStart = start;
        _rangeEnd = trimmedEnd;
        _focusedDay = selectedDay;
      });

      widget.onRangeSelected(start, trimmedEnd, false);
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: _focusedDay,
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          onDaySelected: (selectedDay, focusedDay) => _handleTap(selectedDay),
          selectedDayPredicate: (day) =>
              DateUtils.isSameDay(day, _rangeStart) ||
              DateUtils.isSameDay(day, _rangeEnd),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              return CalendarTile(
                date: day,
                isUnavailable: _isUnavailable(day),
                isSelected: _isWithinRange(day),
                isToday: _isToday(day),
                onTap: () => _handleTap(day),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            "Tip: Tap once to select a start date, then again to select the end date.",
            style:
                TextStyle(fontSize: 13, color: Color.fromARGB(255, 96, 96, 96)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.redAccent, 'Unavailable'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.green.shade400, 'Selected Range'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Today'),
          ],
        ),
      ],
    );
  }
}
