import React, { useEffect, useState } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";
import "../styles/table.css";

const ReportsPage = () => {
  const [reports, setReports] = useState([]);
  const [search, setSearch] = useState("");

  const fetchReports = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/reports", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setReports(res.data);
    } catch (err) {
      console.error("Error fetching reports:", err);
    }
  };

  useEffect(() => {
    fetchReports();
  }, []);

  const handleStatusChange = async (id, newStatus) => {
    try {
      await axios.put(
        `http://localhost:5000/api/reports/${id}`,
        { status: newStatus },
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      fetchReports();
    } catch (err) {
      console.error("Failed to update status", err);
    }
  };

  const filtered = reports.filter((r) =>
    r.subject.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        <h2>📢 Problem Reports</h2>
        <input
          type="text"
          placeholder="Search by subject..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{
            padding: "8px",
            margin: "10px 0",
            border: "1px solid #ccc",
            borderRadius: "4px",
            width: "300px",
          }}
        />
        <table className="admin-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Role</th>
              <th>Category</th>
              <th>Subject</th>
              <th>Description</th>
              <th>Status</th>
              <th>Submitted</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((report) => (
              <tr key={report._id}>
                <td>
                  {report.user_id?.F_name} {report.user_id?.L_name}
                </td>
                <td>{report.role}</td>
                <td>{report.category}</td>
                <td>{report.subject}</td>
                <td>{report.description}</td>
                <td>
                  <select
                    value={report.status}
                    onChange={(e) =>
                      handleStatusChange(report._id, e.target.value)
                    }
                  >
                    <option value="pending">Pending</option>
                    <option value="in progress">In Progress</option>
                    <option value="resolved">Resolved</option>
                  </select>
                </td>
                <td>{new Date(report.createdAt).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ReportsPage;
