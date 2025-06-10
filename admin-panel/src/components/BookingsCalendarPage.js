import React, { useEffect, useState } from "react";
import { Calendar, dateFnsLocalizer, Views } from 'react-big-calendar';
import { format, parse, startOfWeek, getDay } from 'date-fns';
import enUS from 'date-fns/locale/en-US';
import 'react-big-calendar/lib/css/react-big-calendar.css';

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
  const [calendarDate, setCalendarDate] = useState(new Date()); 


  const [searchDateInput, setSearchDateInput] = useState('');

 
  const [appliedSearchDate, setAppliedSearchDate] = useState('');

  useEffect(() => {
   
    fetchBookings(appliedSearchDate);

    
    if (appliedSearchDate) {
      setCalendarDate(new Date(appliedSearchDate));
    } else {
  
      setCalendarDate(new Date());
    }

  }, [appliedSearchDate]); 


  // Color map and index reset
  const COLORS = [
    "#3e95cd", "#8e5ea2", "#3cba9f", "#e8c3b9", "#c45850",
    "#f4a261", "#2a9d8f", "#e76f51", "#264653", "#6a0572",
  ];
 

  const fetchBookings = async (dateToFilter = "") => {
    // Reset color map for each fetch
    const tempColorMap = new Map();
    let tempColorIndex = 0;

    try {
      const url = dateToFilter
        ? `http://localhost:5000/api/bookings/all?date=${dateToFilter}`
        : "http://localhost:5000/api/bookings/all";

      const res = await axios.get(url, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      const expandedEvents = [];
      res.data.forEach((booking) => {
       

        if (!booking.truck_id) {
            console.warn("Skipping booking due to missing truck_id:", booking);
            return;
        }

        const startDate = new Date(booking.event_start_date);
        const endDate = new Date(booking.event_end_date);
        const truckKey = booking.truck_id._id;

        if (!tempColorMap.has(truckKey)) { // Use tempColorMap
          tempColorMap.set(truckKey, COLORS[tempColorIndex % COLORS.length]); // Use tempColorIndex
          tempColorIndex++; // Use tempColorIndex
        }
        const eventColor = tempColorMap.get(truckKey); // Use tempColorMap

        const current = new Date(startDate);
        while (current <= endDate) {
          const dateStr = current.toISOString().split("T")[0];
          // Ensure times are correctly parsed for the calendar (local time)
          const eventStart = new Date(`${dateStr}T${booking.start_time}`);
          const eventEnd = new Date(`${dateStr}T${booking.end_time}`);

          expandedEvents.push({
            id: `${booking._id}-${dateStr}`,
            title: `${booking.truck_id.truck_name} - ${booking.occasion_type}`,
            start: eventStart,
            end: eventEnd,
            bgColor: eventColor,
          });

          current.setDate(current.getDate() + 1);
        }
      });

      console.log("Expanded events length:", expandedEvents.length);
      setEvents(expandedEvents); 
    } catch (error) {
      console.error("Error fetching bookings:", error);
     
    }
  };

  const handleSearchDateInputChange = (e) => {
    setSearchDateInput(e.target.value);
  };

  // NEW Handler for the "Apply Search" button
  const handleApplySearch = () => {
   
    setAppliedSearchDate(searchDateInput);
  };

  
  const handleClearSearch = () => {
    setSearchDateInput(''); 
    setAppliedSearchDate(''); 
  };


  // 🔘 Custom Nav Handlers (using calendarDate)
  const goToToday = () => setCalendarDate(new Date());

  const goToBack = () => {
    const newDate = new Date(calendarDate); // Use calendarDate here
    if (view === Views.MONTH) newDate.setMonth(calendarDate.getMonth() - 1);
    if (view === Views.WEEK) newDate.setDate(calendarDate.getDate() - 7);
    if (view === Views.DAY) newDate.setDate(calendarDate.getDate() - 1);
    setCalendarDate(newDate); 
  };

  const goToNext = () => {
    const newDate = new Date(calendarDate); // Use calendarDate here
    if (view === Views.MONTH) newDate.setMonth(calendarDate.getMonth() + 1);
    if (view === Views.WEEK) newDate.setDate(calendarDate.getDate() + 7);
    if (view === Views.DAY) newDate.setDate(calendarDate.getDate() + 1);
    setCalendarDate(newDate); 
  };

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        <h2>📅 Bookings Calendar</h2>

        {/* Applying recommended CSS class for search controls */}
        <div className="search-controls">
          <div
  style={{
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    gap: "12px",
    margin: "20px 0",
    flexWrap: "wrap",
  }}
>
  <label htmlFor="bookingDateSearch" style={{ fontWeight: "bold" }}>
    🔍 Search by Date:
  </label>
  <input
    type="date"
    id="bookingDateSearch"
    value={searchDateInput}
    onChange={handleSearchDateInputChange}
    style={{
      padding: "8px",
      borderRadius: "4px",
      border: "1px solid #ccc",
      minWidth: "180px",
    }}
  />
  <button
    onClick={handleApplySearch}
    style={{
      padding: "8px 16px",
      backgroundColor: "#007bff",
      color: "white",
      border: "none",
      borderRadius: "4px",
      cursor: "pointer",
      fontWeight: "bold",
    }}
  >
    Apply Search
  </button>
  {appliedSearchDate && (
    <button
      onClick={handleClearSearch}
      style={{
        padding: "8px 16px",
        backgroundColor: "#6c757d",
        color: "white",
        border: "none",
        borderRadius: "4px",
        cursor: "pointer",
      }}
    >
      Clear Search
    </button>
  )}
</div>
        </div>

        <Calendar
          localizer={localizer}
          events={events}
          startAccessor="start"
          endAccessor="end"
          date={calendarDate} 
          view={view}
          onView={setView}
          onNavigate={setCalendarDate} 
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