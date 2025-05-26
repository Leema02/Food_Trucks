// components/LineChart.js
import React from "react";
import { Line } from "react-chartjs-2";

const LineChart = () => {
  const data = {
    labels: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    datasets: [
      {
        label: "Orders",
        data: [120, 190, 456, 320, 210, 220, 380],
        fill: false,
        borderColor: "#3e95cd",
      },
    ],
  };

  return (
    <div className="card">
      <h4>Chart Order</h4>
      <div style={{ flex: 1, position: "relative" }}>
        <Line data={data} options={{ maintainAspectRatio: false }} />
      </div>
    </div>
  );
};

export default LineChart;
