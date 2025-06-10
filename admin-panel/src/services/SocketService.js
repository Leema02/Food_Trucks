// src/services/SocketService.js
import { io } from "socket.io-client";

class SocketService {
  static instance = null;

  constructor() {
    if (SocketService.instance) {
      return SocketService.instance;
    }

    this.socket = null;
    this.currentUserId = null;
    this.onNewFunction=null;
    this.server = "http://localhost:5000"; // 10.0.2.2 for Android emulator becomes localhost in web
    SocketService.instance = this;

  }
  setFunction(func){
    this.onNewFunction=func;
  }
  setId(id) {
    this.currentUserId = id;
  }

  connectToServer() {
    console.log("Connecting to socket server...");
    this.socket = io(this.server, {
      transports: ["websocket"],
      path: "/socket.io/socket",
    });
    this.socket.on("connect", () => {
      console.log("Connected to socket server");
      if (this.currentUserId) {
        this.socket.emit("setId", {id:this.currentUserId,role:'admin'});
      }
    });
    this.socket.on("Notification", (data) => {
      console.log("Notification received:", data);
      if(this.onNewFunction){
        this.onNewFunction(data);
      }
      this.showNotification(data.title, data.message);
    });
    this.socket.on("disconnect", () => {
      console.log("Disconnected from socket server");
    });
  }

  showNotification(title, message) {
    if (Notification.permission === "granted") {
      new Notification(title, { body: message });
    } else if (Notification.permission !== "denied") {
      Notification.requestPermission().then(permission => {
        if (permission === "granted") {
          new Notification(title, { body: message });
        }
      });
    }
  }
}

const socketService = new SocketService();
export default socketService;