import React from "react";
import "../styles/OrderStatusProgress.css"; // Optional: Create this if you want to separate styles

const OrderStatusCard = ({ data = {} }) => {
  // Ensure data is treated as an object, even if it's null/undefined
  const statuses = Object.entries(data || {});
  const total = Object.values(data || {}).reduce((sum, val) => sum + val, 0);

  // Define colors for your new statuses
  const colors = {
    preparing: "#FFC107", // Yellow/Amber for preparing
    pending: "#F44336", // Red for pending (often requires attention)
    ready: "#2196F3", // Blue for ready (awaiting pickup/delivery)
    completed: "#4CAF50", // Green for completed
  };

  return (
    <div className="order-status-card">
      <h3>Order Status</h3>
      {statuses.length > 0 ? ( // Add a check to render only if there's data
        statuses.map(([status, value]) => {
          // Calculate percentage safely, avoiding division by zero
          const percent = total ? Math.round((value / total) * 100) : 0;

          return (
            <div key={status} className="status-row">
              {/* Capitalize the first letter for display */}
              <strong>
                {status.charAt(0).toUpperCase() + status.slice(1)}
              </strong>
              <div className="progress-bar-container">
                <div
                  className="progress-bar"
                  style={{
                    width: `${percent}%`,
                    backgroundColor: colors[status] || "#ccc", // Fallback color
                  }}
                ></div>
              </div>
              <span>{percent}%</span>
            </div>
          );
        })
      ) : (
        <p>No order status data available.</p> // Message if no data
      )}
    </div>
  );
};

export default OrderStatusCard;
