import React from "react";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Title,
  Legend,
} from "chart.js";
import dayjs from "dayjs"; // ✅ Add this

ChartJS.register(
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Title,
  Legend
);

// ✅ STEP 1: Add this helper before the component
const generateLast6Months = () => {
  const months = [];
  const now = dayjs();
  for (let i = 5; i >= 0; i--) {
    months.push(now.subtract(i, "month").format("YYYY-MM"));
  }
  return months;
};

const UserSignupLineChart = ({ data }) => {
  // ✅ STEP 2: Replace your chartData logic with this block
  const months = generateLast6Months();
  const signupMap = Object.fromEntries(data.map((d) => [d._id, d.count]));

  const chartData = {
    labels: months,
    datasets: [
      {
        label: "New Users",
        data: months.map((month) => signupMap[month] || 0),
        borderColor: "#3e95cd",
        backgroundColor: "rgba(62,149,205,0.2)",
        tension: 0.4,
        fill: true,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      title: {
        display: true,
        text: "🧍 New Users Over Time",
        font: { size: 18 },
        padding: { top: 10, bottom: 20 },
      },
      legend: {
        display: true,
        position: "top",
      },
    },
  };

  return <Line data={chartData} options={options} />;
};

export default UserSignupLineChart;
