import React, { useEffect, useState } from "react";
import { FaBell } from "react-icons/fa";
import io from "socket.io-client";
import "../styles/notification.css";

const socket = io("http://localhost:5000"); // adjust if needed

const NotificationBell = () => {
  const [notifications, setNotifications] = useState([]);
  const [showPopup, setShowPopup] = useState(false);

  useEffect(() => {
    socket.on("new_report", (data) => {
      setNotifications((prev) => [data, ...prev]);
    });

    return () => {
      socket.off("new_report");
    };
  }, []);

  return (
    <div className="notification-wrapper">
      <div className="icon-button" onClick={() => setShowPopup(!showPopup)}>
        <FaBell style={{ color: "orange", fontSize: "20px" }} />
        {notifications.length > 0 && <span className="badge">{notifications.length}</span>}
      </div>

      {showPopup && (
        <div className="notification-popup">
          {notifications.length === 0 ? (
            <p>No new reports</p>
          ) : (
            notifications.map((n, i) => (
              <div key={i} className="notification-item">
                <strong>{n.category}</strong>: {n.subject}
                <div className="notification-meta">
                  <small>{n.role}</small> |{" "}
                  <small>{new Date(n.submittedAt).toLocaleString()}</small>
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
};

export default NotificationBell;
