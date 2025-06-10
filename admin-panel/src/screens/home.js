import React, { useEffect, useState, useCallback } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";
import StatCard from "../components/StatCard";
import OrdersByTruckChart from "../components/OrdersByTruckChart";
import OrderTypesPieChart from "../components/OrderTypesPieChart";
import Header from "../components/Header";
import OrderStatusProgress from "../components/OrderStatusProgress";
import OrdersByCityPieChart from "../components/OrdersByCityPieChart";
import UserSignupLineChart from "../components/UserSignupLineChart";
import "../styles/OrderStatusProgress.css";
import "../styles/home.css";

const Home = () => {
  const [stats, setStats] = useState({
    totalOrders: 0,
    totalTrucks: 0,
    totalUsers: 0,
    totalRevenue: 0,
    totalBookings: 0,
  });
  const [topOrdersByTruck, setTopOrdersByTruck] = useState([]);
  const [orderTypesData, setOrderTypesData] = useState([]);
  const [ordersByCityData, setOrdersByCityData] = useState([]);
  const [statusSummary, setStatusSummary] = useState({});
  const [signupStats, setSignupStats] = useState([]);

  // Fetch functions using useCallback for memoization
  const fetchTotalBookings = useCallback(async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/bookings/total-bookings",
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
  }, []);

  const fetchSignupStats = useCallback(async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/users/signup-stats", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setSignupStats(res.data);
    } catch (error) {
      console.error("Error fetching signup stats:", error);
    }
  }, []);

  const fetchTotalOrders = useCallback(async () => {
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
  }, []);

  const fetchTotalTrucks = useCallback(async () => {
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
  }, []);

  const fetchTotalUsers = useCallback(async () => {
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
  }, []);

const fetchOrdersByTruck = useCallback(async () => {
    try {
        // Change the URL to your new top 5 endpoint
        const res = await axios.get("http://localhost:5000/api/orders/stats/top5-by-truck", {
            headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
        });

        const rawData = res.data; // This will now contain only the top 5 from the backend

        // *** You still need the frontend aggregation ***
        // Because the backend groups by _id, if two _ids have the same truckName,
        // they will still appear as separate entries in the rawData from the backend.
        // The frontend aggregation sums these up for a single bar per unique truckName.
   const aggregatedData = rawData.reduce((acc, current) => {
    const existingTruck = acc.find(item => item.truckName === current.truckName);
    if (existingTruck) {
        existingTruck.orderCount += current.orderCount;
    } else {
        acc.push({ truckName: current.truckName || 'Unknown Truck', orderCount: current.orderCount });
    }
    return acc;
}, []);

setTopOrdersByTruck(aggregatedData); // Set the aggregated data to state
    } catch (err) {
        console.error("Failed to fetch top 5 orders by truck data:", err);
    }
}, []);


  const fetchOrderTypes = useCallback(async () => {
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
  }, []);

  const fetchOrdersByCity = useCallback(async () => {
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
  }, []);

  const fetchStatusSummary = useCallback(async () => {
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
  }, []);

  useEffect(() => {
    fetchTotalOrders();
    fetchTotalTrucks();
    fetchTotalUsers();
    fetchOrderTypes();
    fetchStatusSummary();
    fetchOrdersByTruck(); // This will now fetch and aggregate
    fetchOrdersByCity();
    fetchTotalBookings();
    fetchSignupStats();
  }, [fetchTotalOrders, fetchTotalTrucks, fetchTotalUsers, fetchOrderTypes,
      fetchStatusSummary, fetchOrdersByTruck, fetchOrdersByCity,
      fetchTotalBookings, fetchSignupStats]); // Added all dependencies for useCallback functions

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
              <OrdersByTruckChart data={topOrdersByTruck} />
            </div>
            <div className="chart-card">
              <OrderTypesPieChart data={orderTypesData} />
            </div>
            <div className="chart-card">
              <OrdersByCityPieChart data={ordersByCityData} />
            </div>
            <div className="chart-card">
              <UserSignupLineChart data={signupStats} />
            </div>

          </div>
        </div>
      </main>
    </div>
  );
};

export default Home;