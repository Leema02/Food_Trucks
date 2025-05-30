import React, { useEffect, useState } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";
import StatCard from "../components/StatCard";
import OrdersByTruckChart from "../components/OrdersByTruckChart";
import OrderTypesPieChart from "../components/OrderTypesPieChart";
import Header from "../components/Header";
import OrderStatusProgress from "../components/OrderStatusProgress";
import OrdersByCityPieChart from "../components/OrdersByCityPieChart";
import "../styles/OrderStatusProgress.css";

import "../styles/home.css";

const Home = () => {
  const [stats, setStats] = useState({
    totalOrders: 0,
    totalTrucks: 0,
    totalUsers: 0,
    totalRevenue: 0,
    totalBookings: 0, // Initialize totalBookings state
  });
  const [ordersByTruck, setOrdersByTruck] = useState([]);
  const [orderTypesData, setOrderTypesData] = useState([]);
  const [ordersByCityData, setOrdersByCityData] = useState([]);
  const [statusSummary, setStatusSummary] = useState({});

  // ⭐⭐⭐ MOVE ALL FETCH FUNCTIONS HERE, OUTSIDE OF useEffect ⭐⭐⭐

  const fetchTotalBookings = async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/bookings/total-bookings", // Corrected URL
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setStats((prev) => ({
        ...prev,
        totalBookings: res.data.total,
      }));
    } catch (err) {
      console.error("Failed to fetch total bookings:", err);
      setStats((prev) => ({
        ...prev,
        totalBookings: "N/A",
      }));
    }
  };

  const fetchTotalOrders = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/orders/total", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setStats((prev) => ({
        ...prev,
        totalOrders: res.data.totalOrders,
      }));
    } catch (err) {
      console.error("Failed to fetch total orders:", err);
    }
  };

  const fetchTotalTrucks = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/trucks/total", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setStats((prev) => ({
        ...prev,
        totalTrucks: res.data.total,
      }));
    } catch (err) {
      console.error("Failed to fetch total trucks:", err);
    }
  };

  const fetchTotalUsers = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/users/total", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setStats((prev) => ({
        ...prev,
        totalUsers: res.data.totalUsers,
      }));
    } catch (err) {
      console.error("Failed to fetch total users:", err);
    }
  };

  const fetchOrdersByTruck = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/orders/by-truck", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setOrdersByTruck(res.data);
    } catch (err) {
      console.error("Failed to fetch orders by truck", err);
    }
  };

  const fetchOrderTypes = async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/orders/order-types",
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setOrderTypesData(res.data);
    } catch (err) {
      console.error("Failed to fetch order types:", err);
    }
  };

  const fetchOrdersByCity = async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/orders/orders-by-city",
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setOrdersByCityData(res.data);
    } catch (err) {
      console.error("Failed to fetch orders by city:", err);
    }
  };

  const fetchStatusSummary = async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/orders/status-summary",
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setStatusSummary(res.data);
    } catch (err) {
      console.error("Failed to fetch status summary:", err);
    }
  };

  // ⭐⭐⭐ Now, call the functions inside useEffect ⭐⭐⭐
  useEffect(() => {
    fetchTotalOrders();
    fetchTotalTrucks();
    fetchTotalUsers();
    fetchOrderTypes();
    fetchStatusSummary();
    fetchOrdersByTruck();
    fetchOrdersByCity();
    fetchTotalBookings(); // Call the newly moved function
  }, []); // Empty dependency array means this runs once on component mount

  return (
    <div className="dashboard-container">
      <Sidebar />
      <main className="main-panel">
        <Header />
        <div className="dashboard-content">
          <div className="dashboard-header">
            <h2>Dashboard Overview</h2>
          </div>

          {/* KPI Cards */}
          <section className="stats-section">
            <div className="stats-grid">
              <StatCard
                title="Total Orders"
                value={stats.totalOrders}
                icon="🧾"
              />
              <StatCard
                title="Total Trucks"
                value={stats.totalTrucks}
                icon="🚚"
              />
              <StatCard
                title="Total Users"
                value={stats.totalUsers}
                icon="👥"
              />
              <StatCard
                title="Total Bookings"
                value={stats.totalBookings}
                icon="📅"
              />
            </div>
          </section>

          {/* Charts Section */}
          <div className="charts-row">
            <div className="chart-card">
              <OrdersByTruckChart data={ordersByTruck} />
            </div>
            <div className="chart-card">
              <OrderTypesPieChart data={orderTypesData} />
            </div>
            <div className="chart-card">
              <OrdersByCityPieChart data={ordersByCityData} />
            </div>

            <OrderStatusProgress data={statusSummary} />
          </div>
        </div>
      </main>
    </div>
  );
};

export default Home;
