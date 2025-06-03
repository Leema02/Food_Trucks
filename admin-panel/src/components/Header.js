import React from "react";
import "../styles/home.css";
import { FaSignOutAlt } from "react-icons/fa";
import userAvatar from "../assets/avatar.png";
import { useNavigate } from "react-router-dom";
import NotificationBell from "./NotificationBell";

const Header = () => {
  const navigate = useNavigate();

  // Get user from localStorage
  const storedUser = JSON.parse(localStorage.getItem("adminUser"));
  const userName = storedUser ? `${storedUser.F_name}` : "Admin";

  const handleLogout = () => {
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminUser");
    navigate("/login");
  };

  return (
    <div className="header">
      <div className="header-actions">
        <NotificationBell />

        <button className="icon-button" onClick={handleLogout}>
          <FaSignOutAlt />
        </button>

        <div className="user-info">
          <span className="greeting">
            Hi, <strong>{userName}</strong>
          </span>
          <img src={userAvatar} alt="User Avatar" className="avatar" />
        </div>
      </div>
    </div>
  );
};

export default Header;
