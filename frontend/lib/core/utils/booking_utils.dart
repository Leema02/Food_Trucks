List<Map<String, String>> getDailyEntries(Map<String, dynamic> booking) {
  final start = DateTime.tryParse(booking['event_start_date'] ?? '');
  final end = DateTime.tryParse(booking['event_end_date'] ?? '');
  final startTime = booking['start_time'] ?? '';
  final endTime = booking['end_time'] ?? '';

  if (start == null || end == null) return [];

  final entries = <Map<String, String>>[];
  DateTime current = start;

  while (!current.isAfter(end)) {
    entries.add({
      'date': current.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
    });
    current = current.add(const Duration(days: 1));
  }

  return entries;
}
