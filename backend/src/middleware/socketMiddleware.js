import jwt from "jsonwebtoken";
import User from "../models/user.js";

export const socketAuth = async (socket, next) => {
  try {
    const token =
      socket.handshake.auth?.token || socket.handshake.headers?.token;

    if (!token) {
      const err = new Error("NO_TOKEN");
      err.data = { msg: "thiếu token" };
      return next(err);
    }

    const decoded = jwt.verify(token, process.env.PRIVATE_ACCESS_TOKEN);

    const idToFind = decoded.id || decoded.userId;

    if (!idToFind) {
      console.error("Token decoded but no id found:", decoded);
      return next(new Error("INVALID_TOKEN_PAYLOAD"));
    }

    const user = await User.findById(idToFind).select(
      "_id username displayName avatarUrl"
    );

    if (!user) {
      const err = new Error("USER_NOT_FOUND");
      err.data = { msg: "không tìm thấy user" };
      return next(err);
    }

    socket.userId = user._id.toString();
    socket.user = user;

    next();
  } catch (e) {
    console.error("Socket Auth Failed:", e.message);
    const error = new Error("INVALID_TOKEN");
    error.data = { msg: "token không hợp lệ hoặc hết hạn" };
    next(error);
  }
};
