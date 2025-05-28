import "./chartSetup"; // ✅ Register Chart.js elements globally

import { HashRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./screens/login";
import Home from "./screens/home";
import UsersPage from "./screens/UsersPage";
import BookingsCalendarPage from "./components/BookingsCalendarPage";
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
      </Routes>
    </Router>
  );
}

export default App;
