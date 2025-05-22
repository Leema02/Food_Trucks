import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_tile.dart';

class TruckCalendar extends StatefulWidget {
  final List<DateTime> unavailableDates;
  final void Function(DateTime selected) onDateSelected;

  const TruckCalendar({
    super.key,
    required this.unavailableDates,
    required this.onDateSelected,
  });

  @override
  State<TruckCalendar> createState() => _TruckCalendarState();
}

class _TruckCalendarState extends State<TruckCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isUnavailable(DateTime day) {
    final today = DateTime.now();
    return widget.unavailableDates.any((d) => DateUtils.isSameDay(d, day)) ||
        DateUtils.isSameDay(day, today); // ❌ block today
  }

  bool _isToday(DateTime day) {
    return DateUtils.isSameDay(day, DateTime.now());
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
          selectedDayPredicate: (day) => DateUtils.isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (_isUnavailable(selectedDay)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❌ This date is unavailable")),
              );
              return;
            }

            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            widget.onDateSelected(selectedDay);
          },
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              return CalendarTile(
                date: day,
                isUnavailable: _isUnavailable(day),
                isSelected: DateUtils.isSameDay(_selectedDay, day),
                isToday: _isToday(day),
                onTap: () {
                  if (!_isUnavailable(day)) {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = day;
                    });
                    widget.onDateSelected(day);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.redAccent, 'Unavailable'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.green.shade400, 'Available'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Today'),
          ],
        ),
      ],
    );
  }
}
