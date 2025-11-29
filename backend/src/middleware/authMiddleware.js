import jwt from "jsonwebtoken";
import User from "../models/user.js";

export const protectedRoute = (req, res, next) => {
  try {
    // lay token tu header
    const authHeader = req.headers["authorization"];

    if (!authHeader) {
      return res
        .status(401)
        .json({ success: false, message: "không tìm thấy access token" });
    }

    const token = authHeader.split(" ")[1]; // "Bearer <token>"

    if (!token) {
      return res
        .status(401)
        .json({ success: false, message: "không tìm thấy access token" });
    }

    // verify token
    jwt.verify(token, process.env.PRIVATE_ACCESS_TOKEN, async (e, decoded) => {
      if (e) {
        console.log("verify error:", e.message);
        return res.status(401).json({
          success: false,
          message: "access token không hợp lệ hoặc hết hạn",
        });
      }

      // tim user tu decoded info
      const user = await User.findById(decoded.userId).select(
        "-hashedPassword"
      );
      if (!user) {
        return res
          .status(404)
          .json({ success: false, message: "user không tồn tại" });
      }

      // gan user vao req
      req.user = {
        id: user._id.toString(),
        role: user.role,
        ...user.toObject(),
      };

      next();
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};
