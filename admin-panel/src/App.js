import "./chartSetup"; // ✅ Register Chart.js elements globally

import { HashRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./screens/login";
import Home from "./screens/home";
import UsersPage from "./screens/UsersPage";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/home" element={<Home />} />
        <Route path="/admin/users" element={<UsersPage />} />
      </Routes>
    </Router>
  );
}

export default App;
