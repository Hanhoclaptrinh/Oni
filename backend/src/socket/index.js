import { Server } from "socket.io";
import http from "http";
import express from "express";

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*", credentials: true },
});

io.on("connection", async (client) => {
  console.log(`client connected: ${client.id}`);

  socket.on("disconnect", () => {
    console.log(`client disconnected: ${client.id}`);
  });
});

export { app, server };
