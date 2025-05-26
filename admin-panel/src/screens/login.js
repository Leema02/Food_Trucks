import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/login.css";
import logo from "../assets/appIcon.png";
import { FaEye, FaEyeSlash } from "react-icons/fa";
import { authService } from "../services/authService";

function Login() {
  const [email, setEmail] = useState("");
  const [Password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);
    const result = await authService.login({ email, Password });

    setIsLoading(false);
    if (result.success) {
      localStorage.setItem("token", result.data.token);
      localStorage.setItem("email", result.data.admin.email);
      navigate("/home");
    } else {
      setError("Login failed. Please check the data you entered.");
    }
  };

  return (
    <div className="login-container">
      <form onSubmit={handleSubmit} className="login-form">
        <div className="logo-container">
          <img src={logo} alt="App Logo" className="app-logo" />
        </div>
        <h2> Admin Login </h2>
        {error && <div className="error-message">{error}</div>}

        <div className="form-group">
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={isLoading}
          />
        </div>

        <div className="form-group password-group">
          <label htmlFor="password">password</label>
          <div className="password-input-wrapper">
            <input
              type={showPassword ? "text" : "password"}
              id="password"
              value={Password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isLoading}
            />
            <span
              className="toggle-password"
              onClick={() => setShowPassword((prev) => !prev)}
            >
              {showPassword ? <FaEyeSlash /> : <FaEye />}
            </span>
          </div>
        </div>
        <button type="submit" className="login-button" disabled={isLoading}>
          {isLoading ? "loading" : <strong>login</strong>}
        </button>
      </form>
    </div>
  );
}

export default Login;
