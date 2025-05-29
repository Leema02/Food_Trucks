import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { Bar } from "react-chartjs-2";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const OrdersByTruckChart = ({ data }) => {
  const chartData = {
    labels: data.map((d) => d.truckName),
    datasets: [
      {
        label: "Orders",
        data: data.map((d) => d.orderCount),
        backgroundColor: "rgba(54, 162, 235, 0.6)",
        borderRadius: 5,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false, // 🔧 key to control height
    plugins: {
      legend: { position: "top" },
      title: { display: true, text: "Orders by Truck" },
    },
  };

  return (
    <div
      style={{
        width: "100%",
        maxWidth: "400px",
        height: "300px",
        margin: "0 auto",
      }}
    >
      <Bar data={chartData} options={options} />
    </div>
  );
};

export default OrdersByTruckChart;
