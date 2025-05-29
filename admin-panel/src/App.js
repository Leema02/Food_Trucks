import "./chartSetup"; // ✅ Register Chart.js elements globally

import { HashRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./screens/login";
import Home from "./screens/home";
import UsersPage from "./screens/UsersPage";
import OrdersPage from "./screens/OrdersPage"; // Correctly imported
import BookingsCalendarPage from "./components/BookingsCalendarPage";
import ReviewsDashboardPage from "./screens/ReviewsDashboardPage";
import TrucksPage from "./screens/TrucksPage";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/home" element={<Home />} />
        <Route path="/admin/users" element={<UsersPage />} />
        <Route path="/admin/bookings" element={<BookingsCalendarPage />} />
        <Route path="/admin/trucks" element={<TrucksPage />} />
        <Route path="/admin/orders" element={<OrdersPage />} />
        <Route path="/admin/reviews" element={<ReviewsDashboardPage />} />

        {/* Correctly routed */}
      </Routes>
    </Router>
  );
}

export default App;
