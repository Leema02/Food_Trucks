// src/components/Sidebar.js
import React from "react";
import { useNavigate } from "react-router-dom";
import {
  FaTachometerAlt,
  FaUsers,
  FaTruck,
  FaCalendarAlt,
  FaUtensils,
  FaMoneyBillWave,
  FaChartBar,
  FaStar, // Import the FaStar icon for reviews
} from "react-icons/fa";
import logo from "../assets/appIcon.png";
import "../styles/sidebar.css";

const Sidebar = () => {
  const navigate = useNavigate();

  return (
    <div className="sidebar">
      <h2>
        <img src={logo} alt="Logo" className="sidebar-logo" />
        Food Trucks
      </h2>
      <ul>
        <li onClick={() => navigate("/home")}>
          <FaTachometerAlt /> Dashboard
        </li>
        <li onClick={() => navigate("/admin/users")}>
          <FaUsers /> Users
        </li>
        <li onClick={() => navigate("/admin/trucks")}>
          <FaTruck /> Trucks
        </li>
        <li onClick={() => navigate("/admin/bookings")}>
          <FaCalendarAlt /> Bookings
        </li>
        <li onClick={() => navigate("/admin/orders")}>
          <FaUtensils /> Orders
        </li>
        <li onClick={() => navigate("/admin/payments")}>
          <FaMoneyBillWave /> Payments
        </li>
        {/* Add the Reviews link here */}
        <li onClick={() => navigate("/admin/reviews")}>
          <FaStar /> Reviews {/* Using FaStar icon */}
        </li>
        <li onClick={() => navigate("/admin/reports")}>
          <FaChartBar /> Reports
        </li>
      </ul>
    </div>
  );
};

export default Sidebar;
