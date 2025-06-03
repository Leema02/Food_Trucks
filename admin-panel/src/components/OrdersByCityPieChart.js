import { Pie } from "react-chartjs-2";
import { Chart as ChartJS, ArcElement, Tooltip, Legend, Title } from "chart.js";
ChartJS.register(ArcElement, Tooltip, Legend, Title);

const OrdersByCityPieChart = ({ data }) => {
  const chartData = {
    labels: data.map((d) => d._id),
    datasets: [
      {
        data: data.map((d) => d.count),
        backgroundColor: [
          "#36A2EB",
          "#FF6384",
          "#FFCE56",
          "#4BC0C0",
          "#9966FF",
        ],
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      title: {
        display: true,
        text: "Orders by City",
        font: { size: 18 },
      },
      legend: {
        position: "bottom",
      },
    },
  };

  return (
  <div
    style={{
      display: "flex",
      justifyContent: "center",   // horizontally center
      alignItems: "center",       // vertically center
      height: "100%",             // take full height of card
      minHeight: "400px",         // ensure visual space
    }}
  >
    <div
      style={{
        width: "320px",           // ⬅️ Increase chart size
        height: "320px",
        position: "relative",
      }}
    >
      <Pie data={chartData} options={options} />
    </div>
  </div>
);
};

export default OrdersByCityPieChart;
