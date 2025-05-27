function getDailyEntries(booking) {
  const entries = [];
  const start = new Date(booking.event_start_date);
  const end = new Date(booking.event_end_date);
  const startTime = booking.start_time;
  const endTime = booking.end_time;

  for (
    let date = new Date(start);
    date <= end;
    date.setDate(date.getDate() + 1)
  ) {
    entries.push({
      date: date.toISOString().split('T')[0],
      start_time: startTime,
      end_time: endTime,
    });
  }

  return entries;
}
