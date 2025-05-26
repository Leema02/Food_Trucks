// components/PieChartCard.js
import React from "react";
import { Pie } from "react-chartjs-2";

const PieChartCard = () => {
  const data = {
    labels: ["Total Orders", "Customer Growth", "Revenue"],
    datasets: [
      {
        data: [81, 22, 62],
        backgroundColor: ["#ff6384", "#36a2eb", "#ffce56"],
      },
    ],
  };

  return (
    <div className="card">
      <h4>Pie Chart</h4>
      <div style={{ flex: 1, position: "relative" }}>
        <Pie data={data} options={{ maintainAspectRatio: false }} />
      </div>
    </div>
  );
};

export default PieChartCard;
