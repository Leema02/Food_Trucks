import React, { useEffect, useState } from "react";
import { Calendar, dateFnsLocalizer, Views } from "react-big-calendar";
import format from "date-fns/format";
import parse from "date-fns/parse";
import startOfWeek from "date-fns/startOfWeek";
import getDay from "date-fns/getDay";
import enUS from "date-fns/locale/en-US";
import "react-big-calendar/lib/css/react-big-calendar.css";
import Sidebar from "../components/Sidebar";
import axios from "axios";
import "../styles/table.css";

const locales = { "en-US": enUS };

const localizer = dateFnsLocalizer({
  format,
  parse,
  startOfWeek,
  getDay,
  locales,
});

const BookingsCalendarPage = () => {
  const [events, setEvents] = useState([]);
  const [view, setView] = useState(Views.WEEK);
  const [date, setDate] = useState(new Date());

  useEffect(() => {
    fetchBookings();
  }, []);

  const COLORS = [
    "#3e95cd",
    "#8e5ea2",
    "#3cba9f",
    "#e8c3b9",
    "#c45850",
    "#f4a261",
    "#2a9d8f",
    "#e76f51",
    "#264653",
    "#6a0572",
  ];

  const colorMap = new Map();
  let colorIndex = 0;

  const fetchBookings = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/bookings/all", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      const expandedEvents = [];

      res.data.forEach((booking) => {
        const startDate = new Date(booking.event_start_date);
        const endDate = new Date(booking.event_end_date);

        // Assign a unique color per truck
        const truckKey = booking.truck_id._id;
        if (!colorMap.has(truckKey)) {
          colorMap.set(truckKey, COLORS[colorIndex % COLORS.length]);
          colorIndex++;
        }
        const eventColor = colorMap.get(truckKey);

        const current = new Date(startDate);
        while (current <= endDate) {
          const eventStart = new Date(
            `${current.toISOString().split("T")[0]}T${booking.start_time}`
          );
          const eventEnd = new Date(
            `${current.toISOString().split("T")[0]}T${booking.end_time}`
          );

          expandedEvents.push({
            id: `${booking._id}-${current.toDateString()}`,
            title: `${booking.truck_id.truck_name} - ${booking.occasion_type}`,
            start: eventStart,
            end: eventEnd,
            bgColor: eventColor, // ⬅️ Attach color
          });

          current.setDate(current.getDate() + 1);
        }
      });

      setEvents(expandedEvents);
    } catch (error) {
      console.error("Error fetching bookings:", error);
    }
  };

  // 🔘 Custom Nav Handlers
  const goToToday = () => setDate(new Date());

  const goToBack = () => {
    const newDate = new Date(date);
    if (view === Views.MONTH) newDate.setMonth(date.getMonth() - 1);
    if (view === Views.WEEK) newDate.setDate(date.getDate() - 7);
    if (view === Views.DAY) newDate.setDate(date.getDate() - 1);
    setDate(newDate);
  };

  const goToNext = () => {
    const newDate = new Date(date);
    if (view === Views.MONTH) newDate.setMonth(date.getMonth() + 1);
    if (view === Views.WEEK) newDate.setDate(date.getDate() + 7);
    if (view === Views.DAY) newDate.setDate(date.getDate() + 1);
    setDate(newDate);
  };

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        <h2>📅 Bookings Calendar</h2>

        <Calendar
          localizer={localizer}
          events={events}
          startAccessor="start"
          endAccessor="end"
          date={date}
          view={view}
          onView={setView}
          onNavigate={setDate}
          style={{ height: "80vh" }}
          eventPropGetter={(event) => ({
            style: {
              backgroundColor: event.bgColor || "#3e95cd",
              color: "white",
              borderRadius: "5px",
              padding: "4px",
            },
          })}
        />
      </div>
    </div>
  );
};

export default BookingsCalendarPage;
