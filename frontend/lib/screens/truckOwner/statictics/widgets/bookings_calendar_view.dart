// lib/screens/truckOwner/orders/bookings_calendar_view.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/core/services/event_booking_service.dart';

class BookingsCalendarView extends StatefulWidget {
  final String truckId;

  const BookingsCalendarView({super.key, required this.truckId});

  @override
  State<BookingsCalendarView> createState() => _BookingsCalendarViewState();
}

class _BookingsCalendarViewState extends State<BookingsCalendarView> {
  late Future<Map<DateTime, List<dynamic>>> _eventsFuture;
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _eventsFuture = _fetchAndProcessBookings();
  }

  @override
  void didUpdateWidget(covariant BookingsCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.truckId != oldWidget.truckId) {
      setState(() {
        _eventsFuture = _fetchAndProcessBookings();
        _selectedEvents.value = [];
      });
    }
  }

  Future<Map<DateTime, List<dynamic>>> _fetchAndProcessBookings() async {
    try {
      final List<dynamic> allBookings = await EventBookingService.getOwnerBookings();

      final Map<DateTime, List<dynamic>> eventSource = {};

      for (var booking in allBookings) {
        if (booking['truck_id']?['_id'] == widget.truckId &&
            booking['status'] == 'confirmed') {
          if (booking['event_start_date'] == null || booking['event_end_date'] == null) {
            continue;
          }

          final startDate = DateTime.parse(booking['event_start_date']).toUtc();
          final endDate = DateTime.parse(booking['event_end_date']).toUtc();

          for (var day = startDate;
          day.isBefore(endDate.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))) {
            final dateKey = DateTime.utc(day.year, day.month, day.day);
            if (eventSource[dateKey] == null) {
              eventSource[dateKey] = [];
            }
            eventSource[dateKey]!.add(booking);
          }
        }
      }

      final todayUtc = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      _selectedEvents.value = eventSource[todayUtc] ?? [];

      return eventSource;
    } catch (e) {
      print('Error fetching or processing bookings: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(heightFactor: 5, child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Error loading bookings: ${snapshot.error}', textAlign: TextAlign.center),
                ));
          }

          final events = snapshot.data ?? {};
          if (events.isEmpty) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFFE3F2FD),
              margin: const EdgeInsets.all(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Confirmed Bookings Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                      SizedBox(height: 4),
                      Text("This truck doesn't have any confirmed event bookings yet.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            );
          }

          List<dynamic> getEventsForDay(DateTime day) {
            final utcDay = DateTime.utc(day.year, day.month, day.day);
            return events[utcDay] ?? [];
          }

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFFE3F2FD),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Confirmed Bookings Calendar', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  TableCalendar<dynamic>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: getEventsForDay, // This still provides data for the builder
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _selectedEvents.value = getEventsForDay(selectedDay);
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    // --- STYLE CHANGES ---
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Color(0xFF90CAF9),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      // The default dot marker is no longer needed. We remove it.
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    // --- BUILDER CHANGES ---
                    calendarBuilders: CalendarBuilders(
                      // Builder for regular days
                      defaultBuilder: (context, day, focusedDay) {
                        final utcDay = DateTime.utc(day.year, day.month, day.day);
                        // If this day has an event, build our custom red circle
                        if (events.containsKey(utcDay)) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                        // Otherwise, return null to use the default look
                        return null;
                      },
                      dowBuilder: (context, day) {
                        final text = DateFormat.E().format(day);
                        if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
                          return Center(child: Text(text, style: TextStyle(color: Colors.red.shade400)));
                        }
                        return Center(child: Text(text, style: TextStyle(color: Colors.blue.shade800)));
                      },
                      markerBuilder: (context, day, events) {
                        return Container(); // Returning an empty container removes the dot
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(height: 1),
                  ValueListenableBuilder<List<dynamic>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("No bookings for ${DateFormat.yMMMd().format(_selectedDay!)}", style: TextStyle(color: Colors.grey.shade600)),
                        );
                      }
                      return ListView.builder(
                        itemCount: value.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final booking = value[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(12.0),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade300,
                                child: const Icon(Icons.event_available, color: Colors.white, size: 20),
                              ),
                              title: Text(booking['truck_id']?['truck_name'] ?? 'Booking'),
                              subtitle: Text('Location: ${booking['city'] ?? 'N/A'} | Time: ${booking['start_time']}'),
                              onTap: () {},
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}