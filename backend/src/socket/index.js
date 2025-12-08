import { Server } from "socket.io";
import http from "http";
import express from "express";
import { socketAuth } from "../middleware/socketMiddleware.js";
import registerPresenceHandler from "./handlers/presence.js";
import registerConversationHandler from "./handlers/conversation.js";
import registerMessageHandler from "./handlers/message.js";

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*", credentials: true },
});

io.use(socketAuth);

io.on("connection", async (socket) => {
  console.log("connected:", socket.id);

  registerPresenceHandler(io, socket);
  registerConversationHandler(io, socket);
  registerMessageHandler(io, socket);
});

export { app, server, io };
