import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/database.js";
import authRoute from "./routes/authRoute.js";
import userRoute from "./routes/userRoute.js";
import frsRoute from "./routes/frsRoute.js";
import cvsRoute from "./routes/cvsRoute.js";
import msgRoute from "./routes/msgRoute.js";
import postRoute from "./routes/postRoute.js";
import { app, server } from "./socket/index.js";
import mongoose from "mongoose";

dotenv.config();
const port = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

app.use("/api/v1/auth", authRoute);
app.use("/api/v1/users", userRoute);
app.use("/api/v1/friends", frsRoute);
app.use("/api/v1/conversations", cvsRoute);
app.use("/api/v1/messages", msgRoute);
app.use("/api/v1/posts", postRoute);

connectDB()
  .then(async () => {
    // Warmup connection với một simple query
    try {
      await mongoose.connection.collection("users").countDocuments({})
      console.log("Database warmup successful")
    } catch (err) {
      console.warn("Warmup query failed:", err.message)
    }
    
    server.listen(port, () => {
      console.log(`server + Socket.IO running on port ${port}`);
    });
  })
  .catch((err) => console.log("db error:", err.message));
