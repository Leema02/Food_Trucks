import { Pie } from "react-chartjs-2";
import { Chart as ChartJS, ArcElement, Tooltip, Legend, Title } from "chart.js";

ChartJS.register(ArcElement, Tooltip, Legend, Title);

const OrderTypesPieChart = ({ data }) => {
  const chartData = {
    labels: data.map((d) => d._id), // e.g. ["pickup", "delivery", "dine-in"]
    datasets: [
      {
        label: "Order Types",
        data: data.map((d) => d.count), // e.g. [10, 15, 5]
        backgroundColor: ["#4CAF50", "#2196F3", "#FFC107"], // green, blue, yellow
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
        text: "Order Types Breakdown", // 👈 Add your chart title here
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

  return <Pie data={chartData} options={options} />;
};

export default OrderTypesPieChart;
