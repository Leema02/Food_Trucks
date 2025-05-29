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
  });
  const [ordersByTruck, setOrdersByTruck] = useState([]);
  const [orderTypesData, setOrderTypesData] = useState([]);
  const [ordersByCityData, setOrdersByCityData] = useState([]);
  const [statusSummary, setStatusSummary] = useState({});

  useEffect(() => {
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
          totalTrucks: res.data.totalTrucks,
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
        const res = await axios.get(
          "http://localhost:5000/api/orders/by-truck",
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
          }
        );
        setOrdersByTruck(res.data);
      } catch (err) {
        console.error("Failed to fetch orders by truck", err);
      }
    };
    const fetchOrderTypes = async () => {
      const res = await axios.get(
        "http://localhost:5000/api/orders/order-types",
        {
          headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
        }
      );
      setOrderTypesData(res.data);
    };

    const fetchOrdersByCity = async () => {
      const res = await axios.get(
        "http://localhost:5000/api/orders/orders-by-city",
        {
          headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
        }
      );
      setOrdersByCityData(res.data);
    };
    const fetchStatusSummary = async () => {
      const res = await axios.get(
        "http://localhost:5000/api/orders/status-summary",
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setStatusSummary(res.data);
    };
    fetchTotalOrders(); // ✅ already working — keep it
    fetchTotalTrucks();
    fetchTotalUsers(); // ✅ new addition
    fetchOrderTypes();
    fetchStatusSummary();

    fetchOrdersByTruck();
    fetchOrdersByCity();
  }, []);

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
                title="Total Revenue"
                value={`$${stats.totalRevenue}`}
                icon="💰"
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
