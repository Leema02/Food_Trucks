import React from "react";
import Sidebar from "../components/Sidebar";
import StatCard from "../components/StatCard";
import PieChartCard from "../components/PieChartCard";
import LineChart from "../components/LineChart";
import Header from "../components/Header";
import "../styles/home.css";

const Home = () => {
  return (
    <div className="dashboard-container">
      <Sidebar />
      <main className="main-panel">
        <Header />

        <div className="dashboard-content">
          <div className="dashboard-header">
            <h2>Dashboard Overview</h2>
            <p className="dashboard-subtext"></p>
          </div>

          {/* KPI Cards */}
          <section className="stats-section">
            <div className="stats-grid">
              <StatCard title="Total Orders" value="75" icon="🧾" />
              <StatCard title="Total Delivered" value="357" icon="✅" />
              <StatCard title="Total Canceled" value="65" icon="❌" />
              <StatCard title="Total Revenue" value="$128" icon="💰" />
            </div>
          </section>

          {/* Charts Section */}
          <section className="charts-section">
            <div className="charts-row">
              <PieChartCard />
              <LineChart />
            </div>
          </section>
        </div>
      </main>
    </div>
  );
};

export default Home;
