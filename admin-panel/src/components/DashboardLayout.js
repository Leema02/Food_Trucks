// src/components/DashboardLayout.js
import React from "react";
import Sidebar from "./Sidebar";
import { Outlet } from "react-router-dom";

const DashboardLayout = () => {
  return (
    <div className="dashboard-container">
      <Sidebar />
      <main className="main-panel">
        <Outlet /> {/* This is where page content shows */}
      </main>
    </div>
  );
};

export default DashboardLayout;
