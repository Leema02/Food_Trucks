import React from "react";
import "../styles/home.css";
import { FaSignOutAlt, FaFilter, FaSearch } from "react-icons/fa";
import userAvatar from "../assets/avatar.png";
import { useNavigate } from "react-router-dom";

const Header = () => {
  const navigate = useNavigate();

  // ✅ Get user from localStorage
  const storedUser = JSON.parse(localStorage.getItem("adminUser"));
  const userName = storedUser ? `${storedUser.F_name}` : "Admin";

  const handleLogout = () => {
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminUser"); // ✅ clear stored user
    navigate("/login");
  };

  return (
    <div className="header">
      <div className="search-bar">
        <FaSearch className="icon" />
        <input type="text" placeholder="Search here" />
      </div>

      <div className="header-actions">
        <button className="icon-button">
          <FaFilter />
        </button>

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
