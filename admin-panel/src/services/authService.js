import axios from "axios";

const API_BASE_URL = "http://localhost:5000/api/admin";

export const authService = {
  login: async ({ email, Password }) => {
    try {
      const response = await axios.post(`${API_BASE_URL}/login`, {
        email,
        password: Password,
      });

      return {
        success: true,
        data: response.data,
      };
    } catch (error) {
      console.error("Login error:", error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.message || "Login failed",
      };
    }
  },
};
