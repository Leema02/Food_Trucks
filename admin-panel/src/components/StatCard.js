// components/StatCard.js
import React from "react";
import "../styles/home.css";

const StatCard = ({ title, value }) => {
  return (
    <div className="stat-card">
      <h4>{title}</h4>
      <p>{value}</p>
    </div>
  );
};

export default StatCard;
