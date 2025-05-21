import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/availability_service.dart';
import '../../../../core/services/truckOwner_service.dart';

class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({super.key});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  List<dynamic> trucks = [];
  String? selectedTruckId;
  Set<DateTime> unavailableDates = {};
  bool isLoading = true;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchMyTrucks();
  }

  Future<void> fetchMyTrucks() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await TruckOwnerService.getMyTrucks(token);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        trucks = result;
        if (trucks.isNotEmpty) {
          selectedTruckId = trucks[0]['_id'] ?? '';
          fetchUnavailableDates();
        } else {
          isLoading = false;
        }
      });
    } else {
      setState(() => isLoading = false);
      print("❌ Error loading trucks: ${response.body}");
    }
  }

  Future<void> fetchUnavailableDates() async {
    if (selectedTruckId == null) return;

    setState(() => isLoading = true);
    try {
      final result =
          await AvailabilityService.getUnavailableDates(selectedTruckId!);
      setState(() {
        unavailableDates =
            result.map((d) => DateTime(d.year, d.month, d.day)).toSet();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleDate(DateTime selectedDay) async {
    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final isUnavailable = unavailableDates.contains(d);

    setState(() {
      if (isUnavailable) {
        unavailableDates.remove(d);
      } else {
        unavailableDates.add(d);
      }
    });

    try {
      if (isUnavailable) {
        await AvailabilityService.removeUnavailableDate(selectedTruckId!, d);
      } else {
        await AvailabilityService.addUnavailableDate(selectedTruckId!, d);
      }
    } catch (e) {
      print("❌ Toggle date error: $e");
    }
  }

  bool isDateUnavailable(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return unavailableDates.contains(d);
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_availability'.tr()),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trucks.isEmpty
              ? Center(child: Text('you_dont_have_trucks'.tr()))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: (selectedTruckId != null &&
                                trucks.any((t) => t['_id'] == selectedTruckId))
                            ? selectedTruckId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'select_a_Truck'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        items: trucks.map<DropdownMenuItem<String>>((truck) {
                          return DropdownMenuItem<String>(
                            value: truck['_id'],
                            child: Text(truck['truck_name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTruckId = value;
                            fetchUnavailableDates();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay:
                                  DateTime.now().add(const Duration(days: 180)),
                              focusedDay: focusedDay,
                              calendarStyle: const CalendarStyle(
                                outsideDaysVisible: false,
                              ),
                              availableGestures: AvailableGestures.all,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month',
                              },
                              onDaySelected: (selectedDay, newFocusedDay) {
                                setState(() {
                                  focusedDay = newFocusedDay;
                                });
                                toggleDate(selectedDay);
                              },
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  return CalendarTile(
                                    date: day,
                                    isUnavailable: isDateUnavailable(day),
                                    onTap: () => toggleDate(day),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                    Colors.redAccent, 'Unavailable'.tr()),
                                const SizedBox(width: 16),
                                _buildLegendItem(
                                    Colors.greenAccent, 'Available'.tr()),
                                const SizedBox(width: 16),
                                _buildLegendItem(
                                    Colors.blueAccent, 'Today'.tr()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}
