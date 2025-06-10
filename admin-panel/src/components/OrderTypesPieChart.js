import { Pie } from "react-chartjs-2";
import { Chart as ChartJS, ArcElement, Tooltip, Legend, Title } from "chart.js";

ChartJS.register(ArcElement, Tooltip, Legend, Title);

const OrderTypesPieChart = ({ data }) => {
  const chartData = {
    labels: data.map((d) => d._id), // e.g. ["pickup", "delivery"]
    datasets: [
      {
        label: "Order Types",
        data: data.map((d) => d.count),
        backgroundColor: ["#4CAF50", "#2196F3", "#FFC107"],
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: "top",
      },
      title: {
        display: true,
        text: "Order Types Breakdown",
        font: {
          size: 18,
        },
        padding: {
          top: 10,
          bottom: 30,
        },
      },
    },
  };

  return (
  <div
    style={{
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      height: "100%", // let the parent card handle height
    }}
  >
    <div
      style={{
        width: "320px",       // 👈 Reduced from 400px
        height: "320px",      // 👈 Square size
        position: "relative",
      }}
    >
      <Pie data={chartData} options={options} />
    </div>
  </div>
);

};

export default OrderTypesPieChart;
