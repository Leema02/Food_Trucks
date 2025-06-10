import axios from "axios";
import socketService from "./SocketService";

const API_BASE_URL = "http://localhost:5000/api/admin";

export const authService = {
  login: async ({ email, Password }) => {
    try {
      const response = await axios.post(`${API_BASE_URL}/login`, {
        email,
        password: Password,
      });
      console.log(response.data.admin.id)
      socketService.setId(response.data.admin.id);
      socketService.connectToServer();
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
