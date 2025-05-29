import React from "react";
import "../styles/OrderStatusProgress.css"; // 🔁 Optional: Create this if you want to separate styles

const OrderStatusCard = ({ data = {} }) => {
  const statuses = Object.entries(data || {});
  const total = Object.values(data || {}).reduce((sum, val) => sum + val, 0);

  const colors = {
    delivered: "#3e95cd", // Blue
    shipped: "#af4cc7", // Purple
    pending: "#f4a300", // Orange
  };

  return (
    <div className="order-status-card">
      <h3>Order Status</h3>
      {statuses.map(([status, value]) => {
        const percent = total ? Math.round((value / total) * 100) : 0;

        return (
          <div key={status} className="status-row">
            <strong>{status.charAt(0).toUpperCase() + status.slice(1)}</strong>
            <div className="progress-bar-container">
              <div
                className="progress-bar"
                style={{
                  width: `${percent}%`,
                  backgroundColor: colors[status] || "#ccc",
                }}
              ></div>
            </div>
            <span>{percent}%</span>
          </div>
        );
      })}
    </div>
  );
};

export default OrderStatusCard;
