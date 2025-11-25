import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/database.js";
import authRoute from "./routes/authRoute.js";
import userRoute from "./routes/userRoute.js";

dotenv.config();

const app = express();
const port = process.env.PORT || 5001;

app.use(express.json());

app.use("/api/v1/auth", authRoute);

app.use("/api/v1/users", userRoute);

connectDB()
  .then(() => {
    app.listen(port, () => console.log(`server đang chạy trên cổng ${port}`));
  })
  .catch((e) => console.log(`không thể kết nối server ${e.message}`));
